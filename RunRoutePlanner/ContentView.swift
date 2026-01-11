import SwiftUI
import MapKit

// Make CLLocationCoordinate2D Equatable for onChange
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routePlanner = RoutePlanner()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var settings = SettingsManager()
    @State private var isRunning = false
    @State private var targetDistance: Double = AppConstants.Routing.defaultDistance
    @State private var targetTime: Double = AppConstants.Pace.defaultTimeMinutes
    @State private var voiceGuidanceEnabled = true
    @State private var paceCoachingEnabled = true
    @State private var showSettings = false
    @State private var showStopConfirmation = false
    @State private var showRunSummary = false
    @State private var completedRunStats: RunStats?
    
    struct RunStats {
        let distance: Double
        let time: TimeInterval
        let averagePace: Double
    }

    var body: some View {
        ZStack {
            mapView
            
            VStack {
                topStatsPanel
                Spacer()
                bottomControlPanel
            }
        }
        .onAppear {
            handleAppear()
        }
        .onChange(of: locationManager.location) { newValue in
            handleLocationChange(newValue: newValue)
        }
        .onChange(of: routePlanner.currentWaypoints) { newValue in
            handleWaypointsChange(newValue: newValue)
        }
        .onChange(of: voiceGuidanceEnabled) { newValue in
            handleVoiceGuidanceChange(newValue: newValue)
        }
        .onChange(of: locationManager.currentPace) { newValue in
            handlePaceChange(newValue: newValue)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
        .sheet(isPresented: $showRunSummary) {
            if let stats = completedRunStats {
                RunSummaryView(stats: stats, settings: settings, onDismiss: {
                    showRunSummary = false
                    completedRunStats = nil
                })
            }
        }
        .confirmationDialog("Stop Run?", isPresented: $showStopConfirmation, titleVisibility: .visible) {
            Button("Stop and Save", role: .destructive) {
                stopRun()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be saved.")
        }
    }
    
    // MARK: - View Components
    
    private var mapView: some View {
        MapView(
            userLocation: locationManager.location,
            route: routePlanner.currentRoute,
            completedPath: locationManager.runPath
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    private var topStatsPanel: some View {
        if isRunning {
            runningStatsPanel
        } else {
            idleStatsPanel
        }
    }
    
    private var runningStatsPanel: some View {
        VStack(spacing: 8) {
            HStack {
                distanceStatView
                Spacer()
                timeStatView
                Spacer()
                paceStatView
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(AppConstants.UI.statsCornerRadius)
        .padding()
    }
    
    private var distanceStatView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Distance")
                .font(.caption)
                .foregroundColor(.white)
            Text(String(format: "%.2f km", locationManager.totalDistance / 1000))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var timeStatView: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("Time")
                .font(.caption)
                .foregroundColor(.white)
            Text(formatElapsedTime(locationManager.elapsedTime))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var paceStatView: some View {
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
    
    private var idleStatsPanel: some View {
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
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(AppConstants.UI.statsCornerRadius)
        .padding()
    }
    
    private var bottomControlPanel: some View {
        VStack(spacing: 16) {
            if !isRunning {
                runConfigurationView
            }
            
            startStopButton
            
            if isRunning {
                if routePlanner.isLoadingRoute {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating route...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Follow the blue route on the map")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(AppConstants.UI.controlsCornerRadius)
        .padding()
    }
    
    private var runConfigurationView: some View {
        VStack(spacing: 12) {
            distanceControl
            Divider()
            timeControl
            Divider()
            calculatedPaceView
            Divider()
            voiceGuidanceToggle
            paceCoachingToggle
        }
        .padding()
        .background(Color.white)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    private var calculatedPaceView: some View {
        VStack(spacing: 8) {
            Text("Calculated Pace")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(calculateMilesPerHour())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("mph")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(calculateMinutesPerMile())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("min/mile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var distanceControl: some View {
        VStack(spacing: 12) {
            Text("Target Distance")
                .font(.headline)
            
            HStack {
                Button(action: { decrementDistance() }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                
                Text(String(format: "%.1f km", targetDistance))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 100)
                
                Button(action: { incrementDistance() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
        }
    }
    
    private var timeControl: some View {
        VStack(spacing: 12) {
            Text("Target Time")
                .font(.headline)
            
            HStack {
                Button(action: { decrementTime() }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                
                Text(formatTime(targetTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 100)
                
                Button(action: { incrementTime() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
        }
    }
    
    private var voiceGuidanceToggle: some View {
        Toggle(isOn: $voiceGuidanceEnabled) {
            HStack {
                Image(systemName: voiceGuidanceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                Text("Voice Guidance")
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
    
    private var paceCoachingToggle: some View {
        Toggle(isOn: $paceCoachingEnabled) {
            HStack {
                Image(systemName: paceCoachingEnabled ? "gauge.high" : "gauge")
                Text("Pace Coaching")
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .green))
    }
    
    private var startStopButton: some View {
        Button(action: {
            if isRunning {
                showStopConfirmation = true
            } else {
                startRun()
            }
            hapticFeedback(.medium)
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
            .shadow(color: (isRunning ? Color.red : Color.green).opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Event Handlers
    
    private func handleAppear() {
        locationManager.requestPermission()
    }
    
    private func handleLocationChange(newValue: CLLocationCoordinate2D?) {
        if voiceGuidanceEnabled, let location = newValue {
            navigationManager.updateLocation(location)
        }
    }
    
    private func handleWaypointsChange(newValue: [CLLocationCoordinate2D]) {
        startNavigationIfNeeded()
    }
    
    private func handleVoiceGuidanceChange(newValue: Bool) {
        if !newValue {
            navigationManager.stopNavigation()
        } else {
            startNavigationIfNeeded()
        }
    }
    
    private func handlePaceChange(newValue: Double) {
        if paceCoachingEnabled, isRunning {
            navigationManager.updatePace(
                currentPace: newValue,
                elapsedTime: locationManager.elapsedTime
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateMilesPerHour() -> String {
        guard targetDistance > 0, targetTime > 0 else {
            return "--"
        }
        
        // Convert km to miles
        let miles = targetDistance * 0.621371
        // Convert minutes to hours
        let hours = targetTime / 60.0
        let mph = miles / hours
        
        return String(format: "%.2f", mph)
    }
    
    private func calculateMinutesPerMile() -> String {
        guard targetDistance > 0, targetTime > 0 else {
            return "--"
        }
        
        // Convert km to miles
        let miles = targetDistance * 0.621371
        let minutesPerMile = targetTime / miles
        
        // Format as minutes:seconds
        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func decrementDistance() {
        targetDistance = max(AppConstants.Routing.minDistance, targetDistance - 1)
    }
    
    private func incrementDistance() {
        targetDistance = min(AppConstants.Routing.maxDistance, targetDistance + 1)
    }
    
    private func decrementDistanceFine() {
        targetDistance = max(AppConstants.Routing.minDistance, targetDistance - 0.1)
    }
    
    private func incrementDistanceFine() {
        targetDistance = min(AppConstants.Routing.maxDistance, targetDistance + 0.1)
    }
    
    private func decrementTime() {
        targetTime = max(AppConstants.Pace.minTimeMinutes, targetTime - AppConstants.Pace.timeStepMinutes)
    }
    
    private func incrementTime() {
        targetTime = min(AppConstants.Pace.maxTimeMinutes, targetTime + AppConstants.Pace.timeStepMinutes)
    }

    private func startRun() {
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
        // Save stats before resetting
        completedRunStats = RunStats(
            distance: locationManager.totalDistance / 1000,
            time: locationManager.elapsedTime,
            averagePace: locationManager.currentPace
        )
        
        isRunning = false
        locationManager.stopTracking()
        routePlanner.stopPlanning()
        navigationManager.stopNavigation()
        
        // Show summary
        hapticNotification(.success)
        showRunSummary = true
        
        // Reset after delay
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
