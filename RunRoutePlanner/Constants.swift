import Foundation
import CoreLocation
import SwiftUI
import UIKit

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

    // MARK: - Pace Tracking
    enum Pace {
        // Time goals
        static let minTimeMinutes = 5.0 // minimum time goal in minutes
        static let maxTimeMinutes = 300.0 // maximum time goal in minutes (5 hours)
        static let defaultTimeMinutes = 30.0 // default time goal in minutes
        static let timeStepMinutes = 5.0 // increment/decrement step for time

        // Pace calculation
        static let paceUpdateInterval: TimeInterval = 10.0 // how often to recalculate pace
        static let minDistanceForPace = 100.0 // meters - minimum distance before calculating pace

        // Pace coaching thresholds
        static let paceTolerancePercent = 0.10 // 10% tolerance before coaching
        static let paceCheckInterval: TimeInterval = 60.0 // check pace every minute
        static let minTimeBetweenCoaching: TimeInterval = 120.0 // wait 2 minutes between coaching messages

        // Pace status thresholds (percentage difference from target)
        static let slightlySlowThreshold = 0.05 // 5% slower
        static let moderatelySlowThreshold = 0.15 // 15% slower
        static let slightlyFastThreshold = 0.05 // 5% faster
        static let moderatelyFastThreshold = 0.15 // 15% faster
    }
}
// MARK: - App Color Scheme

extension Color {
    // MARK: - Background Colors
    
    /// Main background color
    static var appBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
                : UIColor.systemBackground
        })
    }
    
    /// Secondary background for cards and panels
    static var appCardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
                : UIColor.secondarySystemBackground
        })
    }
    
    /// Elevated card background (for overlays)
    static var appElevatedBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.15, green: 0.15, blue: 0.22, alpha: 0.95)
                : UIColor.systemBackground.withAlphaComponent(0.95)
        })
    }
    
    // MARK: - Text Colors
    
    /// Primary text color
    static var appTextPrimary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
                : UIColor.label
        })
    }
    
    /// Secondary text color
    static var appTextSecondary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.70, green: 0.70, blue: 0.75, alpha: 1.0)
                : UIColor.secondaryLabel
        })
    }
    
    // MARK: - Accent Colors
    
    /// Success/positive color
    static var appSuccess: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
                : UIColor.systemGreen
        })
    }
    
    /// Warning color
    static var appWarning: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1.0)
                : UIColor.systemOrange
        })
    }
    
    /// Error/danger color
    static var appDanger: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0)
                : UIColor.systemRed
        })
    }
    
    /// Info color
    static var appInfo: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)
                : UIColor.systemBlue
        })
    }
    
    // MARK: - Running Specific Colors
    
    static var paceOnTrack: Color { appSuccess }
    static var paceSlightlyOff: Color { appWarning }
    static var paceFarOff: Color { appDanger }
    static var plannedRoute: Color { appInfo }
    static var completedPath: Color { appSuccess }
    
    // MARK: - Shadow Colors
    
    static var appShadow: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.6)
                : UIColor.black.withAlphaComponent(0.15)
        })
    }
}

// MARK: - Gradient Styles

extension LinearGradient {
    static var appPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appInfo, Color.blue.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var appSuccessGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appSuccess, Color.green.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var appDangerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appDanger, Color.red.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

