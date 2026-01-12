import Foundation
import CoreLocation
import MapKit
import Combine

// MARK: - Route Generation Strategy

enum RouteStrategy: String, CaseIterable, Identifiable {
    case balanced = "Balanced"
    case scenic = "Scenic"
    case direct = "Direct"
    case varied = "Varied"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .balanced: return "circle.hexagongrid"
        case .scenic: return "leaf.fill"
        case .direct: return "arrow.triangle.2.circlepath"
        case .varied: return "chart.bar.fill"
        }
    }
    
    var description: String {
        switch self {
        case .balanced: return "Mix of turns and straightaways"
        case .scenic: return "More waypoints, varied path"
        case .direct: return "Fewer turns, efficient route"
        case .varied: return "Maximum variety, explore"
        }
    }
    
    var waypointMultiplier: Double {
        switch self {
        case .balanced: return 1.0
        case .scenic: return 1.5
        case .direct: return 0.7
        case .varied: return 1.8
        }
    }
    
    var radiusVariation: Double {
        switch self {
        case .balanced: return 0.1
        case .scenic: return 0.25
        case .direct: return 0.05
        case .varied: return 0.35
        }
    }
}

// MARK: - Route Option

struct RouteOption: Identifiable, Hashable {
    let id = UUID()
    let strategy: RouteStrategy
    let waypoints: [CLLocationCoordinate2D]
    let coordinates: [CLLocationCoordinate2D]
    let estimatedDistance: Double // meters
    let waypointCount: Int
    let complexity: String // "Low", "Medium", "High"
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RouteOption, rhs: RouteOption) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Route Details Models

struct RouteDetails {
    // Distance and turns
    let numberOfTurns: Int
    let rightTurns: Int
    let leftTurns: Int
    let sharpTurns: Int
    
    // Elevation
    let elevationProfile: [ElevationPoint]
    let totalElevationGain: Double
    let totalElevationLoss: Double
    let maxElevation: Double
    let minElevation: Double
    let averageGrade: Double
    let maxGrade: Double
    
    // Surface types
    let roadPercentage: Double
    let trailPercentage: Double
    let unknownPercentage: Double
    
    // Difficulty
    let difficulty: RouteDifficulty
    
    // Estimated time (based on 6 min/km base pace + adjustments)
    let estimatedTime: TimeInterval
}

struct ElevationPoint: Identifiable {
    let id = UUID()
    let distance: Double // km
    let elevation: Double // meters
}

enum RouteDifficulty: String {
    case easy = "Easy"
    case moderate = "Moderate"
    case challenging = "Challenging"
    case hard = "Hard"
}

// MARK: - Route Planner

/// Manages dynamic route planning using MapKit Directions API
/// Generates circular routes that follow roads and paths
class RoutePlanner: ObservableObject {
    // MARK: - Published Properties
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var currentWaypoints: [CLLocationCoordinate2D] = []
    @Published var isLoadingRoute = false
    @Published var routeError: String?
    @Published var isReversed: Bool = false
    @Published var routeDetails: RouteDetails?
    @Published var routeOptions: [RouteOption] = []
    @Published var selectedRouteOption: RouteOption?
    @Published var isGeneratingOptions = false

    // MARK: - Private Properties
    private var startLocation: CLLocationCoordinate2D?
    private var targetDistance: Double = 0
    private var timer: Timer?
    private var routeTask: Task<Void, Never>?
    private var currentRouteSteps: [MKRoute.Step] = []

    // MARK: - Public Methods
    
    /// Generates multiple route options for the user to choose from
    /// - Parameters:
    ///   - location: Starting location coordinate
    ///   - targetDistance: Desired total distance in meters
    func generateRouteOptions(from location: CLLocationCoordinate2D, targetDistance: Double) async {
        await MainActor.run {
            isGeneratingOptions = true
            routeOptions = []
        }
        
        self.startLocation = location
        self.targetDistance = targetDistance
        
        var options: [RouteOption] = []
        
        // Generate routes for each strategy
        for strategy in RouteStrategy.allCases {
            if let option = await generateRouteOption(
                from: location,
                targetDistance: targetDistance,
                strategy: strategy
            ) {
                options.append(option)
            }
        }
        
        await MainActor.run {
            self.routeOptions = options
            // Auto-select balanced option
            if let balanced = options.first(where: { $0.strategy == .balanced }) {
                selectRouteOption(balanced)
            }
            isGeneratingOptions = false
        }
    }
    
    /// Selects a route option and makes it the current route
    func selectRouteOption(_ option: RouteOption) {
        selectedRouteOption = option
        currentRoute = option.coordinates
        currentWaypoints = option.waypoints
    }

    /// Starts planning a circular route from the given location
    /// - Parameters:
    ///   - location: Starting location coordinate
    ///   - targetDistance: Desired total distance in meters
    func startPlanning(from location: CLLocationCoordinate2D, targetDistance: Double) {
        self.startLocation = location
        self.targetDistance = targetDistance

        // Generate initial route
        generateRoute(from: location)

        // Update route periodically
        timer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Routing.routeUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self, let start = self.startLocation else { return }
            self.generateRoute(from: start)
        }
    }

    /// Stops route planning and cancels ongoing tasks
    func stopPlanning() {
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
        isLoadingRoute = false
    }

    /// Resets all route planning state
    func reset() {
        currentRoute = []
        currentWaypoints = []
        startLocation = nil
        targetDistance = 0
        isReversed = false
        timer?.invalidate()
        timer = nil
        routeTask?.cancel()
        routeTask = nil
        isLoadingRoute = false
        routeError = nil
    }
    
    /// Toggles the direction of the route
    func toggleDirection() {
        isReversed.toggle()
        if !currentRoute.isEmpty {
            currentRoute.reverse()
        }
        if !currentWaypoints.isEmpty {
            currentWaypoints.reverse()
        }
    }
    
    /// Updates waypoints with manually edited coordinates
    func updateWaypoints(_ newWaypoints: [CLLocationCoordinate2D]) {
        currentWaypoints = newWaypoints
        
        // Regenerate route with new waypoints
        Task {
            await MainActor.run { isLoadingRoute = true }
            
            if let routeCoordinates = await fetchDirectionsRoute(waypoints: newWaypoints) {
                await updateRoute(routeCoordinates, error: nil)
            } else {
                let fallbackRoute = createGeometricRoute(waypoints: newWaypoints)
                await updateRoute(fallbackRoute, error: "Using simplified route")
            }
            
            await MainActor.run { isLoadingRoute = false }
        }
    }
    
    /// Regenerates route with a specific number of waypoints
    func regenerateRoute(from location: CLLocationCoordinate2D, waypointCount: Int) async {
        await MainActor.run { isLoadingRoute = true }
        
        // Generate new waypoints with custom count
        let waypoints = generateWaypoints(
            center: location,
            targetDistance: targetDistance,
            customWaypointCount: waypointCount
        )
        await MainActor.run { currentWaypoints = waypoints }
        
        if let routeCoordinates = await fetchDirectionsRoute(waypoints: waypoints) {
            await updateRoute(routeCoordinates, error: nil)
        } else {
            let fallbackRoute = createGeometricRoute(waypoints: waypoints)
            await updateRoute(fallbackRoute, error: "Using simplified route")
        }
        
        await MainActor.run { isLoadingRoute = false }
    }

    // MARK: - Private Methods

    private func generateRoute(from location: CLLocationCoordinate2D) {
        routeTask?.cancel()

        routeTask = Task {
            await MainActor.run { isLoadingRoute = true }

            let waypoints = generateWaypoints(center: location, targetDistance: targetDistance)
            await MainActor.run { currentWaypoints = waypoints }

            if let routeCoordinates = await fetchDirectionsRoute(waypoints: waypoints) {
                await updateRoute(routeCoordinates, error: nil)
            } else {
                // Only show fallback for very long routes
                let distanceKm = targetDistance / 1000
                if distanceKm > 15 {
                    await updateRoute([], error: "Route too long for this area. Try a shorter distance.")
                } else {
                    let fallbackRoute = createGeometricRoute(waypoints: waypoints)
                    await updateRoute(fallbackRoute, error: "Limited route data available")
                }
            }

            await MainActor.run { isLoadingRoute = false }
        }
    }

    @MainActor
    private func updateRoute(_ route: [CLLocationCoordinate2D], error: String?) {
        currentRoute = route
        routeError = error
    }
    
    // MARK: - Multiple Route Generation
    
    /// Generates a single route option based on strategy
    private func generateRouteOption(
        from location: CLLocationCoordinate2D,
        targetDistance: Double,
        strategy: RouteStrategy
    ) async -> RouteOption? {
        let waypoints = generateWaypoints(
            center: location,
            targetDistance: targetDistance,
            strategy: strategy
        )
        
        guard let coordinates = await fetchDirectionsRoute(waypoints: waypoints) else {
            // Fallback to geometric route if directions fail
            let coordinates = createGeometricRoute(waypoints: waypoints)
            guard !coordinates.isEmpty else { return nil }
            
            return RouteOption(
                strategy: strategy,
                waypoints: waypoints,
                coordinates: coordinates,
                estimatedDistance: targetDistance,
                waypointCount: waypoints.count - 2, // Exclude start and end
                complexity: complexityLevel(for: waypoints.count - 2)
            )
        }
        
        // Calculate actual distance
        let actualDistance = calculateRouteDistance(coordinates)
        
        return RouteOption(
            strategy: strategy,
            waypoints: waypoints,
            coordinates: coordinates,
            estimatedDistance: actualDistance,
            waypointCount: waypoints.count - 2,
            complexity: complexityLevel(for: waypoints.count - 2)
        )
    }
    
    /// Calculates complexity level based on waypoint count
    private func complexityLevel(for waypointCount: Int) -> String {
        switch waypointCount {
        case 0...4: return "Low"
        case 5...8: return "Medium"
        default: return "High"
        }
    }
    
    /// Calculates total distance of a route
    private func calculateRouteDistance(_ coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<(coordinates.count - 1) {
            let location1 = CLLocation(
                latitude: coordinates[i].latitude,
                longitude: coordinates[i].longitude
            )
            let location2 = CLLocation(
                latitude: coordinates[i + 1].latitude,
                longitude: coordinates[i + 1].longitude
            )
            totalDistance += location1.distance(from: location2)
        }
        return totalDistance
    }

    /// Generates waypoints based on strategy
    private func generateWaypoints(
        center: CLLocationCoordinate2D,
        targetDistance: Double,
        strategy: RouteStrategy
    ) -> [CLLocationCoordinate2D] {
        let radius = targetDistance / (2 * .pi)
        let radiusInDegrees = radius / AppConstants.Routing.metersPerDegree

        var waypoints: [CLLocationCoordinate2D] = [center]

        // Calculate waypoint count based on strategy
        let baseWaypointCount = max(AppConstants.Routing.waypointCount, Int(targetDistance / 2000))
        let adjustedCount = Int(Double(baseWaypointCount) * strategy.waypointMultiplier)
        let clampedWaypointCount = min(adjustedCount, 12)

        // Generate waypoints with strategy-specific variations
        for i in 1...clampedWaypointCount {
            let angle = 2 * .pi * Double(i) / Double(clampedWaypointCount)
            
            // Add radius variation based on strategy
            let radiusVariation = 1.0 + (Double.random(in: -1...1) * strategy.radiusVariation)
            let adjustedRadius = radiusInDegrees * radiusVariation
            
            // Add angle offset for more variety
            let angleOffset = strategy == .varied ? Double.random(in: -0.3...0.3) : 0
            let adjustedAngle = angle + angleOffset
            
            let lat = center.latitude + adjustedRadius * cos(adjustedAngle)
            let lon = center.longitude + adjustedRadius * sin(adjustedAngle) / cos(center.latitude * .pi / 180)
            
            waypoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        waypoints.append(center)
        return waypoints
    }

    /// Generates waypoints in a circular pattern around the center
    private func generateWaypoints(
        center: CLLocationCoordinate2D,
        targetDistance: Double,
        customWaypointCount: Int? = nil
    ) -> [CLLocationCoordinate2D] {
        let radius = targetDistance / (2 * .pi)
        let radiusInDegrees = radius / AppConstants.Routing.metersPerDegree

        var waypoints: [CLLocationCoordinate2D] = [center]

        // Use custom count if provided, otherwise calculate based on distance
        let waypointCount: Int
        if let customCount = customWaypointCount {
            waypointCount = customCount
        } else {
            waypointCount = max(AppConstants.Routing.waypointCount, Int(targetDistance / 2000))
        }
        let clampedWaypointCount = min(waypointCount, 12) // Cap at 12 to avoid too many API calls

        for i in 1...clampedWaypointCount {
            let angle = 2 * .pi * Double(i) / Double(clampedWaypointCount)
            let lat = center.latitude + radiusInDegrees * cos(angle)
            let lon = center.longitude + radiusInDegrees * sin(angle) / cos(center.latitude * .pi / 180)
            waypoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        waypoints.append(center)
        return waypoints
    }

    /// Fetches walking directions between waypoints using MapKit
    private func fetchDirectionsRoute(
        waypoints: [CLLocationCoordinate2D]
    ) async -> [CLLocationCoordinate2D]? {
        var allCoordinates: [CLLocationCoordinate2D] = []
        var allSteps: [MKRoute.Step] = []
        var failedSegments = 0
        let maxFailures = waypoints.count / 3 // Allow up to 1/3 of segments to fail

        for i in 0..<(waypoints.count - 1) {
            guard !Task.isCancelled else { return nil }

            let source = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i]))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: waypoints[i + 1]))

            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .walking
            request.requestsAlternateRoutes = false

            do {
                let response = try await MKDirections(request: request).calculate()
                guard let route = response.routes.first else {
                    failedSegments += 1
                    // Add straight line segment as fallback for this one segment
                    let segmentCoords = interpolateSegment(from: waypoints[i], to: waypoints[i + 1])
                    allCoordinates.append(contentsOf: segmentCoords)
                    continue
                }

                let coordinates = extractCoordinates(from: route.polyline)
                allCoordinates.append(contentsOf: coordinates)
                
                // Store route steps for analysis
                allSteps.append(contentsOf: route.steps)
            } catch {
                print("Directions request failed for segment \(i): \(error.localizedDescription)")
                failedSegments += 1
                
                // If too many segments fail, give up on this route
                if failedSegments > maxFailures {
                    return nil
                }
                
                // Add straight line segment as fallback
                let segmentCoords = interpolateSegment(from: waypoints[i], to: waypoints[i + 1])
                allCoordinates.append(contentsOf: segmentCoords)
            }
        }

        // Store steps for route analysis
        await MainActor.run {
            self.currentRouteSteps = allSteps
        }
        
        // If we got mostly real routes, return the mix of real + fallback segments
        return allCoordinates.isEmpty ? nil : allCoordinates
    }
    
    /// Interpolates a straight line segment between two points
    private func interpolateSegment(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        let steps = 5 // Fewer steps than full geometric route
        
        for j in 0...steps {
            let fraction = Double(j) / Double(steps)
            let lat = start.latitude + (end.latitude - start.latitude) * fraction
            let lon = start.longitude + (end.longitude - start.longitude) * fraction
            coords.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return coords
    }

    /// Extracts coordinates from an MKPolyline
    private func extractCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let pointCount = polyline.pointCount
        let points = polyline.points()
        return (0..<pointCount).map { points[$0].coordinate }
    }

    /// Creates a fallback geometric route when directions are unavailable
    private func createGeometricRoute(waypoints: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var route: [CLLocationCoordinate2D] = []

        for i in 0..<(waypoints.count - 1) {
            let start = waypoints[i]
            let end = waypoints[i + 1]

            for j in 0...AppConstants.Routing.interpolationPoints {
                let fraction = Double(j) / Double(AppConstants.Routing.interpolationPoints)
                let lat = start.latitude + (end.latitude - start.latitude) * fraction
                let lon = start.longitude + (end.longitude - start.longitude) * fraction
                route.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }

        return route
    }
    
    // MARK: - Route Analysis
    
    /// Analyzes the current route and generates detailed statistics
    func analyzeRoute() async -> RouteDetails? {
        guard !currentRoute.isEmpty else { return nil }
        
        // Analyze turns
        let turnData = analyzeTurns()
        
        // Analyze elevation
        let elevationData = await analyzeElevation()
        
        // Analyze surface types
        let surfaceData = analyzeSurface()
        
        // Calculate difficulty
        let difficulty = calculateDifficulty(
            elevationGain: elevationData.gain,
            maxGrade: elevationData.maxGrade,
            turns: turnData.total
        )
        
        // Estimate time (base 6 min/km + adjustments for elevation and turns)
        let baseTime = (targetDistance / 1000) * 6 * 60 // 6 min/km in seconds
        let elevationAdjustment = elevationData.gain * 0.5 // +0.5 sec per meter of gain
        let turnAdjustment = Double(turnData.total) * 2 // +2 sec per turn
        let estimatedTime = baseTime + elevationAdjustment + turnAdjustment
        
        return RouteDetails(
            numberOfTurns: turnData.total,
            rightTurns: turnData.right,
            leftTurns: turnData.left,
            sharpTurns: turnData.sharp,
            elevationProfile: elevationData.profile,
            totalElevationGain: elevationData.gain,
            totalElevationLoss: elevationData.loss,
            maxElevation: elevationData.max,
            minElevation: elevationData.min,
            averageGrade: elevationData.avgGrade,
            maxGrade: elevationData.maxGrade,
            roadPercentage: surfaceData.road,
            trailPercentage: surfaceData.trail,
            unknownPercentage: surfaceData.unknown,
            difficulty: difficulty,
            estimatedTime: estimatedTime
        )
    }
    
    private func analyzeTurns() -> (total: Int, right: Int, left: Int, sharp: Int) {
        var rightTurns = 0
        var leftTurns = 0
        var sharpTurns = 0
        
        // Analyze bearing changes between route segments
        for i in stride(from: 20, to: currentRoute.count - 20, by: 20) {
            let before = currentRoute[i - 20]
            let current = currentRoute[i]
            let after = currentRoute[i + 20]
            
            let bearing1 = calculateBearing(from: before, to: current)
            let bearing2 = calculateBearing(from: current, to: after)
            
            var angleDiff = bearing2 - bearing1
            if angleDiff > 180 { angleDiff -= 360 }
            if angleDiff < -180 { angleDiff += 360 }
            
            if abs(angleDiff) > 30 { // Significant turn
                if angleDiff > 0 {
                    rightTurns += 1
                } else {
                    leftTurns += 1
                }
                
                if abs(angleDiff) > 90 {
                    sharpTurns += 1
                }
            }
        }
        
        return (rightTurns + leftTurns, rightTurns, leftTurns, sharpTurns)
    }
    
    private func analyzeElevation() async -> (profile: [ElevationPoint], gain: Double, loss: Double, max: Double, min: Double, avgGrade: Double, maxGrade: Double) {
        var profile: [ElevationPoint] = []
        var totalGain: Double = 0
        var totalLoss: Double = 0
        var maxElevation: Double = -Double.infinity
        var minElevation: Double = Double.infinity
        var maxGrade: Double = 0
        var totalDistance: Double = 0
        
        // Sample every 50 points for elevation
        for i in stride(from: 0, to: currentRoute.count, by: 50) {
            let coord = currentRoute[i]
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            
            // In real app, would use elevation API. For now, simulate based on lat/long
            // This is a placeholder - actual implementation would fetch real elevation data
            let elevation = simulateElevation(for: coord)
            
            if i > 0 {
                let prevCoord = currentRoute[i - 50 < 0 ? 0 : i - 50]
                let prevLocation = CLLocation(latitude: prevCoord.latitude, longitude: prevCoord.longitude)
                let distance = location.distance(from: prevLocation)
                totalDistance += distance
                
                let prevElevation = profile.last?.elevation ?? elevation
                let elevChange = elevation - prevElevation
                
                if elevChange > 0 {
                    totalGain += elevChange
                } else {
                    totalLoss += abs(elevChange)
                }
                
                // Calculate grade
                if distance > 0 {
                    let grade = abs(elevChange / distance) * 100
                    maxGrade = max(maxGrade, grade)
                }
            }
            
            maxElevation = max(maxElevation, elevation)
            minElevation = min(minElevation, elevation)
            
            profile.append(ElevationPoint(
                distance: totalDistance / 1000, // Convert to km
                elevation: elevation
            ))
        }
        
        let avgGrade = totalDistance > 0 ? (totalGain / totalDistance) * 100 : 0
        
        return (profile, totalGain, totalLoss, maxElevation, minElevation, avgGrade, maxGrade)
    }
    
    private func simulateElevation(for coordinate: CLLocationCoordinate2D) -> Double {
        // Placeholder: In production, use Apple's elevation API or third-party service
        // For now, create a simple sine wave pattern for demonstration
        let x = coordinate.latitude * 1000
        let y = coordinate.longitude * 1000
        return 50 + sin(x) * 30 + cos(y) * 20
    }
    
    private func analyzeSurface() -> (road: Double, trail: Double, unknown: Double) {
        // Analyze route steps for surface types
        var roadDistance: Double = 0
        var trailDistance: Double = 0
        var unknownDistance: Double = 0
        
        for step in currentRouteSteps {
            let distance = step.distance
            
            // Check instructions for keywords
            let instructions = step.instructions.lowercased()
            if instructions.contains("trail") || instructions.contains("path") {
                trailDistance += distance
            } else if instructions.contains("road") || instructions.contains("street") || instructions.contains("avenue") {
                roadDistance += distance
            } else {
                unknownDistance += distance
            }
        }
        
        let total = max(roadDistance + trailDistance + unknownDistance, 1) // Avoid division by zero
        
        // If we don't have step data, assume 70% road, 30% unknown
        if currentRouteSteps.isEmpty {
            return (70.0, 0.0, 30.0)
        }
        
        return (
            (roadDistance / total) * 100,
            (trailDistance / total) * 100,
            (unknownDistance / total) * 100
        )
    }
    
    private func calculateDifficulty(elevationGain: Double, maxGrade: Double, turns: Int) -> RouteDifficulty {
        // Simple difficulty calculation based on multiple factors
        var score = 0
        
        // Elevation gain points
        if elevationGain > 200 { score += 3 }
        else if elevationGain > 100 { score += 2 }
        else if elevationGain > 50 { score += 1 }
        
        // Grade points
        if maxGrade > 15 { score += 3 }
        else if maxGrade > 10 { score += 2 }
        else if maxGrade > 5 { score += 1 }
        
        // Turns points
        if turns > 20 { score += 2 }
        else if turns > 10 { score += 1 }
        
        switch score {
        case 0...2: return .easy
        case 3...4: return .moderate
        case 5...6: return .challenging
        default: return .hard
        }
    }
    
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}
