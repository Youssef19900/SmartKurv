import Foundation
import CoreLocation
import Combine

@MainActor
final class AppState: ObservableObject {

    // MARK: - Søg
    @Published var query: String = ""
    @Published var searchResults: [Product] = []

    // MARK: - Varianter og øko
    @Published var selectedVariant: [String: ProductVariant] = [:]
    @Published var isOrganic: [String: Bool] = [:]

    // MARK: - Indkøbsliste + historik
    @Published var currentList: ShoppingList = ShoppingList()
    @Published var history: [ShoppingList] = []

    // Badge i UI (antal stk. i kurven)
    var cartItemCount: Int {
        currentList.items.reduce(0) { $0 + $1.qty }
    }

    // MARK: - “Find billigst”
    @Published var cheapest: [StoreTotal] = []
    @Published var isFindingCheapest = false
    @Published var errorMessage: String?

    /// Radius for “billigst nær mig” (meter) — gemt til senere udvidelse
    @Published var cheapestRadiusMeters: Double = 2_000

    // MARK: - Lokation
    let locationManager = LocationManager()

    init() {
        // Eksempel: PricingService.shared.apiTokenProvider = { Keychain.read("salling_api_token") ?? "" }
    }

    // MARK: - Søgning
    func runSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { searchResults = []; return }
        searchResults = CatalogService.shared.search(q)
    }

    func defaultVariant(for product: Product) -> ProductVariant {
        product.variants.first ?? ProductVariant(unit: "stk", organic: false, ean: nil)
    }

    func setUnit(for product: Product, unit: String) {
        let baseOrganic = isOrganic[product.id] ?? defaultVariant(for: product).organic
        let temp = ProductVariant(unit: unit, organic: baseOrganic, ean: nil)
        let resolved = ProductVariant(
            unit: unit,
            organic: baseOrganic,
            ean: CatalogService.shared.ean(for: product, variant: temp)
        )
        selectedVariant[product.id] = resolved
    }

    func toggleOrganic(for product: Product, value: Bool) {
        let baseUnit = (selectedVariant[product.id]?.unit) ?? defaultVariant(for: product).unit
        let temp = ProductVariant(unit: baseUnit, organic: value, ean: nil)
        let resolved = ProductVariant(
            unit: baseUnit,
            organic: value,
            ean: CatalogService.shared.ean(for: product, variant: temp)
        )
        selectedVariant[product.id] = resolved
        isOrganic[product.id] = value
    }

    func addToList(product: Product, variant: ProductVariant, qty: Int = 1) {
        let resolvedEAN = CatalogService.shared.ean(for: product, variant: variant)
        let finalVariant = ProductVariant(unit: variant.unit, organic: variant.organic, ean: resolvedEAN)

        if let idx = currentList.items.firstIndex(where: {
            $0.product.id == product.id && $0.variant == finalVariant
        }) {
            currentList.items[idx].qty += qty
        } else {
            currentList.items.append(ShoppingItem(product: product, variant: finalVariant, qty: qty))
        }
    }

    func addToList(product: Product) {
        let v = selectedVariant[product.id] ?? defaultVariant(for: product)
        addToList(product: product, variant: v, qty: 1)
    }

    func changeQty(itemID: UUID, delta: Int) {
        guard let idx = currentList.items.firstIndex(where: { $0.id == itemID }) else { return }
        currentList.items[idx].qty = max(0, currentList.items[idx].qty + delta)
        if currentList.items[idx].qty == 0 {
            currentList.items.remove(at: idx)
        }
    }

    func commitCurrentListToHistory() {
        guard !currentList.items.isEmpty else { return }
        let snapshot = ShoppingList(items: currentList.items, createdAt: Date())
        history.insert(snapshot, at: 0)
        currentList = ShoppingList()
    }

    // MARK: - Find billigst

    func findCheapest(location: CLLocation?) async {
        guard !currentList.items.isEmpty else {
            errorMessage = "Din liste er tom."
            cheapest = []
            return
        }

        isFindingCheapest = true
        errorMessage = nil
        defer { isFindingCheapest = false }

        // 🔧 MATCHER nu PricingService-signaturen uden radius:
        let res = await PricingService.shared.findCheapest(
            list: currentList,
            location: location
        )
        cheapest = res

        if res.isEmpty {
            errorMessage = "Kunne ikke finde priser i nærheden."
        }
    }

    /// Automatisk: find nuværende placering og beregn billigste
    func findCheapestNearby() async {
        locationManager.requestWhenInUse()

        // Vent kort på en frisk lokation ved kold start
        let start = Date()
        while locationManager.lastLocation == nil && Date().timeIntervalSince(start) < 2.5 {
            try? await Task.sleep(nanoseconds: 150_000_000)
        }

        await findCheapest(location: locationManager.lastLocation)
    }
}
