import Foundation

// MARK: - Route Details Model

struct RouteDetails {
    // Distance and turns
    let numberOfTurns: Int
    let rightTurns: Int
    let leftTurns: Int
    let sharpTurns: Int
    
    // Elevation
    let elevationProfile: [ElevationPoint]
    let totalElevationGain: Double
    let totalElevationLoss: Double
    let maxElevation: Double
    let minElevation: Double
    let averageGrade: Double
    let maxGrade: Double
    
    // Surface types
    let roadPercentage: Double
    let trailPercentage: Double
    let unknownPercentage: Double
    
    // Difficulty
    let difficulty: RouteDifficulty
    
    // Estimated time (based on 6 min/km base pace + adjustments)
    let estimatedTime: TimeInterval
}

// MARK: - Elevation Point

struct ElevationPoint: Identifiable {
    let id = UUID()
    let distance: Double // km
    let elevation: Double // meters
}

// MARK: - Route Difficulty

enum RouteDifficulty: String {
    case easy = "Easy"
    case moderate = "Moderate"
    case challenging = "Challenging"
    case hard = "Hard"
}
