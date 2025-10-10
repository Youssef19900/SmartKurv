import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    var location: CLLocation? { lastLocation }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    func requestWhenInUse() {
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            errorMessage = "Appen har ikke adgang til din placering. Aktivér det i Indstillinger."
        }
    }

    func refreshLocation() {
        manager.requestLocation()
    }
}

// MARK: - Delegate (nonisolated for Swift 6-compat)
extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let auth = manager.authorizationStatus
        Task { @MainActor in
            self.status = auth
            switch auth {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                self.errorMessage = "Placering nægtet. Giv adgang i Indstillinger > Privatliv > Placering."
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let loc = locations.last {
                self.lastLocation = loc
                self.errorMessage = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // <- her var stavefejlen
        let msg = error.localizedDescription
        print("📍 Location error:", msg)
        Task { @MainActor in
            self.errorMessage = "Kunne ikke finde din placering: \(msg)"
        }
    }
}
