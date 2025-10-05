import Foundation
import CoreLocation

/// Finder totalpriser for en indkøbsliste i nærliggende butikker.
/// I denne demo bruges simple "basispriser" + en kæde-faktor (Netto/Føtex).
final class PricingService {
    static let shared = PricingService()
    private init() {}

    // MARK: - Offentlig API

    /// Returnerer de to billigste butikker for den givne liste.
    /// - Parameters:
    ///   - list: Brugerens indkøbsliste
    ///   - location: Sidste kendte lokation (ikke brugt i denne simple mock, men sendt med for fremtidig geofiltering)
    func findCheapest(list: ShoppingList, location: CLLocation?) async -> [StoreTotal] {
        // De kæder du bad om
        let stores = ["Netto", "Føtex"]

        // Evt. lette prisniveau-forskelle mellem kæder (kan justeres frit)
        func factor(for store: String) -> Double {
            switch store {
            case "Netto": return 0.96   // Netto er ofte lidt billigere i snit
            case "Føtex": return 1.00
            default:      return 1.00
            }
        }

        var totals: [StoreTotal] = []
        for s in stores {
            let f = factor(for: s)
            var sum = 0.0

            for it in list.items {
                let base = basePrice(for: it.product, variant: it.variant)
                sum += base * Double(it.qty) * f
            }

            // afrund til 2 decimaler på en pæn måde
            let rounded = (sum * 100).rounded() / 100
            totals.append(StoreTotal(storeName: s, total: rounded))
        }

        // Billigste først og returnér max 2
        return totals.sorted { $0.total < $1.total }.prefix(2).map { $0 }
    }

    // MARK: - Basispriser (mock)

    /// Simpelt "prisleksikon" til demo. Når du senere kobler rigtige priser på,
    /// bliver denne funktion erstattet af web/API-opslag.
    private func basePrice(for product: Product, variant: ProductVariant) -> Double {
        switch product.id {

        // FRUGT & GRØNT
        case "banan":
            // stk/bundt + øko/konv.
            if variant.unit == "bundt" { return variant.organic ? 24.0 : 20.0 }
            return variant.organic ? 5.5 : 4.0      // stk
        case "apple-red":
            return variant.unit == "kg" ? (variant.organic ? 26.0 : 22.0) : (variant.organic ? 4.5 : 3.5)
        case "pear":
            return variant.unit == "kg" ? (variant.organic ? 28.0 : 24.0) : (variant.organic ? 5.0 : 4.0)
        case "cucumber":
            return variant.organic ? 14.0 : 10.0
        case "tomato":
            if variant.unit == "kg" { return variant.organic ? 36.0 : 30.0 }
            return variant.organic ? 18.0 : 15.0     // bakke
        case "iceberg":
            return variant.organic ? 18.0 : 15.0
        case "potato":
            if variant.unit == "kg" { return variant.organic ? 16.0 : 12.0 }
            return variant.organic ? 26.0 : 20.0     // pose
        case "carrot":
            if variant.unit == "kg" { return variant.organic ? 16.0 : 12.0 }
            return variant.organic ? 18.0 : 14.0     // pose
        case "onion-yellow":
            if variant.unit == "kg" { return 10.0 }
            return 12.0                               // pose

        // MEJERI / BAGERI
        case "milk-1l":
            return variant.organic ? 12.0 : 9.0       // 1 liter letmælk
        case "milk-skim-1l":
            return variant.organic ? 12.0 : 9.0
        case "yoghurt-1l":
            return variant.organic ? 18.0 : 15.0
        case "butter-200g":
            return variant.organic ? 24.0 : 20.0
        case "cheese-slice-400g":
            return variant.organic ? 40.0 : 32.0
        case "eggs-10":
            return variant.organic ? 36.0 : 28.0
        case "rye-bread-1kg":
            return variant.organic ? 24.0 : 18.0
        case "white-bread-600g":
            return 16.0

        // KOLONIAL
        case "pasta-penne-500g":
            return 12.0
        case "spaghetti-500g":
            return 12.0
        case "rice-jasmine-1kg":
            return 20.0
        case "tuna-185g":
            return 14.0
        case "tomato-chopped-400g":
            return 8.0
        case "baked-beans-415g":
            return 10.0
        case "corn-340g":
            return 10.0
        case "chickpeas-400g":
            return 9.0
        case "coffee-400g":
            return 40.0
        case "sugar-1kg":
            return 11.0

        // DRIKKEVARER
        case "cola-330":
            switch variant.unit {
            case "24-pak": return 120.0
            case "6-pak":  return 36.0
            default:       return 6.0  // stk
            }
        case "pepsi-max-330":
            switch variant.unit {
            case "24-pak": return 110.0
            case "6-pak":  return 34.0
            default:       return 5.5
            }
        case "water-still-1_5l":
            return variant.unit == "6-pak" ? 36.0 : 7.0

        // Fallback hvis en vare mangler i tabellen
        default:
            return 10.0
        }
    }
}
