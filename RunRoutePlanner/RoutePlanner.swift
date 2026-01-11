import Foundation
import CoreLocation
import MapKit
import Combine

class RoutePlanner: ObservableObject {
    @Published var currentRoute: [CLLocationCoordinate2D] = []

    private var startLocation: CLLocationCoordinate2D?
    private var targetDistance: Double = 0
    private var timer: Timer?
    private var routeTask: Task<Void, Never>?

    func startPlanning(from location: CLLocationCoordinate2D, targetDistance: Double) {
        self.startLocation = location
        self.targetDistance = targetDistance

        // Generate initial route
        generateRoute(from: location)

        // Update route periodically (every 30 seconds while running)
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startLocation else { return }
            self.generateRoute(from: start)
        }
    }

    func stopPlanning() {
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
    }

    func reset() {
        currentRoute = []
        startLocation = nil
        targetDistance = 0
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
    }

    private func generateRoute(from location: CLLocationCoordinate2D) {
        // Cancel any existing route generation
        routeTask?.cancel()

        routeTask = Task {
            // Generate waypoints in a circular pattern
            let waypoints = generateWaypoints(center: location, targetDistance: targetDistance)

            // Try to get directions that follow roads
            if let routeCoordinates = await fetchDirectionsRoute(waypoints: waypoints) {
                await MainActor.run {
                    self.currentRoute = routeCoordinates
                }
            } else {
                // Fallback to geometric route if directions fail
                let fallbackRoute = createGeometricRoute(waypoints: waypoints)
                await MainActor.run {
                    self.currentRoute = fallbackRoute
                }
            }
        }
    }

    private func generateWaypoints(center: CLLocationCoordinate2D, targetDistance: Double) -> [CLLocationCoordinate2D] {
        // Use fewer waypoints for better routing results
        let waypointCount = 4
        let radius = targetDistance / (2 * .pi)
        let metersPerDegree = 111320.0
        let radiusInDegrees = radius / metersPerDegree

        var waypoints: [CLLocationCoordinate2D] = [center]

        for i in 1...waypointCount {
            let angle = 2 * .pi * Double(i) / Double(waypointCount)
            let lat = center.latitude + radiusInDegrees * cos(angle)
            let lon = center.longitude + radiusInDegrees * sin(angle) / cos(center.latitude * .pi / 180)
            waypoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        // Close the loop back to start
        waypoints.append(center)

        return waypoints
    }

    private func fetchDirectionsRoute(waypoints: [CLLocationCoordinate2D]) async -> [CLLocationCoordinate2D]? {
        var allCoordinates: [CLLocationCoordinate2D] = []

        // Request directions between each pair of waypoints
        for i in 0..<(waypoints.count - 1) {
            let source = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i]))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i + 1]))

            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .walking
            request.requestsAlternateRoutes = false

            let directions = MKDirections(request: request)

            do {
                let response = try await directions.calculate()

                guard let route = response.routes.first else { continue }

                // Extract coordinates from the route polyline
                let pointCount = route.polyline.pointCount
                let coordinates = route.polyline.points()
                let coordArray = (0..<pointCount).map { index in
                    coordinates[index].coordinate
                }

                allCoordinates.append(contentsOf: coordArray)
            } catch {
                // If any segment fails, return nil to use fallback
                print("Directions request failed: \(error.localizedDescription)")
                return nil
            }
        }

        return allCoordinates.isEmpty ? nil : allCoordinates
    }

    private func createGeometricRoute(waypoints: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        // Simple fallback: just connect waypoints with straight lines
        // with some interpolation for smoother curves
        var route: [CLLocationCoordinate2D] = []

        for i in 0..<(waypoints.count - 1) {
            let start = waypoints[i]
            let end = waypoints[i + 1]

            // Interpolate 10 points between each waypoint pair
            for j in 0...10 {
                let fraction = Double(j) / 10.0
                let lat = start.latitude + (end.latitude - start.latitude) * fraction
                let lon = start.longitude + (end.longitude - start.longitude) * fraction
                route.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }

        return route
    }
}
