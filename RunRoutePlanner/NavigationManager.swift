import Foundation
import CoreLocation
import AVFoundation
import Combine

/// Manages turn-by-turn voice navigation for following planned routes
/// Also provides pace coaching to help runners hit their time goals
class NavigationManager: NSObject, ObservableObject {
    @Published var currentWaypointIndex: Int = 0
    @Published var distanceToNextWaypoint: Double = 0
    @Published var isNavigating: Bool = false
    @Published var paceStatus: PaceStatus = .onPace

    private var waypoints: [CLLocationCoordinate2D] = []
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var hasGivenInstruction = false
    private var lastInstructionDistance: Double = 0

    // Pace coaching
    private var targetPace: Double = 0 // minutes per kilometer
    private var lastPaceCoachingTime: Date?
    private var paceCoachingTimer: Timer?

    enum PaceStatus {
        case tooSlow
        case slightlySlow
        case onPace
        case slightlyFast
        case tooFast
    }

    /// Starts navigation with the given route waypoints
    func startNavigation(waypoints: [CLLocationCoordinate2D]) {
        guard waypoints.count >= 2 else { return }

        self.waypoints = waypoints
        self.currentWaypointIndex = 0
        self.isNavigating = true
        self.hasGivenInstruction = false

        speakInstruction("Navigation started. Follow the route.")
    }

    /// Stops navigation and clears the route
    func stopNavigation() {
        isNavigating = false
        waypoints = []
        currentWaypointIndex = 0
        speechSynthesizer.stopSpeaking(at: .immediate)
        paceCoachingTimer?.invalidate()
        paceCoachingTimer = nil
    }

    /// Sets the target pace for coaching
    /// - Parameters:
    ///   - targetDistance: Target distance in kilometers
    ///   - targetTime: Target time in minutes
    func setPaceGoal(targetDistance: Double, targetTime: Double) {
        guard targetDistance > 0, targetTime > 0 else { return }

        // Calculate target pace (min/km)
        targetPace = targetTime / targetDistance

        // Start pace coaching timer
        paceCoachingTimer?.invalidate()
        paceCoachingTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Pace.paceCheckInterval,
            repeats: true
        ) { [weak self] _ in
            // Timer just marks time, actual coaching happens in updatePace
        }
    }

    /// Updates pace coaching based on current pace
    /// - Parameters:
    ///   - currentPace: Current pace in minutes per kilometer
    ///   - elapsedTime: Time elapsed since start in seconds
    func updatePace(currentPace: Double, elapsedTime: TimeInterval) {
        guard targetPace > 0, currentPace > 0 else {
            paceStatus = .onPace
            return
        }

        // Calculate percentage difference from target
        let paceDifference = (currentPace - targetPace) / targetPace

        // Update pace status
        if paceDifference > AppConstants.Pace.moderatelySlowThreshold {
            paceStatus = .tooSlow
        } else if paceDifference > AppConstants.Pace.slightlySlowThreshold {
            paceStatus = .slightlySlow
        } else if paceDifference < -AppConstants.Pace.moderatelyFastThreshold {
            paceStatus = .tooFast
        } else if paceDifference < -AppConstants.Pace.slightlyFastThreshold {
            paceStatus = .slightlyFast
        } else {
            paceStatus = .onPace
        }

        // Give voice coaching if needed
        givePaceCoaching(paceDifference: paceDifference, elapsedTime: elapsedTime)
    }

    /// Gives voice coaching about pace if appropriate
    private func givePaceCoaching(paceDifference: Double, elapsedTime: TimeInterval) {
        // Don't coach too early in the run
        guard elapsedTime > 120 else { return } // Wait 2 minutes

        // Check if we need to wait before next coaching
        if let lastCoaching = lastPaceCoachingTime {
            let timeSinceLastCoaching = Date().timeIntervalSince(lastCoaching)
            guard timeSinceLastCoaching >= AppConstants.Pace.minTimeBetweenCoaching else {
                return
            }
        }

        // Only coach if significantly off pace
        guard abs(paceDifference) > AppConstants.Pace.paceTolerancePercent else {
            return
        }

        var message: String?

        if paceDifference > AppConstants.Pace.moderatelySlowThreshold {
            message = "You're running significantly slow. Try to pick up the pace to hit your goal."
        } else if paceDifference > AppConstants.Pace.slightlySlowThreshold {
            message = "You're running a bit slow. Speed up slightly to stay on track."
        } else if paceDifference < -AppConstants.Pace.moderatelyFastThreshold {
            message = "You're running significantly fast. Slow down to conserve energy."
        } else if paceDifference < -AppConstants.Pace.slightlyFastThreshold {
            message = "You're running a bit fast. You can slow down slightly."
        }

        if let message = message {
            speakInstruction(message)
            lastPaceCoachingTime = Date()
        }
    }

    /// Updates navigation based on current location
    func updateLocation(_ location: CLLocationCoordinate2D) {
        guard isNavigating, !waypoints.isEmpty else { return }
        guard currentWaypointIndex < waypoints.count else {
            // Reached the end
            if currentWaypointIndex == waypoints.count {
                speakInstruction("You have reached your destination.")
                currentWaypointIndex += 1 // Prevent repeating
            }
            return
        }

        let nextWaypoint = waypoints[currentWaypointIndex]
        let distance = calculateDistance(from: location, to: nextWaypoint)
        distanceToNextWaypoint = distance

        // Check if we've reached the current waypoint
        if distance < AppConstants.Navigation.waypointReachedThreshold {
            advanceToNextWaypoint(from: location)
        } else if distance < AppConstants.Navigation.instructionDistance {
            // Give instruction if we haven't already for this waypoint
            if !hasGivenInstruction || (lastInstructionDistance - distance) > AppConstants.Navigation.instructionRepeatThreshold {
                giveNavigationInstruction(from: location)
                hasGivenInstruction = true
                lastInstructionDistance = distance
            }
        }
    }

    /// Advances to the next waypoint and gives appropriate instruction
    private func advanceToNextWaypoint(from location: CLLocationCoordinate2D) {
        currentWaypointIndex += 1
        hasGivenInstruction = false

        if currentWaypointIndex < waypoints.count {
            giveNavigationInstruction(from: location)
        } else if currentWaypointIndex == waypoints.count {
            speakInstruction("You have reached your destination.")
            currentWaypointIndex += 1 // Prevent repeating
        }
    }

    /// Generates and speaks navigation instruction
    private func giveNavigationInstruction(from location: CLLocationCoordinate2D) {
        guard currentWaypointIndex < waypoints.count else { return }

        let nextWaypoint = waypoints[currentWaypointIndex]
        let distance = calculateDistance(from: location, to: nextWaypoint)
        let distanceText = formatDistance(distance)

        // If this is the last waypoint
        if currentWaypointIndex == waypoints.count - 1 {
            speakInstruction("In \(distanceText), you will reach your destination.")
            return
        }

        // Calculate turn direction
        guard currentWaypointIndex + 1 < waypoints.count else { return }
        let followingWaypoint = waypoints[currentWaypointIndex + 1]

        let currentBearing = calculateBearing(from: location, to: nextWaypoint)
        let nextBearing = calculateBearing(from: nextWaypoint, to: followingWaypoint)
        let turnAngle = normalizeAngle(nextBearing - currentBearing)

        let direction = directionFromAngle(turnAngle)
        speakInstruction("In \(distanceText), \(direction).")
    }

    /// Converts turn angle to human-readable direction
    private func directionFromAngle(_ angle: Double) -> String {
        let absAngle = abs(angle)

        if absAngle < AppConstants.Navigation.straightAngleThreshold {
            return "continue straight"
        } else if absAngle > 180 - AppConstants.Navigation.uTurnAngleThreshold {
            return "make a U-turn"
        } else if angle > 0 {
            // Right turn
            if absAngle < AppConstants.Navigation.slightTurnThreshold {
                return "turn slightly right"
            } else if absAngle < AppConstants.Navigation.sharpTurnThreshold {
                return "turn right"
            } else {
                return "turn sharply right"
            }
        } else {
            // Left turn
            if absAngle < AppConstants.Navigation.slightTurnThreshold {
                return "turn slightly left"
            } else if absAngle < AppConstants.Navigation.sharpTurnThreshold {
                return "turn left"
            } else {
                return "turn sharply left"
            }
        }
    }

    /// Calculates distance between two coordinates in meters
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    /// Calculates bearing from one coordinate to another in degrees
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi

        return normalizeAngle(bearing)
    }

    /// Normalizes angle to -180 to 180 range
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle.truncatingRemainder(dividingBy: 360)
        if normalized > 180 {
            normalized -= 360
        } else if normalized < -180 {
            normalized += 360
        }
        return normalized
    }

    /// Formats distance in meters to human-readable string
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters)) meters"
        } else {
            let km = meters / 1000
            return String(format: "%.1f kilometers", km)
        }
    }

    /// Speaks the given instruction using text-to-speech
    private func speakInstruction(_ text: String) {
        // Stop any current speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AppConstants.Navigation.speechRate
        utterance.volume = AppConstants.Navigation.speechVolume

        speechSynthesizer.speak(utterance)
    }
}
