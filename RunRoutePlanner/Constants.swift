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

    // MARK: - Navigation
    enum Navigation {
        // Distance thresholds
        static let waypointReachedThreshold = 20.0 // meters - when to advance to next waypoint
        static let instructionDistance = 50.0 // meters - when to give turn instruction
        static let instructionRepeatThreshold = 30.0 // meters - minimum distance change to repeat instruction

        // Turn angle thresholds (in degrees)
        static let straightAngleThreshold = 20.0 // consider it straight if within this angle
        static let slightTurnThreshold = 45.0 // slight turn threshold
        static let sharpTurnThreshold = 120.0 // sharp turn threshold
        static let uTurnAngleThreshold = 30.0 // degrees from 180 to consider it a U-turn

        // Speech settings
        static let speechRate: Float = 0.5 // 0.0 (slow) to 1.0 (fast)
        static let speechVolume: Float = 1.0 // 0.0 to 1.0
    }
}
