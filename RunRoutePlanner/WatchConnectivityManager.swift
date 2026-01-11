import Foundation
import WatchConnectivity
import Combine

/// Manages communication between iPhone and Apple Watch
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isWatchConnected = false
    @Published var isWatchAppInstalled = false

    private override init() {
        super.init()

        #if !os(watchOS)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        #endif
    }

    /// Sends run state update to watch
    func sendRunState(
        isRunning: Bool,
        distance: Double,
        elapsedTime: TimeInterval,
        currentPace: Double,
        paceStatus: String,
        targetDistance: Double,
        targetTime: Double
    ) {
        #if !os(watchOS)
        guard WCSession.default.isReachable else { return }

        let data: [String: Any] = [
            "isRunning": isRunning,
            "distance": distance,
            "elapsedTime": elapsedTime,
            "currentPace": currentPace,
            "paceStatus": paceStatus,
            "targetDistance": targetDistance,
            "targetTime": targetTime,
            "timestamp": Date().timeIntervalSince1970
        ]

        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            print("Failed to send message to watch: \(error.localizedDescription)")
        }
        #endif
    }

    /// Sends haptic feedback request to watch
    func sendHapticFeedback(type: String) {
        #if !os(watchOS)
        guard WCSession.default.isReachable else { return }

        let data: [String: Any] = [
            "haptic": type
        ]

        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            print("Failed to send haptic to watch: \(error.localizedDescription)")
        }
        #endif
    }
}

// MARK: - WCSessionDelegate (iOS)
#if !os(watchOS)
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = session.isReachable
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle messages from watch (e.g., start/stop run commands)
        if let action = message["action"] as? String {
            handleWatchAction(action)
        }
    }

    private func handleWatchAction(_ action: String) {
        // Post notification that can be observed by ContentView
        NotificationCenter.default.post(name: .watchAction, object: action)
    }
}

extension Notification.Name {
    static let watchAction = Notification.Name("watchAction")
}
#endif
