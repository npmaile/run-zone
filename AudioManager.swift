import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isEnabled = true
    @Published var announcementInterval: Double = 1000.0 // meters (1 km default)
    
    private var lastAnnouncementDistance: Double = 0
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Announcements
    
    func announceProgress(distance: Double, time: TimeInterval, pace: Double, settings: SettingsManager) {
        guard isEnabled else { return }
        
        // Check if we've traveled enough distance since last announcement
        let distanceSinceLastAnnouncement = distance - lastAnnouncementDistance
        
        if distanceSinceLastAnnouncement >= announcementInterval {
            lastAnnouncementDistance = distance
            
            let distanceFormatted = settings.fromKilometers(distance / 1000)
            let unit = settings.distanceUnit == .kilometers ? "kilometers" : "miles"
            let timeFormatted = formatTime(time)
            let paceFormatted = String(format: "%.1f", pace)
            
            let message = """
            Distance: \(String(format: "%.1f", distanceFormatted)) \(unit). \
            Time: \(timeFormatted). \
            Current pace: \(paceFormatted) minutes per \(settings.distanceUnit == .kilometers ? "kilometer" : "mile").
            """
            
            speak(message)
        }
    }
    
    func announceSplit(splitNumber: Int, splitTime: TimeInterval, splitPace: Double) {
        guard isEnabled else { return }
        
        let timeFormatted = formatTime(splitTime)
        let paceFormatted = String(format: "%.1f", splitPace)
        
        let message = "Split \(splitNumber). Time: \(timeFormatted). Pace: \(paceFormatted)."
        speak(message)
    }
    
    func announceWorkoutStart(distance: Double, settings: SettingsManager) {
        guard isEnabled else { return }
        
        let distanceFormatted = settings.fromKilometers(distance)
        let unit = settings.distanceUnit == .kilometers ? "kilometers" : "miles"
        
        let message = "Starting \(String(format: "%.1f", distanceFormatted)) \(unit) run. Good luck!"
        speak(message)
    }
    
    func announceWorkoutComplete(distance: Double, time: TimeInterval, settings: SettingsManager) {
        guard isEnabled else { return }
        
        let distanceFormatted = settings.fromKilometers(distance / 1000)
        let unit = settings.distanceUnit == .kilometers ? "kilometers" : "miles"
        let timeFormatted = formatTime(time)
        
        let message = "Run complete! You ran \(String(format: "%.2f", distanceFormatted)) \(unit) in \(timeFormatted). Great job!"
        speak(message)
    }
    
    func announceHalfway() {
        guard isEnabled else { return }
        speak("You've reached the halfway point! Keep it up!")
    }
    
    func announcePaceFeedback(status: String) {
        guard isEnabled else { return }
        speak(status)
    }
    
    func announceIntervalStart(type: String, duration: Int) {
        guard isEnabled else { return }
        speak("\(type) for \(duration) seconds. Go!")
    }
    
    func announceIntervalEnd() {
        guard isEnabled else { return }
        speak("Interval complete!")
    }
    
    // MARK: - Helper Methods
    
    private func speak(_ text: String) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func resetAnnouncements() {
        lastAnnouncementDistance = 0
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return "\(hours) hours, \(minutes) minutes, \(secs) seconds"
        } else if minutes > 0 {
            return "\(minutes) minutes, \(secs) seconds"
        } else {
            return "\(secs) seconds"
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // Optional: handle speech start
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Optional: handle speech finish
    }
}
