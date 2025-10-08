import Foundation

// MARK: - Produktkatalog

struct Product: Identifiable, Codable, Hashable {
    let id: String            // fx "banana"
    let name: String          // visningsnavn
    var variants: [ProductVariant]  // var så CatalogService kan indsætte EAN'er
}

struct ProductVariant: Codable, Hashable {
    let unit: String          // "stk", "bundt", "ltr", "kg", "dåse", ...
    let organic: Bool         // økologisk?
    let ean: String?          // valgfri – bruges til Salling API

    /// Pænt navn til UI
    var displayName: String {
        organic ? "\(unit.capitalized) • Øko" : unit.capitalized
    }

    /// Nøgle der matcher ean-map.json ("productId|unit|0/1")
    func key(productId: String) -> String {
        "\(productId)|\(unit)|\(organic ? "1" : "0")"
    }
}

// MARK: - Indkøbsliste

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

// MARK: - Butikker / totalpris

/// Totalpris til visning i "Find billigst"
struct StoreTotal: Identifiable, Hashable {
    let id = UUID()
    let storeName: String
    let total: Double
}

/// Butik (bruges når du senere henter rigtige butikker + geo)
struct Store: Identifiable, Codable, Hashable {
    let id: String        // Salling storeId
    let name: String
    let lat: Double
    let lon: Double
}
