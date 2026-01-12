import Foundation
import SwiftData

// MARK: - Run Model

@Model
final class Run {
    var id: UUID
    var date: Date
    var distance: Double // meters
    var duration: TimeInterval // seconds
    var averagePace: Double // min/km
    var calories: Int
    var elevationGain: Double // meters
    var elevationLoss: Double // meters
    var routeName: String?
    var notes: String?
    var weatherCondition: String?
    var temperature: Double?
    var splits: [Split]
    var path: [Coordinate]
    var workoutType: WorkoutType
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        calories: Int = 0,
        elevationGain: Double = 0,
        elevationLoss: Double = 0,
        routeName: String? = nil,
        notes: String? = nil,
        weatherCondition: String? = nil,
        temperature: Double? = nil,
        splits: [Split] = [],
        path: [Coordinate] = [],
        workoutType: WorkoutType = .run
    ) {
        self.id = id
        self.date = date
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.calories = calories
        self.elevationGain = elevationGain
        self.elevationLoss = elevationLoss
        self.routeName = routeName
        self.notes = notes
        self.weatherCondition = weatherCondition
        self.temperature = temperature
        self.splits = splits
        self.path = path
        self.workoutType = workoutType
    }
}

// MARK: - Split Model

@Model
final class Split {
    var distance: Double // meters (usually 1000 for 1km or 1609 for 1 mile)
    var duration: TimeInterval // seconds
    var pace: Double // min/km or min/mile
    
    init(distance: Double, duration: TimeInterval, pace: Double) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }
}

// MARK: - Coordinate Model

@Model
final class Coordinate {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    
    init(latitude: Double, longitude: Double, altitude: Double = 0, timestamp: Date = Date()) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
}

// MARK: - Saved Route Model

@Model
final class SavedRoute {
    var id: UUID
    var name: String
    var distance: Double
    var waypoints: [Coordinate]
    var createdDate: Date
    var lastUsedDate: Date?
    var useCount: Int
    var isFavorite: Bool
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        distance: Double,
        waypoints: [Coordinate],
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        useCount: Int = 0,
        isFavorite: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.waypoints = waypoints
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.useCount = useCount
        self.isFavorite = isFavorite
        self.notes = notes
    }
}

// MARK: - Workout Type Enum

enum WorkoutType: String, Codable, CaseIterable {
    case run = "Run"
    case walk = "Walk"
    case hike = "Hike"
    case intervalRun = "Interval Run"
    case tempoRun = "Tempo Run"
    case longRun = "Long Run"
    case easyRun = "Easy Run"
    case race = "Race"
    
    var icon: String {
        switch self {
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        case .hike: return "figure.hiking"
        case .intervalRun: return "timer"
        case .tempoRun: return "speedometer"
        case .longRun: return "figure.run.circle"
        case .easyRun: return "figure.run.circle.fill"
        case .race: return "flag.checkered"
        }
    }
}

// MARK: - Achievement Model

@Model
final class Achievement {
    var id: UUID
    var type: AchievementType
    var unlockedDate: Date?
    var progress: Double // 0.0 to 1.0
    
    init(id: UUID = UUID(), type: AchievementType, unlockedDate: Date? = nil, progress: Double = 0.0) {
        self.id = id
        self.type = type
        self.unlockedDate = unlockedDate
        self.progress = progress
    }
}

enum AchievementType: String, Codable, CaseIterable {
    // Distance milestones
    case first5k = "First 5K"
    case first10k = "First 10K"
    case firstHalfMarathon = "First Half Marathon"
    case firstMarathon = "First Marathon"
    case total100km = "100km Total"
    case total500km = "500km Total"
    case total1000km = "1000km Total"
    
    // Streak achievements
    case streak7days = "7 Day Streak"
    case streak30days = "30 Day Streak"
    case streak100days = "100 Day Streak"
    
    // Speed achievements
    case sub5minKm = "Sub 5:00/km"
    case sub4minKm = "Sub 4:00/km"
    case sub8minMile = "Sub 8:00/mile"
    case sub7minMile = "Sub 7:00/mile"
    
    // Quantity achievements
    case runs10 = "10 Runs"
    case runs50 = "50 Runs"
    case runs100 = "100 Runs"
    case runs500 = "500 Runs"
    
    var icon: String {
        switch self {
        case .first5k, .first10k, .firstHalfMarathon, .firstMarathon:
            return "rosette"
        case .total100km, .total500km, .total1000km:
            return "star.fill"
        case .streak7days, .streak30days, .streak100days:
            return "flame.fill"
        case .sub5minKm, .sub4minKm, .sub8minMile, .sub7minMile:
            return "bolt.fill"
        case .runs10, .runs50, .runs100, .runs500:
            return "trophy.fill"
        }
    }
    
    var description: String {
        switch self {
        case .first5k: return "Complete your first 5K run"
        case .first10k: return "Complete your first 10K run"
        case .firstHalfMarathon: return "Complete your first Half Marathon"
        case .firstMarathon: return "Complete your first Marathon"
        case .total100km: return "Run a total of 100 kilometers"
        case .total500km: return "Run a total of 500 kilometers"
        case .total1000km: return "Run a total of 1000 kilometers"
        case .streak7days: return "Run for 7 consecutive days"
        case .streak30days: return "Run for 30 consecutive days"
        case .streak100days: return "Run for 100 consecutive days"
        case .sub5minKm: return "Run a kilometer in under 5 minutes"
        case .sub4minKm: return "Run a kilometer in under 4 minutes"
        case .sub8minMile: return "Run a mile in under 8 minutes"
        case .sub7minMile: return "Run a mile in under 7 minutes"
        case .runs10: return "Complete 10 runs"
        case .runs50: return "Complete 50 runs"
        case .runs100: return "Complete 100 runs"
        case .runs500: return "Complete 500 runs"
        }
    }
}

// MARK: - Training Plan Model

@Model
final class TrainingPlan {
    var id: UUID
    var name: String
    var goalDistance: Double
    var startDate: Date
    var weeks: Int
    var currentWeek: Int
    var completedWorkouts: [UUID] // IDs of completed runs
    var planType: TrainingPlanType
    
    init(
        id: UUID = UUID(),
        name: String,
        goalDistance: Double,
        startDate: Date = Date(),
        weeks: Int,
        currentWeek: Int = 1,
        completedWorkouts: [UUID] = [],
        planType: TrainingPlanType
    ) {
        self.id = id
        self.name = name
        self.goalDistance = goalDistance
        self.startDate = startDate
        self.weeks = weeks
        self.currentWeek = currentWeek
        self.completedWorkouts = completedWorkouts
        self.planType = planType
    }
}

enum TrainingPlanType: String, Codable, CaseIterable {
    case couchTo5k = "Couch to 5K"
    case fiveKto10K = "5K to 10K"
    case halfMarathon = "Half Marathon"
    case marathon = "Marathon"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .couchTo5k: return "figure.walk.motion"
        case .fiveKto10K: return "figure.run"
        case .halfMarathon: return "figure.run.circle"
        case .marathon: return "flag.checkered"
        case .custom: return "pencil.circle"
        }
    }
}
