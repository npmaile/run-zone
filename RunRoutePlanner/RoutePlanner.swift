import Foundation
import CoreLocation
import MapKit
import Combine

/// Manages dynamic route planning using MapKit Directions API
/// Generates circular routes that follow roads and paths
class RoutePlanner: ObservableObject {
    // MARK: - Published Properties
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var currentWaypoints: [CLLocationCoordinate2D] = []
    @Published var isLoadingRoute = false
    @Published var routeError: String?

    // MARK: - Private Properties
    private var startLocation: CLLocationCoordinate2D?
    private var targetDistance: Double = 0
    private var timer: Timer?
    private var routeTask: Task<Void, Never>?

    // MARK: - Public Methods

    /// Starts planning a circular route from the given location
    /// - Parameters:
    ///   - location: Starting location coordinate
    ///   - targetDistance: Desired total distance in meters
    func startPlanning(from location: CLLocationCoordinate2D, targetDistance: Double) {
        self.startLocation = location
        self.targetDistance = targetDistance

        // Generate initial route
        generateRoute(from: location)

        // Update route periodically
        timer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Routing.routeUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self, let start = self.startLocation else { return }
            self.generateRoute(from: start)
        }
    }

    /// Stops route planning and cancels ongoing tasks
    func stopPlanning() {
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
        isLoadingRoute = false
    }

    /// Resets all route planning state
    func reset() {
        currentRoute = []
        currentWaypoints = []
        startLocation = nil
        targetDistance = 0
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
        isLoadingRoute = false
        routeError = nil
    }

    // MARK: - Private Methods

    private func generateRoute(from location: CLLocationCoordinate2D) {
        routeTask?.cancel()

        routeTask = Task {
            await MainActor.run { isLoadingRoute = true }

            let waypoints = generateWaypoints(center: location, targetDistance: targetDistance)
            await MainActor.run { currentWaypoints = waypoints }

            if let routeCoordinates = await fetchDirectionsRoute(waypoints: waypoints) {
                await updateRoute(routeCoordinates, error: nil)
            } else {
                let fallbackRoute = createGeometricRoute(waypoints: waypoints)
                await updateRoute(fallbackRoute, error: "Using fallback route (no network)")
            }

            await MainActor.run { isLoadingRoute = false }
        }
    }

    @MainActor
    private func updateRoute(_ route: [CLLocationCoordinate2D], error: String?) {
        currentRoute = route
        routeError = error
    }

    /// Generates waypoints in a circular pattern around the center
    private func generateWaypoints(
        center: CLLocationCoordinate2D,
        targetDistance: Double
    ) -> [CLLocationCoordinate2D] {
        let radius = targetDistance / (2 * .pi)
        let radiusInDegrees = radius / AppConstants.Routing.metersPerDegree

        var waypoints: [CLLocationCoordinate2D] = [center]

        for i in 1...AppConstants.Routing.waypointCount {
            let angle = 2 * .pi * Double(i) / Double(AppConstants.Routing.waypointCount)
            let lat = center.latitude + radiusInDegrees * cos(angle)
            let lon = center.longitude + radiusInDegrees * sin(angle) / cos(center.latitude * .pi / 180)
            waypoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        waypoints.append(center)
        return waypoints
    }

    /// Fetches walking directions between waypoints using MapKit
    private func fetchDirectionsRoute(
        waypoints: [CLLocationCoordinate2D]
    ) async -> [CLLocationCoordinate2D]? {
        var allCoordinates: [CLLocationCoordinate2D] = []

        for i in 0..<(waypoints.count - 1) {
            guard !Task.isCancelled else { return nil }

            let source = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i]))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i + 1]))

            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .walking
            request.requestsAlternateRoutes = false

            do {
                let response = try await MKDirections(request: request).calculate()
                guard let route = response.routes.first else { continue }

                let coordinates = extractCoordinates(from: route.polyline)
                allCoordinates.append(contentsOf: coordinates)
            } catch {
                print("Directions request failed: \(error.localizedDescription)")
                return nil
            }
        }

        return allCoordinates.isEmpty ? nil : allCoordinates
    }

    /// Extracts coordinates from an MKPolyline
    private func extractCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let pointCount = polyline.pointCount
        let points = polyline.points()
        return (0..<pointCount).map { points[$0].coordinate }
    }

    /// Creates a fallback geometric route when directions are unavailable
    private func createGeometricRoute(waypoints: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var route: [CLLocationCoordinate2D] = []

        for i in 0..<(waypoints.count - 1) {
            let start = waypoints[i]
            let end = waypoints[i + 1]

            for j in 0...AppConstants.Routing.interpolationPoints {
                let fraction = Double(j) / Double(AppConstants.Routing.interpolationPoints)
                let lat = start.latitude + (end.latitude - start.latitude) * fraction
                let lon = start.longitude + (end.longitude - start.longitude) * fraction
                route.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }

        return route
    }
}
