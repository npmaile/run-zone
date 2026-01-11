import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var totalDistance: Double = 0
    @Published var runPath: [CLLocationCoordinate2D] = []
    @Published var authorizationStatus: CLAuthorizationStatus?

    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 10 // Update every 10 meters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        manager.startUpdatingLocation()
        runPath = []
        totalDistance = 0
        lastLocation = nil
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
    }

    func reset() {
        runPath = []
        totalDistance = 0
        lastLocation = nil
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Update current location
        location = newLocation.coordinate

        // Add to path
        runPath.append(newLocation.coordinate)

        // Calculate distance
        if let last = lastLocation {
            let distance = newLocation.distance(from: last)
            // Filter out unrealistic jumps (e.g., GPS errors)
            if distance < 100 {
                totalDistance += distance
            }
        }

        lastLocation = newLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
