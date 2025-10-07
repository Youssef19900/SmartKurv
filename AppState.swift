import Foundation
import CoreLocation
import Combine

@MainActor
final class AppState: ObservableObject {

    // Søg
    @Published var searchQuery: String = ""
    @Published var searchResults: [Product] = []

    // Valgte varianter pr. produkt-id
    @Published var selectedVariant: [String: ProductVariant] = [:]
    @Published var isOrganic: [String: Bool] = [:]

    // Indkøbsliste + historik
    @Published var currentList: ShoppingList = ShoppingList()
    @Published var history: [ShoppingList] = []

    // Lokation
    let locationManager = LocationManager()

    // MARK: - Søgning

    func performSearch() {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            searchResults = []
            return
        }
        searchResults = CatalogService.shared.search(q)
    }

    // Default-variant hvis brugeren ikke har valgt
    func defaultVariant(for product: Product) -> ProductVariant {
        product.variants.first ?? ProductVariant(unit: "stk", organic: false, ean: nil)
    }

    // Brugeren ændrer enhed
    func setUnit(for product: Product, unit: String) {
        let baseOrganic = isOrganic[product.id] ?? defaultVariant(for: product).organic
        let v = ProductVariant(unit: unit, organic: baseOrganic, ean: nil)
        selectedVariant[product.id] = v
    }

    // Brugeren toggler øko
    func toggleOrganic(for product: Product, value: Bool) {
        let baseUnit = (selectedVariant[product.id]?.unit) ?? defaultVariant(for: product).unit
        let v = ProductVariant(unit: baseUnit, organic: value, ean: nil)
        selectedVariant[product.id] = v
        isOrganic[product.id] = value
    }

    // Læg i kurv
    func addToList(product: Product) {
        let variant = selectedVariant[product.id] ?? defaultVariant(for: product)
        if let idx = currentList.items.firstIndex(where: { $0.product.id == product.id && $0.variant == variant }) {
            currentList.items[idx].qty += 1
        } else {
            currentList.items.append(ShoppingItem(product: product, variant: variant, qty: 1))
        }
    }

    // Ændr antal
    func changeQty(itemID: UUID, delta: Int) {
        guard let idx = currentList.items.firstIndex(where: { $0.id == itemID }) else { return }
        currentList.items[idx].qty = max(0, currentList.items[idx].qty + delta)
        if currentList.items[idx].qty == 0 {
            currentList.items.remove(at: idx)
        }
    }

    // Gem som handlet
    func commitCurrentListToHistory() {
        guard !currentList.items.isEmpty else { return }
        history.insert(currentList, at: 0)
        currentList = ShoppingList()
    }
}
