import Foundation

// Produktkatalog
struct Product: Identifiable, Codable, Hashable {
    let id: String            // fx "banan"
    let name: String          // visningsnavn
    let variants: [ProductVariant]
}

struct ProductVariant: Codable, Hashable {
    let unit: String          // "stk", "bundt", "ltr", "kg", "dåse" osv.
    let organic: Bool         // økologisk?
}

// Indkøbsliste
struct ShoppingItem: Identifiable, Codable, Hashable {
    let id: UUID
    let product: Product
    let variant: ProductVariant
    var qty: Int

    init(id: UUID = UUID(), product: Product, variant: ProductVariant, qty: Int = 1) {
        self.id = id
        self.product = product
        self.variant = variant
        self.qty = qty
    }
}

struct ShoppingList: Identifiable, Codable, Hashable {
    let id: UUID
    var items: [ShoppingItem]
    let createdAt: Date

    init(id: UUID = UUID(), items: [ShoppingItem] = [], createdAt: Date = .init()) {
        self.id = id
        self.items = items
        self.createdAt = createdAt
    }
}

// Prisresultat pr. butik (bruges i UI'et)
struct StoreTotal: Identifiable, Hashable {
    let id = UUID()
    let storeName: String
    let total: Double
}
