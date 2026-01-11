import Foundation
import CoreLocation

enum AppConstants {
    // MARK: - Routing
    enum Routing {
        static let waypointCount = 4
        static let routeUpdateInterval: TimeInterval = 30
        static let interpolationPoints = 10
        static let metersPerDegree = 111320.0
        static let minDistance = 1.0 // km
        static let maxDistance = 50.0 // km
        static let defaultDistance = 5.0 // km
    }

    // MARK: - Location
    enum Location {
        static let distanceFilter = 10.0 // meters
        static let maxRealisticJump = 100.0 // meters
        static let mapZoomMeters = 1000.0
    }

    // MARK: - UI
    enum UI {
        static let horizontalPadding: CGFloat = 40
        static let cornerRadius: CGFloat = 15
        static let statsCornerRadius: CGFloat = 15
        static let controlsCornerRadius: CGFloat = 20

        // Map overlay styling
        static let completedPathWidth: CGFloat = 6
        static let completedPathAlpha: CGFloat = 0.8
        static let plannedRouteWidth: CGFloat = 4
        static let plannedRouteAlpha: CGFloat = 0.6
        static let plannedRouteDashPattern: [NSNumber] = [10, 5]

        // Timing
        static let paywallDelay: TimeInterval = 1.0
        static let resetDelay: TimeInterval = 1.0
    }

    // MARK: - Subscription
    enum Subscription {
        static let productID = "com.runrouteplanner.monthly_subscription"
    }
}
