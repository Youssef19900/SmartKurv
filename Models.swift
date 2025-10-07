import Foundation

// MARK: - Produktkatalog

struct Product: Identifiable, Codable, Hashable {
    let id: String            // fx "banana"
    let name: String          // visningsnavn i UI
    var variants: [ProductVariant]  // var, så CatalogService kan indsætte EAN’er
}

struct ProductVariant: Codable, Hashable {
    let unit: String          // "stk", "bundt", "ltr", "kg", "dåse" osv.
    let organic: Bool         // økologisk?
    let ean: String?          // valgfri EAN til Salling API

    /// Vist navn i UI – bruges i Søg-fanen og Indkøbsliste
    var displayName: String {
        organic ? "\(unit.capitalized) • Øko" : unit.capitalized
    }

    /// Nøgle brugt til ean-map.json og slå-op-funktioner
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

// MARK: - Butik / totalpris til UI

/// Samlet pris pr. butik, bruges til "Find billigst i nærheden"
struct StoreTotal: Identifiable, Hashable {
    let id = UUID()
    let storeName: String
    let total: Double
}

/// Butiksmodel (til geo-filter og prisopslag)
struct Store: Identifiable, Codable, Hashable {
    let id: String      // Salling storeId
    let name: String
    let lat: Double
    let lon: Double
}
