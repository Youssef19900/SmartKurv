import Foundation

final class CatalogService {
    static let shared = CatalogService()
    private var products: [Product] = []

    init() {
        loadFromBundle()
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json") else {
            print("⚠️ catalog.json ikke fundet i bundlen – bruger fallback.")
            products = fallbackProducts()
            return
        }
        do {
            let data = try Data(contentsOf: url)
            products = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print("⚠️ Kunne ikke læse catalog.json: \(error)")
            products = fallbackProducts()
        }
    }

    private func fallbackProducts() -> [Product] {
        // Minimal backup, hvis json mangler – to klassikere
        return [
            Product(
                id: "banana",
                name: "Banan",
                variants: [
                    ProductVariant(unit: "stk", organic: false),
                    ProductVariant(unit: "bundt", organic: false),
                    ProductVariant(unit: "stk", organic: true),
                    ProductVariant(unit: "bundt", organic: true)
                ]
            ),
            Product(
                id: "milk-1l",
                name: "Mælk Let 1L",
                variants: [
                    ProductVariant(unit: "ltr", organic: false),
                    ProductVariant(unit: "ltr", organic: true)
                ]
            )
        ]
    }

    func search(_ query: String) -> [Product] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return products.filter { $0.name.lowercased().contains(q) }
    }

    func all() -> [Product] { products }
}
