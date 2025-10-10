import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    /// Seneste kendte lokation (bekvemmelig alias)
    var location: CLLocation? { lastLocation }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    /// Bed om adgang og/eller hent en enkelt lokation, hvis muligt
    func requestWhenInUse() {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation() // one-shot
        case .denied, .restricted:
            errorMessage = "Appen har ikke adgang til din placering. Aktivér det i Indstillinger."
        @unknown default:
            break
        }
    }

    /// Manuelt refresh (one-shot)
    func refreshLocation() {
        manager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate (nonisolated for Swift 6)
extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let auth = manager.authorizationStatus
        Task { @MainActor in
            self.status = auth
            switch auth {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
                self.errorMessage = nil
            case .denied, .restricted:
                self.errorMessage = "Placering nægtet. Giv adgang i Indstillinger > Privatliv > Placering."
            case .notDetermined:
                break
            @unknown default:
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
        let msg = error.localizedDescription
        print("📍 Location error:", msg)
        Task { @MainActor in
            self.errorMessage = "Kunne ikke finde din placering: \(msg)"
        }
    }
}