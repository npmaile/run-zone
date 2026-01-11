import Foundation
import WatchConnectivity
import Combine

/// Manages communication between Apple Watch and iPhone
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isPhoneReachable = false
    @Published var isRunning = false
    @Published var distance: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentPace: Double = 0
    @Published var paceStatus: PaceStatus = .onPace
    @Published var targetDistance: Double = 5.0
    @Published var targetTime: Double = 30.0

    enum PaceStatus: String {
        case tooSlow
        case slightlySlow
        case onPace
        case slightlyFast
        case tooFast

        init(from string: String) {
            switch string {
            case "tooSlow": self = .tooSlow
            case "slightlySlow": self = .slightlySlow
            case "slightlyFast": self = .slightlyFast
            case "tooFast": self = .tooFast
            default: self = .onPace
            }
        }
    }

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    /// Sends action to iPhone (e.g., start/stop run)
    func sendAction(_ action: String) {
        guard WCSession.default.isReachable else {
            print("iPhone not reachable")
            return
        }

        let message: [String: Any] = ["action": action]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send action to iPhone: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate (watchOS)
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }

        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // Update run state from iPhone
            if let isRunning = message["isRunning"] as? Bool {
                self.isRunning = isRunning
            }
            if let distance = message["distance"] as? Double {
                self.distance = distance
            }
            if let elapsedTime = message["elapsedTime"] as? TimeInterval {
                self.elapsedTime = elapsedTime
            }
            if let currentPace = message["currentPace"] as? Double {
                self.currentPace = currentPace
            }
            if let paceStatusString = message["paceStatus"] as? String {
                self.paceStatus = PaceStatus(from: paceStatusString)
            }
            if let targetDistance = message["targetDistance"] as? Double {
                self.targetDistance = targetDistance
            }
            if let targetTime = message["targetTime"] as? Double {
                self.targetTime = targetTime
            }

            // Handle haptic feedback
            if let hapticType = message["haptic"] as? String {
                self.triggerHaptic(type: hapticType)
            }
        }
    }

    private func triggerHaptic(type: String) {
        #if os(watchOS)
        import WatchKit
        switch type {
        case "success":
            WKInterfaceDevice.current().play(.success)
        case "warning":
            WKInterfaceDevice.current().play(.notification)
        case "error":
            WKInterfaceDevice.current().play(.failure)
        default:
            WKInterfaceDevice.current().play(.click)
        }
        #endif
    }
}
