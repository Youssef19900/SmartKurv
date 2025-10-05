import Foundation

final class CatalogService {
    static let shared = CatalogService()

    private let products: [Product] = [
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
            id: "milk",
            name: "Mælk",
            variants: [
                ProductVariant(unit: "ltr", organic: false),
                ProductVariant(unit: "ltr", organic: true)
            ]
        )
    ]

    func search(_ query: String) -> [Product] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return products.filter { $0.name.lowercased().contains(q) }
    }
}
