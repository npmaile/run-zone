import Foundation
import SwiftData

// MARK: - WorkoutType

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
        case .run, .intervalRun, .tempoRun, .longRun, .easyRun, .race:
            return "figure.run"
        case .walk:
            return "figure.walk"
        case .hike:
            return "figure.hiking"
        }
    }
}

// MARK: - Run Model

@Model
class Run {
    var id: UUID
    var date: Date
    var distance: Double // in meters
    var duration: TimeInterval // in seconds
    var averagePace: Double // min per km
    var calories: Int
    var workoutType: WorkoutType
    var routeName: String?
    var splits: [Split]
    var elevationGain: Double
    var elevationLoss: Double
    var notes: String?
    var weatherCondition: String?
    var temperature: Double?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        calories: Int,
        workoutType: WorkoutType = .run,
        routeName: String? = nil,
        splits: [Split] = [],
        elevationGain: Double = 0,
        elevationLoss: Double = 0,
        notes: String? = nil,
        weatherCondition: String? = nil,
        temperature: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.calories = calories
        self.workoutType = workoutType
        self.routeName = routeName
        self.splits = splits
        self.elevationGain = elevationGain
        self.elevationLoss = elevationLoss
        self.notes = notes
        self.weatherCondition = weatherCondition
        self.temperature = temperature
    }
}

// MARK: - Split Model

@Model
class Split {
    var distance: Double // in meters
    var duration: TimeInterval // in seconds
    var pace: Double // min per km
    
    init(distance: Double, duration: TimeInterval, pace: Double) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }
}
