import SwiftUI

// MARK: - App Color Scheme

extension Color {
    // MARK: - Background Colors
    
    /// Main background color
    static var appBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0) // Dark blue-gray
                : UIColor.systemBackground
        })
    }
    
    /// Secondary background for cards and panels
    static var appCardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0) // Lighter blue-gray
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
                ? UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0) // Brighter green for dark mode
                : UIColor.systemGreen
        })
    }
    
    /// Warning color
    static var appWarning: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1.0) // Brighter orange
                : UIColor.systemOrange
        })
    }
    
    /// Error/danger color
    static var appDanger: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0) // Brighter red
                : UIColor.systemRed
        })
    }
    
    /// Info color
    static var appInfo: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) // Brighter blue
                : UIColor.systemBlue
        })
    }
    
    // MARK: - Running Specific Colors
    
    /// Color for pace status - on track
    static var paceOnTrack: Color {
        appSuccess
    }
    
    /// Color for pace status - slightly off
    static var paceSlightlyOff: Color {
        appWarning
    }
    
    /// Color for pace status - significantly off
    static var paceFarOff: Color {
        appDanger
    }
    
    /// Color for planned route on map
    static var plannedRoute: Color {
        appInfo
    }
    
    /// Color for completed path on map
    static var completedPath: Color {
        appSuccess
    }
    
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
    /// Primary gradient for buttons and highlights
    static var appPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appInfo, Color.blue.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Success gradient
    static var appSuccessGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appSuccess, Color.green.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Danger gradient
    static var appDangerGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appDanger, Color.red.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
