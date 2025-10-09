import Foundation
import CoreLocation
import Combine

@MainActor
final class AppState: ObservableObject {

    // MARK: - Søg
    @Published var query: String = ""                  // bruges i Views/Search
    @Published var searchResults: [Product] = []

    // Beholdt til UI der vælger enhed/øko pr. produkt
    @Published var selectedVariant: [String: ProductVariant] = [:]
    @Published var isOrganic: [String: Bool] = [:]

    // MARK: - Indkøbsliste + historik
    @Published var currentList: ShoppingList = ShoppingList()
    @Published var history: [ShoppingList] = []

    // Badge i UI (antal stk. i kurven)
    var cartItemCount: Int {
        currentList.items.reduce(0) { $0 + $1.qty }
    }

    // MARK: - “Find billigst”
    @Published var cheapest: [StoreTotal] = []
    @Published var isFindingCheapest = false
    @Published var errorMessage: String?

    // MARK: - Lokation
    let locationManager = LocationManager()

    // MARK: - Søgning
    func runSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { searchResults = []; return }
        searchResults = CatalogService.shared.search(q)
    }

    // Default-variant hvis brugeren ikke har valgt
    func defaultVariant(for product: Product) -> ProductVariant {
        product.variants.first ?? ProductVariant(unit: "stk", organic: false, ean: nil)
    }

    // Brugeren ændrer enhed (hvis UI’et har enhedsvælger)
    func setUnit(for product: Product, unit: String) {
        let baseOrganic = isOrganic[product.id] ?? defaultVariant(for: product).organic
        let temp = ProductVariant(unit: unit, organic: baseOrganic, ean: nil)
        let resolved = ProductVariant(
            unit: unit,
            organic: baseOrganic,
            ean: CatalogService.shared.ean(for: product, variant: temp)
        )
        selectedVariant[product.id] = resolved
    }

    // Brugeren toggler øko (hvis UI’et har øko-toggle)
    func toggleOrganic(for product: Product, value: Bool) {
        let baseUnit = (selectedVariant[product.id]?.unit) ?? defaultVariant(for: product).unit
        let temp = ProductVariant(unit: baseUnit, organic: value, ean: nil)
        let resolved = ProductVariant(
            unit: baseUnit,
            organic: value,
            ean: CatalogService.shared.ean(for: product, variant: temp)
        )
        selectedVariant[product.id] = resolved
        isOrganic[product.id] = value
    }

    // MARK: - Læg i kurven (primær – bruges når variant er kendt)
    func addToList(product: Product, variant: ProductVariant, qty: Int = 1) {
        // Sørg for EAN hvis muligt (fra ean-map eller varianten selv)
        let resolvedEAN = CatalogService.shared.ean(for: product, variant: variant)
        let finalVariant = ProductVariant(unit: variant.unit, organic: variant.organic, ean: resolvedEAN)

        if let idx = currentList.items.firstIndex(where: {
            $0.product.id == product.id && $0.variant == finalVariant
        }) {
            currentList.items[idx].qty += qty
        } else {
            currentList.items.append(ShoppingItem(product: product, variant: finalVariant, qty: qty))
        }
    }

    // Bekvemmelighed: tillad gamle kald uden variant
    func addToList(product: Product) {
        let v = selectedVariant[product.id] ?? defaultVariant(for: product)
        addToList(product: product, variant: v, qty: 1)
    }

    // Ændr antal (+/-)
    func changeQty(itemID: UUID, delta: Int) {
        guard let idx = currentList.items.firstIndex(where: { $0.id == itemID }) else { return }
        currentList.items[idx].qty = max(0, currentList.items[idx].qty + delta)
        if currentList.items[idx].qty == 0 {
            currentList.items.remove(at: idx)
        }
    }

    // Gem som handlet → historik
    func commitCurrentListToHistory() {
        guard !currentList.items.isEmpty else { return }
        let snapshot = ShoppingList(items: currentList.items, createdAt: Date())
        history.insert(snapshot, at: 0)
        currentList = ShoppingList()
    }

    // MARK: - Find billigst
    func findCheapest(location: CLLocation?) async {
        isFindingCheapest = true
        errorMessage = nil
        defer { isFindingCheapest = false }
        let res = await PricingService.shared.findCheapest(list: currentList, location: location)
        cheapest = res
    }
}
