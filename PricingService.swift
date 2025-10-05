import Foundation
import CoreLocation

struct StoreTotal: Identifiable {
    let id = UUID()
    let storeName: String
    let total: Double
}

final class PricingService {
    static let shared = PricingService()

    private func basePrice(for product: Product, variant: ProductVariant) -> Double {
        switch product.id {
        case "banana":
            if variant.organic && variant.unit == "bundt" { return 22 }
            if variant.organic && variant.unit == "stk"   { return 5.5 }
            if !variant.organic && variant.unit == "bundt"{ return 18 }
            return 4.0
        case "milk":
            return variant.organic ? 12.0 : 9.0
        default:
            return 10.0
        }
    }

    func findCheapest(list: ShoppingList, location: CLLocation?) async -> [StoreTotal] {
        let stores = ["Butik A", "Butik B", "Butik C"]

        func factor(_ name: String) -> Double {
            switch name {
            case "Butik A": return 1.00
            case "Butik B": return 0.95
            case "Butik C": return 1.08
            default:        return 1.00
            }
        }

        var totals: [StoreTotal] = []
        for s in stores {
            let f = factor(s)
            var sum = 0.0
            for it in list.items {
                sum += basePrice(for: it.product, variant: it.variant) * Double(it.qty) * f
            }
            totals.append(StoreTotal(storeName: s, total: (sum * 100).rounded() / 100))
        }
        totals.sort { $0.total < $1.total }
        return Array(totals.prefix(2))
    }
}
