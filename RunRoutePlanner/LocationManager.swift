import Foundation
import CoreLocation
import Combine

/// Manages GPS location tracking and distance calculation for running
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published Properties
    @Published var location: CLLocationCoordinate2D?
    @Published var totalDistance: Double = 0
    @Published var runPath: [CLLocationCoordinate2D] = []
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: String?

    // MARK: - Private Properties
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    // MARK: - Initialization

    override init() {
        super.init()
        configureLocationManager()
    }

    // MARK: - Public Methods

    /// Requests location permission from the user
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Starts tracking the user's location and recording the running path
    func startTracking() {
        manager.startUpdatingLocation()
        reset()
    }

    /// Stops tracking the user's location
    func stopTracking() {
        manager.stopUpdatingLocation()
    }

    /// Resets all tracking data
    func reset() {
        runPath = []
        totalDistance = 0
        lastLocation = nil
        locationError = nil
    }

    // MARK: - Private Methods

    private func configureLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = AppConstants.Location.distanceFilter
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            locationError = nil
        case .denied, .restricted:
            locationError = "Location access denied. Please enable in Settings."
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            locationError = "Unknown authorization status"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Validate location accuracy
        guard newLocation.horizontalAccuracy >= 0 else {
            return // Invalid location
        }

        // Update current location
        location = newLocation.coordinate

        // Add to path
        runPath.append(newLocation.coordinate)

        // Calculate distance with GPS error filtering
        if let last = lastLocation {
            let distance = newLocation.distance(from: last)

            // Filter out unrealistic jumps due to GPS errors
            if distance < AppConstants.Location.maxRealisticJump {
                totalDistance += distance
            }
        }

        lastLocation = newLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorMessage = "Location error: \(error.localizedDescription)"
        print(errorMessage)
        locationError = errorMessage
    }
}
