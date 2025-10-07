import Foundation

final class CatalogService {
    static let shared = CatalogService()
    private var products: [Product] = []
    private var eanMap: [String: String] = [:] // key = "productId|unit|organicFlag(0/1)"

    private init() {
        loadCatalog()
        loadEANMap()
        mergeEANs()
    }

    // MARK: - Public API

    func search(_ raw: String) -> [Product] {
        let q = normalize(raw)
        guard !q.isEmpty else { return [] }
        return products.filter { normalize($0.name).contains(q) }
    }

    func all() -> [Product] { products }

    /// Slår EAN op for et givet produkt+variant (bruger eanMap først, ellers varianten selv)
    func ean(for product: Product, variant: ProductVariant) -> String? {
        let key = "\(product.id)|\(variant.unit)|\(variant.organic ? "1" : "0")"
        return eanMap[key] ?? variant.ean
    }

    // MARK: - Private

    private func loadCatalog() {
        if let url = Bundle.main.url(forResource: "catalog", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                products = try JSONDecoder().decode([Product].self, from: data)
                return
            } catch {
                print("⚠️ Kunne ikke læse catalog.json: \(error)")
            }
        }
        products = fallbackProducts() // hvis der ikke findes en fil
    }

    /// Indlæs en valgfri ean-map.json (key: "productId|unit|organicFlag(0/1)" -> ean)
    private func loadEANMap() {
        if let url = Bundle.main.url(forResource: "ean-map", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            eanMap = decoded
        } else {
            // ikke en fejl – bare info
            // print("ℹ️ ean-map.json ikke fundet – kører videre uden.")
        }
    }

    /// Fletter EAN’er fra eanMap ind i dine produkter, så varianterne får udfyldt ean, hvis muligt.
    private func mergeEANs() {
        guard !eanMap.isEmpty else { return }
        for i in 0..<products.count {
            var p = products[i]
            p.variants = p.variants.map { v in
                let key = "\(p.id)|\(v.unit)|\(v.organic ? "1" : "0")"
                if let mappedEAN = eanMap[key] {
                    // Returnér en kopi med ean udfyldt
                    return ProductVariant(unit: v.unit, organic: v.organic, ean: mappedEAN)
                } else {
                    return v
                }
            }
            products[i] = p
        }
    }

    private func normalize(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
         .lowercased()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func fallbackProducts() -> [Product] {
        // NOTE: Brug rigtige EAN’er, hvis du har dem. Disse er placeholders.
        return [
            Product(
                id: "banana",
                name: "Banan",
                variants: [
                    ProductVariant(unit: "stk",   organic: false, ean: "0000000000001"),
                    ProductVariant(unit: "bundt", organic: false, ean: "0000000000002"),
                    ProductVariant(unit: "stk",   organic: true,  ean: "0000000000003"),
                    ProductVariant(unit: "bundt", organic: true,  ean: "0000000000004")
                ]
            ),
            Product(
                id: "milk-1l",
                name: "Mælk Let 1L",
                variants: [
                    ProductVariant(unit: "ltr", organic: false, ean: "0000000000101"),
                    ProductVariant(unit: "ltr", organic: true,  ean: "0000000000102")
                ]
            )
        ]
    }
}
