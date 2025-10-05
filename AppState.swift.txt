import Foundation
import CoreLocation

@MainActor
final class AppState: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [Product] = []
    @Published var selectedVariant: [String: ProductVariant] = [:]
    @Published var isOrganic: [String: Bool] = [:]

    @Published var currentList = ShoppingList()
    @Published var history: [ShoppingList] = []
    @Published var locationManager = LocationManager()

    func performSearch() {
        searchResults = CatalogService.shared.search(searchQuery)
    }

    func defaultVariant(for product: Product) -> ProductVariant {
        return product.variants.first ?? ProductVariant(unit: "stk", organic: false)
    }

    func toggleOrganic(for product: Product, value: Bool) {
        isOrganic[product.id] = value
        if let current = selectedVariant[product.id] {
            let new = ProductVariant(unit: current.unit, organic: value)
            if product.variants.contains(new) {
                selectedVariant[product.id] = new
                return
            }
        }
        if let first = product.variants.first(where: { $0.organic == value }) {
            selectedVariant[product.id] = first
        }
    }

    func setUnit(for product: Product, unit: String) {
        let eco = isOrganic[product.id] ?? false
        let candidate = ProductVariant(unit: unit, organic: eco)
        if product.variants.contains(candidate) {
            selectedVariant[product.id] = candidate
        } else if let any = product.variants.first(where: { $0.unit == unit }) {
            selectedVariant[product.id] = any
            isOrganic[product.id] = any.organic
        }
    }

    func addToList(product: Product) {
        let variant = selectedVariant[product.id] ?? defaultVariant(for: product)
        if let idx = currentList.items.firstIndex(where: {
            $0.product.id == product.id && $0.variant == variant
        }) {
            currentList.items[idx].qty += 1
        } else {
            currentList.items.append(ListItem(product: product, variant: variant, qty: 1))
        }
    }

    func changeQty(itemID: UUID, delta: Int) {
        guard let i = currentList.items.firstIndex(where: { $0.id == itemID }) else { return }
        currentList.items[i].qty = max(0, currentList.items[i].qty + delta)
        if currentList.items[i].qty == 0 {
            currentList.items.remove(at: i)
        }
    }

    func commitCurrentListToHistory() {
        guard !currentList.items.isEmpty else { return }
        history.insert(currentList, at: 0)
        currentList = ShoppingList()
    }
}
