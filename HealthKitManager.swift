import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // Types we want to read
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.workoutType()
    ]
    
    // Types we want to write
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.workoutType()
    ]
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        
        await MainActor.run {
            isAuthorized = true
        }
    }
    
    // MARK: - Save Workout
    
    func saveWorkout(
        distance: Double, // meters
        duration: TimeInterval, // seconds
        calories: Double,
        startDate: Date,
        workoutType: WorkoutType = .run
    ) async throws {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let hkWorkoutType: HKWorkoutActivityType = {
            switch workoutType {
            case .run, .intervalRun, .tempoRun, .longRun, .easyRun, .race:
                return .running
            case .walk:
                return .walking
            case .hike:
                return .hiking
            }
        }()
        
        let workout = HKWorkout(
            activityType: hkWorkoutType,
            start: startDate,
            end: startDate.addingTimeInterval(duration),
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: [
                HKMetadataKeyIndoorWorkout: false
            ]
        )
        
        try await healthStore.save(workout)
    }
    
    // MARK: - Read Data
    
    func fetchRecentWorkouts(limit: Int = 10) async throws -> [HKWorkout] {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { query, samples, error in
            // Handle results
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: nil,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Calculate Calories
    
    func estimateCalories(
        distance: Double, // meters
        duration: TimeInterval, // seconds
        userWeight: Double = 70.0 // kg, default average
    ) -> Int {
        // MET (Metabolic Equivalent) calculation
        // Running: MET = 1.0 * (m/min * 0.2) + 0.9 * (m/min * 0.2) * (grade) + 3.5
        // Simplified: approximately 1 calorie per kg per km
        
        let distanceKm = distance / 1000.0
        let calories = userWeight * distanceKm * 1.036 // slight multiplier for energy expenditure
        
        return Int(calories)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Health data is not available on this device"
        case .notAuthorized:
            return "Health app authorization required"
        case .saveFailed:
            return "Failed to save workout to Health app"
        }
    }
}
