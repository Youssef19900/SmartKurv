import Foundation

final class CatalogService {
    static let shared = CatalogService()
    private var products: [Product] = []

    private init() {
        loadFromBundle()
    }

    // MARK: - Public API

    func search(_ raw: String) -> [Product] {
        let q = normalize(raw)
        guard !q.isEmpty else { return [] }
        return products.filter { normalize($0.name).contains(q) }
    }

    func all() -> [Product] { products }

    // MARK: - Private

    private func loadFromBundle() {
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

    private func normalize(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
         .lowercased()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func fallbackProducts() -> [Product] {
        // NOTE: Brug rigtige EAN’er, hvis du har dem. Disse er eksempler/placeholder.
        return [
            Product(
                id: "banana",
                name: "Banan",
                variants: [
                    ProductVariant(unit: "stk",   organic: false, ean: "0000000000001", displayName: "Banan (stk)"),
                    ProductVariant(unit: "bundt", organic: false, ean: "0000000000002", displayName: "Banan (bundt)"),
                    ProductVariant(unit: "stk",   organic: true,  ean: "0000000000003", displayName: "Banan Øko (stk)"),
                    ProductVariant(unit: "bundt", organic: true,  ean: "0000000000004", displayName: "Banan Øko (bundt)")
                ]
            ),
            Product(
                id: "milk-1l",
                name: "Mælk Let 1L",
                variants: [
                    ProductVariant(unit: "ltr", organic: false, ean: "0000000000101", displayName: "Letmælk 1L"),
                    ProductVariant(unit: "ltr", organic: true,  ean: "0000000000102", displayName: "Letmælk Øko 1L")
                ]
            )
        ]
    }
}
