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
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentPace: Double = 0 // minutes per kilometer

    // MARK: - Private Properties
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var startTime: Date?
    private var paceTimer: Timer?

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
        startTime = Date()

        // Start timer to update elapsed time
        paceTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Pace.paceUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updatePaceMetrics()
        }
    }

    /// Stops tracking the user's location
    func stopTracking() {
        manager.stopUpdatingLocation()
        paceTimer?.invalidate()
        paceTimer = nil
    }

    /// Resets all tracking data
    func reset() {
        runPath = []
        totalDistance = 0
        lastLocation = nil
        locationError = nil
        elapsedTime = 0
        currentPace = 0
        startTime = nil
        paceTimer?.invalidate()
        paceTimer = nil
    }

    // MARK: - Private Methods

    private func configureLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = AppConstants.Location.distanceFilter
    }

    /// Updates pace metrics (elapsed time and current pace)
    private func updatePaceMetrics() {
        guard let start = startTime else { return }

        // Update elapsed time
        elapsedTime = Date().timeIntervalSince(start)

        // Calculate current pace (min/km)
        // Only calculate if we've covered minimum distance
        if totalDistance >= AppConstants.Pace.minDistanceForPace {
            let distanceKm = totalDistance / 1000.0
            let timeMinutes = elapsedTime / 60.0
            currentPace = timeMinutes / distanceKm
        } else {
            currentPace = 0
        }
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
