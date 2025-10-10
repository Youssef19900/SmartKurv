import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    /// Giver nem adgang til den seneste position (eller nil)
    var location: CLLocation? {
        lastLocation
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50  // opdater kun hvis man bevæger sig lidt
    }

    /// Bed brugeren om tilladelse hvis nødvendigt
    func requestWhenInUse() {
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            errorMessage = "Appen har ikke adgang til din placering. Aktivér det i Indstillinger."
        }
    }

    /// Opdatér positionen manuelt (bruges i AppState.findCheapestNearby)
    func refreshLocation() {
        manager.requestLocation()
    }
}

// MARK: - Delegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Placering nægtet. Giv adgang under Indstillinger > Privatliv > Placering."
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        lastLocation = loc
        errorMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error:", error.locali
