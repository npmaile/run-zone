import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        if connectivity.isRunning {
            RunningView()
                .environmentObject(connectivity)
        } else {
            IdleView()
                .environmentObject(connectivity)
        }
    }
}

struct IdleView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Run Route Planner")
                .font(.headline)
                .multilineTextAlignment(.center)

            if connectivity.isPhoneReachable {
                VStack(spacing: 8) {
                    HStack {
                        Text("Distance:")
                            .font(.caption)
                        Spacer()
                        Text(String(format: "%.1f km", connectivity.targetDistance))
                            .font(.caption)
                            .fontWeight(.bold)
                    }

                    HStack {
                        Text("Time Goal:")
                            .font(.caption)
                        Spacer()
                        Text(formatTime(connectivity.targetTime))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)

                Text("Start run on iPhone")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "iphone.slash")
                        .font(.title2)
                        .foregroundColor(.orange)

                    Text("iPhone not connected")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Open the app on your iPhone")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }

    private func formatTime(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

struct RunningView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        TabView {
            // Stats Tab
            StatsView()
                .environmentObject(connectivity)

            // Pace Tab
            PaceView()
                .environmentObject(connectivity)
        }
        .tabViewStyle(.page)
    }
}

struct StatsView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        VStack(spacing: 4) {
            // Distance
            VStack(spacing: 2) {
                Text("Distance")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f", connectivity.distance / 1000))
                    .font(.system(size: 32, weight: .bold))
                Text("km")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)

            Divider()

            // Time
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatElapsedTime(connectivity.elapsedTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatTargetTime(connectivity.targetTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 4)

            Divider()

            // Remaining
            HStack {
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.2f km", max(0, connectivity.targetDistance - connectivity.distance / 1000)))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.top, 4)
        }
        .padding()
    }

    private func formatElapsedTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    private func formatTargetTime(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return "\(hours):\(String(format: "%02d", mins))"
        } else {
            return "\(mins) min"
        }
    }
}

struct PaceView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        VStack(spacing: 8) {
            // Pace status icon
            Image(systemName: paceStatusIcon())
                .font(.system(size: 40))
                .foregroundColor(paceStatusColor())
                .padding(.bottom, 4)

            // Current pace
            VStack(spacing: 2) {
                Text("Current Pace")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                if connectivity.currentPace > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", connectivity.currentPace))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(paceStatusColor())
                        Text("min/km")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold))
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Target pace
            VStack(spacing: 2) {
                Text("Target Pace")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                if connectivity.targetDistance > 0 && connectivity.targetTime > 0 {
                    let targetPace = connectivity.targetTime / connectivity.targetDistance
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", targetPace))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("min/km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("--")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            // Status text
            Text(paceStatusText())
                .font(.caption2)
                .foregroundColor(paceStatusColor())
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding()
    }

    private func paceStatusIcon() -> String {
        switch connectivity.paceStatus {
        case .tooSlow:
            return "hare.fill"
        case .slightlySlow:
            return "hare"
        case .onPace:
            return "checkmark.circle.fill"
        case .slightlyFast:
            return "tortoise"
        case .tooFast:
            return "tortoise.fill"
        }
    }

    private func paceStatusColor() -> Color {
        switch connectivity.paceStatus {
        case .tooSlow, .tooFast:
            return .red
        case .slightlySlow, .slightlyFast:
            return .orange
        case .onPace:
            return .green
        }
    }

    private func paceStatusText() -> String {
        switch connectivity.paceStatus {
        case .tooSlow:
            return "Speed up!"
        case .slightlySlow:
            return "A bit slow"
        case .onPace:
            return "On pace"
        case .slightlyFast:
            return "A bit fast"
        case .tooFast:
            return "Slow down!"
        }
    }
}

struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
            .environmentObject(WatchConnectivityManager())
    }
}
