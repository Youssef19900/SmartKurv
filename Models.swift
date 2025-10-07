import Foundation

// MARK: - Produktkatalog

struct Product: Identifiable, Codable, Hashable {
    let id: String            // fx "banan"
    let name: String          // visningsnavn
    let variants: [ProductVariant]
}

struct ProductVariant: Codable, Hashable {
    let unit: String          // "stk", "bundt", "ltr", "kg", "dåse" osv.
    let organic: Bool         // økologisk?

    // 👇 Ny: valgfri EAN til Salling API. Hvis nil, kan vi slå det op via egen tabel/regler.
    let ean: String?

    // Praktisk helper til UI (frivillig)
    var displayName: String {
        organic
        ? "\(unit.capitalized) • Øko"
        : "\(unit.capitalized)"
    }

    // Stabil nøgle hvis du vil mappe (product.id + variant) -> EAN i en separat resolver
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

struct StoreTotal: Identifiable, Hashable {
    let id = UUID()
    let storeName: String
    let total: Double
}

// Ny: enkel butiksmodel (bruges til "i nærheden" + storeId til prisopslag)
struct Store: Identifiable, Codable, Hashable {
    let id: String            // Salling storeId
    let name: String
    let lat: Double
    let lon: Double
}
