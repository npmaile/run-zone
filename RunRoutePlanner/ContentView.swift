import SwiftUI
import SwiftUI
import MapKit
import UIKit

// Make CLLocationCoordinate2D Equatable for onChange
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Optimization Mode

enum OptimizationMode: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case time = "Time"
    case pace = "Pace"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .distance: return "arrow.left.and.right"
        case .time: return "clock"
        case .pace: return "gauge.with.dots.needle.bottom.50percent"
        }
    }
    
    var description: String {
        switch self {
        case .distance: return "Lock distance, adjust time & pace"
        case .time: return "Lock time, adjust distance & pace"
        case .pace: return "Lock pace, adjust distance & time"
        }
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
    @State private var targetPace: Double = 6.0 // minutes per km
    @State private var optimizationMode: OptimizationMode = .distance
    @State private var voiceGuidanceEnabled = true
    @State private var paceCoachingEnabled = true
    @State private var showSettings = false
    @State private var showStopConfirmation = false
    @State private var showRunSummary = false
    @State private var showRouteDetails = false
    @State private var showRouteEditor = false
    @State private var showRouteOptions = false
    @State private var completedRunStats: RunStats?
    @State private var isControlPanelExpanded = false // Start collapsed for better route visibility

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
        .onChange(of: targetDistance) { newValue in
            handleTargetDistanceChange()
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
        .sheet(isPresented: $showRouteDetails) {
            if let details = routePlanner.routeDetails {
                RouteDetailsSheet(routeDetails: details)
            }
        }
        .sheet(isPresented: $showRouteEditor) {
            SimpleRouteEditorSheet(routePlanner: routePlanner)
        }
        .sheet(isPresented: $showRouteOptions) {
            RouteOptionsSheet(routePlanner: routePlanner)
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
            completedPath: locationManager.runPath,
            showDirectionalArrows: !isRunning && !routePlanner.currentRoute.isEmpty
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
        HStack(spacing: 16) {
            distanceStatView
            Divider()
                .frame(height: 40)
            timeStatView
            Divider()
                .frame(height: 40)
            paceStatView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.appElevatedBackground
                .opacity(0.95)
        )
        .cornerRadius(AppConstants.UI.statsCornerRadius)
        .shadow(color: Color.appShadow, radius: 6, x: 0, y: 3)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
    
    private var distanceStatView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Distance")
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
            Text(String(format: "%.2f km", locationManager.totalDistance / 1000))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
        }
    }
    
    private var timeStatView: some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Time")
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
            Text(formatElapsedTime(locationManager.elapsedTime))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
        }
    }
    
    private var paceStatView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("Pace")
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
            HStack(spacing: 4) {
                if locationManager.currentPace > 0 {
                    Text(String(format: "%.1f", locationManager.currentPace))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(paceStatusColor())
                    Text("min/km")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                } else {
                    Text("--")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                }
            }
        }
    }
    
    private var idleStatsPanel: some View {
        HStack(alignment: .center, spacing: 12) {
            // Compact distance display
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDistance(targetDistance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                Text("\(Int(targetTime))min target")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
            
            // Route control buttons
            if !routePlanner.currentRoute.isEmpty {
                Divider()
                    .frame(height: 30)
                
                HStack(spacing: 10) {
                    // Route options button (NEW!)
                    Button(action: {
                        Task {
                            if let location = locationManager.location {
                                await routePlanner.generateRouteOptions(
                                    from: location,
                                    targetDistance: targetDistance * 1000
                                )
                            }
                            showRouteOptions = true
                        }
                        hapticFeedback(.light)
                    }) {
                        Image(systemName: "map.fill")
                            .font(.title3)
                            .foregroundColor(.appSuccess)
                    }
                    
                    // Reverse direction button
                    Button(action: {
                        routePlanner.toggleDirection()
                        hapticFeedback(.light)
                    }) {
                        Image(systemName: routePlanner.isReversed ? "arrow.counterclockwise.circle.fill" : "arrow.clockwise.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appInfo)
                    }
                    
                    // Edit route button
                    Button(action: {
                        showRouteEditor = true
                        hapticFeedback(.light)
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appWarning)
                    }
                    
                    // Route details button
                    Button(action: {
                        Task {
                            if routePlanner.routeDetails == nil {
                                routePlanner.routeDetails = await routePlanner.analyzeRoute()
                            }
                            showRouteDetails = true
                        }
                        hapticFeedback(.light)
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appSuccess)
                    }
                }
            } else if routePlanner.isLoadingRoute {
                Divider()
                    .frame(height: 30)
                ProgressView()
                    .tint(.appInfo)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Settings button
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.appTextPrimary)
                    .padding(8)
                    .background(Color.appCardBackground.opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.appElevatedBackground
                .opacity(0.95)
        )
        .cornerRadius(AppConstants.UI.statsCornerRadius)
        .shadow(color: Color.appShadow, radius: 6, x: 0, y: 3)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
    
    private var bottomControlPanel: some View {
        VStack(spacing: 12) {
            // Collapse/Expand button (only when not running)
            if !isRunning {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isControlPanelExpanded.toggle()
                    }
                    hapticFeedback(.light)
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.subheadline)
                        Text(isControlPanelExpanded ? "Hide Settings" : "Adjust Distance & Time")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: isControlPanelExpanded ? "chevron.down" : "chevron.up")
                            .font(.caption)
                    }
                    .foregroundColor(.appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.appCardBackground.opacity(0.5))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            
            // Expandable content
            if !isRunning && isControlPanelExpanded {
                runConfigurationView
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                
                // Show route error if present
                if let error = routePlanner.routeError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.appWarning)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.appWarning.opacity(0.1))
                    .cornerRadius(8)
                }
                // Preview hint
                else if !routePlanner.currentRoute.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.caption)
                            .foregroundColor(.appInfo)
                        Text("Blue arrows show direction • Use buttons above to customize")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            
            startStopButton
            
            if isRunning {
                Text("Follow the blue route on the map")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            Color.appElevatedBackground
                .opacity(0.95)
        )
        .cornerRadius(AppConstants.UI.controlsCornerRadius)
        .shadow(color: Color.appShadow, radius: 8, x: 0, y: -3)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    private var runConfigurationView: some View {
        VStack(spacing: 12) {
            // Optimization mode picker
            optimizationModePicker
            
            Divider()
            
            // Dynamic controls based on optimization mode
            dynamicControls
            
            Divider()
            
            // Show calculated/locked value
            lockedValueDisplay
            
            Divider()
            
            voiceGuidanceToggle
            paceCoachingToggle
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    @ViewBuilder
    private var dynamicControls: some View {
        switch optimizationMode {
        case .distance:
            // Distance is locked, show time and pace controls
            timeControl
            Divider()
            paceControl
            
        case .time:
            // Time is locked, show distance and pace controls
            distanceControl
            Divider()
            paceControl
            
        case .pace:
            // Pace is locked, show distance and time controls
            distanceControl
            Divider()
            timeControl
        }
    }
    
    private var optimizationModePicker: some View {
        VStack(spacing: 8) {
            Text("Optimize For")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Picker("Optimization Mode", selection: $optimizationMode) {
                ForEach(OptimizationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: optimizationMode) { newValue in
                // Just provide haptic feedback, no recalculation needed
                // The values stay as they are, just which one is locked changes
                hapticFeedback(.light)
            }
            
            // Show description and icon for selected mode
            HStack(spacing: 6) {
                Image(systemName: optimizationMode.icon)
                    .font(.caption)
                    .foregroundColor(.appInfo)
                Text(optimizationMode.description)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            .multilineTextAlignment(.center)
        }
    }
    
    private var lockedValueDisplay: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.appInfo)
                Text("Locked Value")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
            }
            
            HStack(spacing: 20) {
                switch optimizationMode {
                case .distance:
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f km", targetDistance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appInfo)
                        Text("Distance (locked)")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    
                case .time:
                    VStack(spacing: 4) {
                        Text(formatTime(targetTime))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appInfo)
                        Text("Time (locked)")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    
                case .pace:
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", targetPace))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appInfo)
                        Text("min/km (locked)")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                // Show other calculated values
                VStack(spacing: 4) {
                    Text(calculateMilesPerHour())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.appSuccess)
                    Text("mph")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(calculateMinutesPerMile())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.appWarning)
                    Text("min/mile")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding()
        .background(Color.appInfo.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var calculatedPaceView: some View {
        VStack(spacing: 8) {
            Text("Calculated Pace")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(calculateMilesPerHour())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appInfo)
                    Text("mph")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(calculateMinutesPerMile())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appSuccess)
                    Text("min/mile")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
    }
    
    private var distanceControl: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Target Distance")
                    .font(.headline)
                if optimizationMode == .distance {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.appInfo)
                }
            }
            
            HStack {
                Button(action: { 
                    decrementDistance()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .distance ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .distance)
                
                Text(String(format: "%.1f km", targetDistance))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 100)
                    .foregroundColor(optimizationMode == .distance ? .appInfo : .appTextPrimary)
                
                Button(action: { 
                    incrementDistance()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .distance ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .distance)
            }
        }
    }
    
    private var timeControl: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Target Time")
                    .font(.headline)
                if optimizationMode == .time {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.appInfo)
                }
            }
            
            HStack {
                Button(action: { 
                    decrementTime()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .time ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .time)
                
                Text(formatTime(targetTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 100)
                    .foregroundColor(optimizationMode == .time ? .appInfo : .appTextPrimary)
                
                Button(action: { 
                    incrementTime()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .time ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .time)
            }
        }
    }
    
    private var paceControl: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Target Pace")
                    .font(.headline)
                if optimizationMode == .pace {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.appInfo)
                }
            }
            
            HStack {
                Button(action: { 
                    decrementPace()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .pace ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .pace)
                
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", targetPace))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(optimizationMode == .pace ? .appInfo : .appTextPrimary)
                    Text("min/km")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(width: 100)
                
                Button(action: { 
                    incrementPace()
                    hapticFeedback(.light)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(optimizationMode == .pace ? .appTextSecondary : .appInfo)
                }
                .disabled(optimizationMode == .pace)
            }
        }
    }
    
    private var voiceGuidanceToggle: some View {
        Toggle(isOn: $voiceGuidanceEnabled) {
            HStack {
                Image(systemName: voiceGuidanceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundColor(.appInfo)
                Text("Voice Guidance")
                    .foregroundColor(.appTextPrimary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .appInfo))
    }
    
    private var paceCoachingToggle: some View {
        Toggle(isOn: $paceCoachingEnabled) {
            HStack {
                Image(systemName: paceCoachingEnabled ? "gauge.high" : "gauge")
                    .foregroundColor(.appSuccess)
                Text("Pace Coaching")
                    .foregroundColor(.appTextPrimary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .appSuccess))
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
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.title3)
                Text(isRunning ? "Stop Run" : "Start Run")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(isRunning ? LinearGradient.appDangerGradient : LinearGradient.appSuccessGradient)
            .cornerRadius(12)
            .shadow(color: Color.appShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Event Handlers
    
    private func handleAppear() {
        locationManager.requestPermission()
        // Calculate initial pace from default distance and time
        if targetDistance > 0 && targetTime > 0 {
            targetPace = targetTime / targetDistance
        }
        // Generate initial route preview when location is available
        if let location = locationManager.location {
            generateRoutePreview(from: location)
        }
    }
    
    private func handleLocationChange(newValue: CLLocationCoordinate2D?) {
        if voiceGuidanceEnabled, let location = newValue {
            navigationManager.updateLocation(location)
        }
        // Update preview if not running
        if !isRunning, let location = newValue {
            generateRoutePreview(from: location)
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
    
    private func handleTargetDistanceChange() {
        // Update route preview when distance changes
        if !isRunning, let location = locationManager.location {
            generateRoutePreview(from: location)
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateRoutePreview(from location: CLLocationCoordinate2D) {
        // Generate a preview of the route based on target distance
        routePlanner.startPlanning(
            from: location,
            targetDistance: targetDistance * 1000 // Convert to meters
        )
    }
    
    private func formatDistance(_ km: Double) -> String {
        let distance = settings.fromKilometers(km)
        return String(format: "%.2f %@", distance, settings.distanceUnit.abbreviation)
    }
    
    private func calculateSpeed() -> String {
        guard targetDistance > 0, targetTime > 0 else {
            return "--"
        }
        
        let distance = settings.fromKilometers(targetDistance)
        let hours = targetTime / 60.0
        let speed = distance / hours
        
        return String(format: "%.2f", speed)
    }
    
    private func calculatePace() -> String {
        guard targetDistance > 0, targetTime > 0 else {
            return "--"
        }
        
        let distance = settings.fromKilometers(targetDistance)
        let pace = targetTime / distance
        
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func calculateMilesPerHour() -> String {
        guard targetPace > 0 else {
            return "--"
        }
        
        // Convert pace (min/km) to speed (mph)
        // Speed in km/h = 60 / pace
        let kmh = 60.0 / targetPace
        // Convert to mph
        let mph = kmh * 0.621371
        
        return String(format: "%.2f", mph)
    }
    
    private func calculateMinutesPerMile() -> String {
        guard targetPace > 0 else {
            return "--"
        }
        
        // Convert min/km to min/mile
        let minutesPerMile = targetPace / 0.621371
        
        // Format as minutes:seconds
        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func decrementDistance() {
        guard optimizationMode != .distance else { return }
        targetDistance = max(AppConstants.Routing.minDistance, targetDistance - 1)
        recalculateFromDistance()
    }
    
    private func incrementDistance() {
        guard optimizationMode != .distance else { return }
        targetDistance = min(AppConstants.Routing.maxDistance, targetDistance + 1)
        recalculateFromDistance()
    }
    
    private func decrementTime() {
        guard optimizationMode != .time else { return }
        targetTime = max(AppConstants.Pace.minTimeMinutes, targetTime - AppConstants.Pace.timeStepMinutes)
        recalculateFromTime()
    }
    
    private func incrementTime() {
        guard optimizationMode != .time else { return }
        targetTime = min(AppConstants.Pace.maxTimeMinutes, targetTime + AppConstants.Pace.timeStepMinutes)
        recalculateFromTime()
    }
    
    private func decrementPace() {
        guard optimizationMode != .pace else { return }
        targetPace = max(3.0, targetPace - 0.5)
        recalculateFromPace()
    }
    
    private func incrementPace() {
        guard optimizationMode != .pace else { return }
        targetPace = min(15.0, targetPace + 0.5)
        recalculateFromPace()
    }
    
    /// Recalculate when distance changed
    private func recalculateFromDistance() {
        guard targetDistance > 0, targetPace > 0 else { return }
        
        switch optimizationMode {
        case .distance:
            // Distance is locked, shouldn't get here
            break
        case .time:
            // Time is locked, recalculate pace from new distance
            // pace = time / distance
            let newPace = targetTime / targetDistance
            targetPace = max(3.0, min(15.0, newPace))
        case .pace:
            // Pace is locked, recalculate time from new distance
            // time = distance * pace
            let newTime = targetDistance * targetPace
            targetTime = max(AppConstants.Pace.minTimeMinutes,
                           min(AppConstants.Pace.maxTimeMinutes, newTime))
        }
    }
    
    /// Recalculate when time changed
    private func recalculateFromTime() {
        guard targetTime > 0, targetDistance > 0 else { return }
        
        switch optimizationMode {
        case .distance:
            // Distance is locked, recalculate pace from new time
            // pace = time / distance
            let newPace = targetTime / targetDistance
            targetPace = max(3.0, min(15.0, newPace))
        case .time:
            // Time is locked, shouldn't get here
            break
        case .pace:
            // Pace is locked, recalculate distance from new time
            // distance = time / pace
            let newDistance = targetTime / targetPace
            targetDistance = max(AppConstants.Routing.minDistance,
                               min(AppConstants.Routing.maxDistance, newDistance))
        }
    }
    
    /// Recalculate when pace changed
    private func recalculateFromPace() {
        guard targetPace > 0, targetDistance > 0 else { return }
        
        switch optimizationMode {
        case .distance:
            // Distance is locked, recalculate time from new pace
            // time = distance * pace
            let newTime = targetDistance * targetPace
            targetTime = max(AppConstants.Pace.minTimeMinutes,
                           min(AppConstants.Pace.maxTimeMinutes, newTime))
        case .time:
            // Time is locked, recalculate distance from new pace
            // distance = time / pace
            let newDistance = targetTime / targetPace
            targetDistance = max(AppConstants.Routing.minDistance,
                               min(AppConstants.Routing.maxDistance, newDistance))
        case .pace:
            // Pace is locked, shouldn't get here
            break
        }
    }
    


    private func startRun() {
        isRunning = true
        locationManager.startTracking()
        
        // Re-generate route now that we're actually running
        // This will update continuously during the run
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
            
            // Regenerate preview after reset
            if let location = self.locationManager.location {
                self.generateRoutePreview(from: location)
            }
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
            return .paceFarOff
        case .slightlySlow, .slightlyFast:
            return .paceSlightlyOff
        case .onPace:
            return .paceOnTrack
        }
    }
}

// MARK: - Supporting Types (from UsabilityComponents.swift)

struct RunStats {
    let distance: Double
    let time: TimeInterval
    let averagePace: Double
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct RunSummaryView: View {
    let stats: RunStats
    let settings: SettingsManager
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.appSuccess)
                    .padding(.top, 40)
                
                Text("Run Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                
                VStack(spacing: 20) {
                    StatRow(
                        icon: "figure.run",
                        label: "Distance",
                        value: formatDistance(stats.distance, settings: settings),
                        color: .appInfo
                    )
                    
                    StatRow(
                        icon: "clock.fill",
                        label: "Time",
                        value: formatTimeInterval(stats.time),
                        color: .appWarning
                    )
                    
                    StatRow(
                        icon: "speedometer",
                        label: "Avg Pace",
                        value: String(format: "%.1f min/km", stats.averagePace),
                        color: .appSuccess
                    )
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.appPrimaryGradient)
                        .cornerRadius(15)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDistance(_ km: Double, settings: SettingsManager) -> String {
        let distance = settings.fromKilometers(km)
        return String(format: "%.2f %@", distance, settings.distanceUnit.abbreviation)
    }
    
    private func formatTimeInterval(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else {
            return String(format: "%dm %ds", minutes, secs)
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(label)
                .font(.body)
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
        }
    }
}

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// MARK: - Route Details Sheet

struct RouteDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let routeDetails: RouteDetails
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    headerStatsSection
                    
                    // Elevation Profile
                    if !routeDetails.elevationProfile.isEmpty {
                        elevationSection
                    }
                    
                    // Turn Information
                    turnsSection
                    
                    // Surface Breakdown
                    surfaceSection
                    
                    // Additional Details
                    additionalDetailsSection
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Route Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appInfo)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerStatsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                RouteStatCardView(
                    icon: "arrow.triangle.turn.up.right.circle.fill",
                    title: "Turns",
                    value: "\(routeDetails.numberOfTurns)",
                    color: .appInfo
                )
                
                RouteStatCardView(
                    icon: "arrow.up.right",
                    title: "Elevation Gain",
                    value: String(format: "%.0fm", routeDetails.totalElevationGain),
                    color: .appSuccess
                )
            }
            
            HStack(spacing: 12) {
                RouteStatCardView(
                    icon: "arrow.down.right",
                    title: "Elevation Loss",
                    value: String(format: "%.0fm", routeDetails.totalElevationLoss),
                    color: .appWarning
                )
                
                RouteStatCardView(
                    icon: "clock.fill",
                    title: "Est. Time",
                    value: formatEstimatedTime(routeDetails.estimatedTime),
                    color: .purple
                )
            }
        }
    }
    
    private var elevationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevation Profile")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Max: \(String(format: "%.0fm", routeDetails.maxElevation))")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    Text("Min: \(String(format: "%.0fm", routeDetails.minElevation))")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Text("Gain: \(String(format: "%.0fm", routeDetails.totalElevationGain)) • Loss: \(String(format: "%.0fm", routeDetails.totalElevationLoss))")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .padding()
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
    
    private var turnsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Turn Information")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 8) {
                TurnRowDetailView(
                    icon: "arrow.turn.up.right",
                    label: "Right Turns",
                    count: routeDetails.rightTurns,
                    color: .appInfo
                )
                
                TurnRowDetailView(
                    icon: "arrow.turn.up.left",
                    label: "Left Turns",
                    count: routeDetails.leftTurns,
                    color: .appSuccess
                )
                
                TurnRowDetailView(
                    icon: "arrow.uturn.forward",
                    label: "Sharp Turns",
                    count: routeDetails.sharpTurns,
                    color: .appWarning
                )
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
    
    private var surfaceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Surface Breakdown")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 12) {
                SurfaceRowDetailView(
                    icon: "road.lanes",
                    label: "Roads",
                    percentage: routeDetails.roadPercentage,
                    color: .appInfo
                )
                
                SurfaceRowDetailView(
                    icon: "figure.hiking",
                    label: "Trails",
                    percentage: routeDetails.trailPercentage,
                    color: .appSuccess
                )
                
                SurfaceRowDetailView(
                    icon: "questionmark.circle",
                    label: "Unknown",
                    percentage: routeDetails.unknownPercentage,
                    color: .appTextSecondary
                )
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
    
    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Details")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 12) {
                DetailRowView(label: "Average Grade", value: String(format: "%.1f%%", routeDetails.averageGrade))
                DetailRowView(label: "Max Grade", value: String(format: "%.1f%%", routeDetails.maxGrade))
                DetailRowView(label: "Difficulty", value: routeDetails.difficulty.rawValue)
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
    
    private func formatEstimatedTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Route Detail Supporting Views

struct RouteStatCardView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct TurnRowDetailView: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.body)
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)
        }
    }
}

struct SurfaceRowDetailView: View {
    let icon: String
    let label: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(label)
                    .font(.body)
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.appTextSecondary.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

struct DetailRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.appTextPrimary)
        }
    }
}

// MARK: - Simple Route Editor
struct SimpleRouteEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var routePlanner: RoutePlanner
    @State private var waypointCount: Int = 4
    @State private var hasChanges = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Instructions
                VStack(spacing: 12) {
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appInfo)
                    
                    Text("Adjust Route Complexity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                    
                    Text("More waypoints = more detailed route")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
                
                // Waypoint count slider
                VStack(spacing: 16) {
                    HStack {
                        Text("Waypoints:")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        
                        Spacer()
                        
                        Text("\(waypointCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appInfo)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(waypointCount) },
                        set: { waypointCount = Int($0) }
                    ), in: 3...12, step: 1)
                    .tint(.appInfo)
                    .onChange(of: waypointCount) { _ in
                        hasChanges = true
                    }
                    
                    HStack {
                        Text("Simple")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text("Detailed")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Info boxes
                VStack(spacing: 12) {
                    InfoRow(
                        icon: "arrow.left.arrow.right",
                        text: "Fewer waypoints = straighter, simpler routes",
                        color: .appSuccess
                    )
                    
                    InfoRow(
                        icon: "arrow.triangle.turn.up.right.circle",
                        text: "More waypoints = curvier, more detailed routes",
                        color: .appInfo
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Apply button
                Button(action: {
                    applyChanges()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Apply Changes")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasChanges ? LinearGradient.appSuccessGradient : LinearGradient.appPrimaryGradient)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appInfo)
                }
            }
        }
        .onAppear {
            waypointCount = routePlanner.currentWaypoints.count
        }
    }
    
    private func applyChanges() {
        // Regenerate route with new waypoint count
        if let location = routePlanner.currentWaypoints.first {
            Task {
                await routePlanner.regenerateRoute(
                    from: location,
                    waypointCount: waypointCount
                )
                
                await MainActor.run {
                    hapticNotification(.success)
                    dismiss()
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
            
            Spacer()
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(10)
    }
}


