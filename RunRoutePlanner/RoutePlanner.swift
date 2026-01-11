import Foundation
import CoreLocation
import Combine

class RoutePlanner: ObservableObject {
    @Published var currentRoute: [CLLocationCoordinate2D] = []

    private var startLocation: CLLocationCoordinate2D?
    private var targetDistance: Double = 0
    private var timer: Timer?

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
    }

    func reset() {
        currentRoute = []
        startLocation = nil
        targetDistance = 0
        timer?.invalidate()
        timer = nil
    }

    private func generateRoute(from location: CLLocationCoordinate2D) {
        // Generate a dynamic circular route
        // This creates a route that loops back to the starting point

        let route = createCircularRoute(
            center: location,
            targetDistance: targetDistance,
            segments: 12
        )

        DispatchQueue.main.async {
            self.currentRoute = route
        }
    }

    private func createCircularRoute(
        center: CLLocationCoordinate2D,
        targetDistance: Double,
        segments: Int
    ) -> [CLLocationCoordinate2D] {
        // Calculate radius for circular route
        // Circumference = 2 * π * r, so r = targetDistance / (2 * π)
        let radius = targetDistance / (2 * .pi)

        // Convert radius from meters to degrees (approximate)
        let metersPerDegree = 111320.0 // meters per degree at equator
        let radiusInDegrees = radius / metersPerDegree

        var route: [CLLocationCoordinate2D] = []

        // Create a circular path with some variation for interesting routes
        for i in 0...segments {
            let angle = 2 * .pi * Double(i) / Double(segments)

            // Add some randomness to make the route more interesting
            let variation = 1.0 + Double.random(in: -0.2...0.2)
            let r = radiusInDegrees * variation

            let lat = center.latitude + r * cos(angle)
            let lon = center.longitude + r * sin(angle) / cos(center.latitude * .pi / 180)

            route.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        return route
    }
}
