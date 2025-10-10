import Foundation
import CoreLocation

// MARK: - Models brugt her
// Antager at du allerede har disse i Models.swift.
// Hvis ikke, så afkommentér nedenfor og brug dem.
 /*
 struct Store: Identifiable, Hashable {
     var id: String
     var name: String
     var lat: Double
     var lon: Double
 }

 struct StoreTotal: Identifiable, Hashable {
     var id: String { storeName }
     var storeName: String
     var total: Double
 }
 */

// Observations gemmes i cache/hukommelse
private struct PriceObservation: Codable {
    let ean: String
    let storeId: String
    let unitPrice: Double    // inkl. kampagne udjævnet til stykpris
    let deposit: Double
    let timestamp: Date
}

final class PricingService {
    static let shared = PricingService()
    private init() {}

    // MARK: – Konfig
    var apiTokenProvider: () -> String = { "" } // <-- Sæt via AppState/Keychain
    /// Hvor langt vi søger (meter)
    var defaultRadius: Double = 2_000

    // Session med kortere timeouts (vi spørger mange butikker hurtigt)
    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 6
        cfg.timeoutIntervalForResource = 10
        return URLSession(configuration: cfg)
    }()

    // in-memory cache (nulstilles ved app-genstart)
    private var cache: [String: PriceObservation] = [:] // key = "\(ean)|\(storeId)"

    // fallback “prisniveau” pr. kæde
    private func chainFactor(name: String) -> Double {
        switch name.lowercased() {
        case "netto": return 0.96
        case "rema 1000", "rema1000": return 0.98
        case "føtex", "foetex", "fotex": return 1.00
        case "fakta": return 0.97
        default: return 1.00
        }
    }

    // MARK: – Offentlig API

    /// Hovedfunktion: find billigste butikker for en *hel liste* inden for radius fra brugerens lokation.
    /// Returnerer de 2 billigste totals sorteret stigende.
    func findCheapest(list: ShoppingList, location: CLLocation?, radiusMeters: Double? = nil) async -> [StoreTotal] {

        // 0) Lille “AI-tænkepause” (føles naturligt at den lige beregner)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // ~1 sek

        // 1) Hent kandidat-butikker og filtrér på radius
        let radius = radiusMeters ?? defaultRadius
        let candidates = nearestStores(around: location, within: radius)

        // 2) Parallel beregning pr. butik (hurtigt)
        var totals: [StoreTotal] = []
        await withTaskGroup(of: StoreTotal?.self) { group in
            for store in candidates {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    // summer alle varer for denne butik
                    var sum = 0.0
                    for item in list.items {
                        let unit = await self.unitPrice(for: item, in: store)
                        sum += unit * Double(item.qty)
                    }
                    let rounded = (sum * 100).rounded() / 100
                    return StoreTotal(storeName: store.name, total: rounded)
                }
            }
            for await maybe in group {
                if let t = maybe { totals.append(t) }
            }
        }

        // 3) Vælg top-2 billigste
        return totals.sorted { $0.total < $1.total }.prefix(2).map { $0 }
    }

    // MARK: – Enkeltvare: pris (API hvis muligt, ellers heuristik)

    private func unitPrice(for item: ShoppingItem, in store: Store) async -> Double {
        // 1) EAN fra CatalogService (ean-map.json eller varianten selv)
        let ean = CatalogService.shared.ean(for: item.product, variant: item.variant)

        // 2) Hvis ingen EAN → heuristik * kædefaktor
        guard let ean else {
            let est = heuristicEstimate(product: item.product, variant: item.variant)
            return est * chainFactor(name: store.name)
        }

        // 3) Cache (30 min)
        let key = "\(ean)|\(store.id)"
        if let hit = cache[key], Date().timeIntervalSince(hit.timestamp) < 60 * 30 {
            return hit.unitPrice + hit.deposit
        }

        // 4) Forsøg API
        if let apiPrice = await fetchFromAPI(ean: ean, storeId: store.id) {
            cache[key] = apiPrice
            // lær af den observerede pris
            updatePrior(product: item.product, variant: item.variant,
                        observed: apiPrice.unitPrice + apiPrice.deposit)
            return apiPrice.unitPrice + apiPrice.deposit
        }

        // 5) Fallback: heuristik * kædefaktor
        let est = heuristicEstimate(product: item.product, variant: item.variant)
        return est * chainFactor(name: store.name)
    }

    // MARK: – Salling API (pris for EAN i butik)

    private func fetchFromAPI(ean: String, storeId: String) async -> PriceObservation? {
        guard let url = buildURL(
            base: "https://api.sallinggroup.com/v2/products/\(ean)",
            query: ["storeId": storeId]
        ) else { return nil }

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let tok = apiTokenProvider()
        if !tok.isEmpty {
            req.setValue("Bearer \(tok)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, resp) = try await session.data(for: req)
            guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }

            struct Resp: Codable {
                struct Instore: Codable {
                    struct Campaign: Codable { let price: Double?; let quantity: Int? }
                    struct Deposit: Codable { let price: Double? }
                    let price: Double?
                    let unitPrice: Double?
                    let campaign: Campaign?
                    let deposit: Deposit?
                }
                let instore: Instore?
            }

            let dec = try JSONDecoder().decode(Resp.self, from: data)

            let base = dec.instore?.price ?? dec.instore?.unitPrice
            let cPrice = dec.instore?.campaign?.price
            let cQty   = dec.instore?.campaign?.quantity
            let campaignUnit = (cPrice != nil && (cQty ?? 0) > 0) ? (cPrice! / Double(cQty!)) : nil

            // vælg billigste af kampagne vs. normal
            let unit = minOptional(campaignUnit, base) ?? base
            let deposit = dec.instore?.deposit?.price ?? 0.0

            guard let u = unit else { return nil }

            return PriceObservation(
                ean: ean,
                storeId: storeId,
                unitPrice: u,
                deposit: deposit,
                timestamp: Date()
            )
        } catch {
            return nil
        }
    }

    private func minOptional(_ a: Double?, _ b: Double?) -> Double? {
        switch (a, b) {
        case let (x?, y?): return min(x, y)
        case let (x?, nil): return x
        case let (nil, y?): return y
        default: return nil
        }
    }

    // MARK: – “AI”: heuristik + historik (EMA)

    private var priors: [String: (mean: Double, alpha: Double)] = [:] // (produktId|unit|organic)

    private func heuristicEstimate(product: Product, variant: ProductVariant) -> Double {
        let base: Double = {
            switch product.id {
            case _ where product.name.localizedCaseInsensitiveContains("banan"):
                return variant.unit == "bundt" ? 22.0 : 4.5
            case _ where product.name.localizedCaseInsensitiveContains("mælk"):
                return 9.5
            case _ where product.name.localizedCaseInsensitiveContains("cola"):
                return variant.unit == "24-pak" ? 115.0 : (variant.unit == "6-pak" ? 35.0 : 6.0)
            default:
                return 10.0
            }
        }()

        let organicCoef = variant.organic ? 1.15 : 1.0

        let unitCoef: Double = {
            switch variant.unit.lowercased() {
            case "kg": return 1.0
            case "ltr", "l": return 1.0
            case "stk": return 1.0
            case "bundt": return 4.5
            case "6-pak": return 6.0
            case "24-pak": return 24.0
            default: return 1.0
            }
        }()

        var estimate = base * organicCoef
        if unitCoef > 1.1 { estimate *= unitCoef }

        let key = "\(product.id)|\(variant.unit)|\(variant.organic ? "1":"0")"
        if let prior = priors[key] {
            estimate = 0.7 * prior.mean + 0.3 * estimate
        }

        return (estimate * 100).rounded() / 100
    }

    private func updatePrior(product: Product, variant: ProductVariant, observed: Double) {
        let key = "\(product.id)|\(variant.unit)|\(variant.organic ? "1":"0")"
        let old = priors[key]?.mean ?? observed
        let alpha = 0.3
        let newMean = (1 - alpha) * old + alpha * observed
        priors[key] = (newMean, alpha)
    }

    // MARK: - Butikker & radius

    /// Simpel liste af butikker i DK (demo). Erstat med rigtigt Store-API hvis du har.
    private func knownStores() -> [Store] {
        [
            .init(id: "netto-001", name: "Netto",  lat: 55.6761, lon: 12.5683),
            .init(id: "rema-002",  name: "Rema 1000", lat: 55.6784, lon: 12.5710),
            .init(id: "fotex-003", name: "Føtex", lat: 55.6740, lon: 12.5650)
        ]
    }

    /// Filtrér butikker inden for radius fra en lokation (eller alle hvis lokation mangler).
    private func nearestStores(around location: CLLocation?, within radius: Double) -> [Store] {
        let all = knownStores()
        guard let loc = location else { return all } // ingen GPS → prøv alle vi kender
        return all.filter { store in
            let d = CLLocation(latitude: store.lat, longitude: store.lon)
                .distance(from: loc)
            return d <= radius
        }
    }
}

// MARK: - URL helper

private func buildURL(base: String, query: [String: String]) -> URL? {
    guard var comp = URLComponents(string: base) else { return nil }
    var items: [URLQueryItem] = comp.queryItems ?? []
    for (k, v) in query { items.append(URLQueryItem(name: k, value: v)) }
    comp.queryItems = items
    return comp.url
}
