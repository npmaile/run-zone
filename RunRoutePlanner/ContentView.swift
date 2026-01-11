import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routePlanner = RoutePlanner()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var navigationManager = NavigationManager()
    @State private var isRunning = false
    @State private var targetDistance: Double = AppConstants.Routing.defaultDistance
    @State private var targetTime: Double = AppConstants.Pace.defaultTimeMinutes
    @State private var showSubscription = false
    @State private var voiceGuidanceEnabled = true
    @State private var paceCoachingEnabled = true

    var body: some View {
        ZStack {
            // Map View
            MapView(
                userLocation: locationManager.location,
                route: routePlanner.currentRoute,
                completedPath: locationManager.runPath
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                // Top Stats Panel
                if isRunning {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text(String(format: "%.2f km", locationManager.totalDistance / 1000))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            VStack(alignment: .center, spacing: 4) {
                                Text("Time")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text(formatElapsedTime(locationManager.elapsedTime))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Pace")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                HStack(spacing: 4) {
                                    if locationManager.currentPace > 0 {
                                        Text(String(format: "%.1f", locationManager.currentPace))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(paceStatusColor())
                                        Text("min/km")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("--")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(AppConstants.UI.statsCornerRadius)
                    .padding()
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(String(format: "%.2f km", locationManager.totalDistance / 1000))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Subscription badge
                        if !subscriptionManager.isSubscribed {
                            Button(action: {
                                showSubscription = true
                            }) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .padding(8)
                                    .background(Color.white.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(AppConstants.UI.statsCornerRadius)
                    .padding()
                }

                Spacer()

                // Bottom Control Panel
                VStack(spacing: 16) {
                    if !isRunning {
                        VStack(spacing: 12) {
                            Text("Target Distance")
                                .font(.headline)

                            HStack {
                                Button(action: {
                                    targetDistance = max(AppConstants.Routing.minDistance, targetDistance - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title)
                                }

                                Text(String(format: "%.1f km", targetDistance))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(width: 100)

                                Button(action: {
                                    targetDistance = min(AppConstants.Routing.maxDistance, targetDistance + 1)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                }
                            }

                            Divider()

                            Text("Target Time")
                                .font(.headline)

                            HStack {
                                Button(action: {
                                    targetTime = max(AppConstants.Pace.minTimeMinutes, targetTime - AppConstants.Pace.timeStepMinutes)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title)
                                }

                                Text(formatTime(targetTime))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(width: 100)

                                Button(action: {
                                    targetTime = min(AppConstants.Pace.maxTimeMinutes, targetTime + AppConstants.Pace.timeStepMinutes)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                }
                            }

                            Divider()

                            Toggle(isOn: $voiceGuidanceEnabled) {
                                HStack {
                                    Image(systemName: voiceGuidanceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    Text("Voice Guidance")
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))

                            Toggle(isOn: $paceCoachingEnabled) {
                                HStack {
                                    Image(systemName: paceCoachingEnabled ? "gauge.high" : "gauge")
                                    Text("Pace Coaching")
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(AppConstants.UI.cornerRadius)
                    }

                    // Start/Stop Button
                    Button(action: {
                        if isRunning {
                            stopRun()
                        } else {
                            startRun()
                        }
                    }) {
                        HStack {
                            Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                .font(.title2)
                            Text(isRunning ? "Stop Run" : "Start Run")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Color.red : Color.green)
                        .cornerRadius(AppConstants.UI.cornerRadius)
                    }

                    if isRunning {
                        Text("Follow the blue route on the map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(AppConstants.UI.controlsCornerRadius)
                .padding()
            }
        }
        .onAppear {
            locationManager.requestPermission()

            // Show subscription paywall if not subscribed
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.UI.paywallDelay) {
                if !subscriptionManager.isSubscribed {
                    showSubscription = true
                }
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            // Update navigation with current location
            if voiceGuidanceEnabled, let location = newLocation {
                navigationManager.updateLocation(location)
            }
        }
        .onChange(of: routePlanner.currentWaypoints) { newWaypoints in
            // Start navigation when new waypoints are generated
            startNavigationIfNeeded()
        }
        .onChange(of: voiceGuidanceEnabled) { enabled in
            // Stop navigation if disabled, start if enabled
            if !enabled {
                navigationManager.stopNavigation()
            } else {
                startNavigationIfNeeded()
            }
        }
        .onChange(of: locationManager.currentPace) { newPace in
            // Update pace coaching
            if paceCoachingEnabled, isRunning {
                navigationManager.updatePace(
                    currentPace: newPace,
                    elapsedTime: locationManager.elapsedTime
                )
            }
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView(isPresented: $showSubscription)
        }
    }

    private func startRun() {
        // Check subscription before starting
        guard subscriptionManager.isSubscribed else {
            showSubscription = true
            return
        }

        isRunning = true
        locationManager.startTracking()
        routePlanner.startPlanning(
            from: locationManager.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            targetDistance: targetDistance * 1000 // Convert to meters
        )

        // Set pace goal for coaching
        if paceCoachingEnabled {
            navigationManager.setPaceGoal(targetDistance: targetDistance, targetTime: targetTime)
        }
    }

    private func startNavigationIfNeeded() {
        guard voiceGuidanceEnabled, isRunning, !routePlanner.currentWaypoints.isEmpty else {
            return
        }
        navigationManager.startNavigation(waypoints: routePlanner.currentWaypoints)
    }

    private func stopRun() {
        isRunning = false
        locationManager.stopTracking()
        routePlanner.stopPlanning()
        navigationManager.stopNavigation()

        // Show summary or reset
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.UI.resetDelay) {
            locationManager.reset()
            routePlanner.reset()
        }
    }

    /// Formats time in minutes to human-readable string
    private func formatTime(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }

    /// Formats elapsed time in seconds to human-readable string
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

    /// Returns pace status color
    private func paceStatusColor() -> Color {
        switch navigationManager.paceStatus {
        case .tooSlow, .tooFast:
            return .red
        case .slightlySlow, .slightlyFast:
            return .orange
        case .onPace:
            return .green
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
