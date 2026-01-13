import SwiftUI
import MapKit
import Charts

// MARK: - Route Details View

struct RouteDetailsView: View {
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
    
    // MARK: - Header Stats
    
    private var headerStatsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "arrow.triangle.turn.up.right.circle.fill",
                    title: "Turns",
                    value: "\(routeDetails.numberOfTurns)",
                    color: .appInfo
                )
                
                RouteStatCard(
                    icon: "arrow.up.right",
                    title: "Elevation Gain",
                    value: String(format: "%.0fm", routeDetails.totalElevationGain),
                    color: .appSuccess
                )
            }
            
            HStack(spacing: 12) {
                RouteStatCard(
                    icon: "arrow.down.right",
                    title: "Elevation Loss",
                    value: String(format: "%.0fm", routeDetails.totalElevationLoss),
                    color: .appWarning
                )
                
                RouteStatCard(
                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                    title: "Est. Time",
                    value: formatEstimatedTime(routeDetails.estimatedTime),
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Elevation Profile
    
    private var elevationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevation Profile")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            if #available(iOS 16.0, *) {
                Chart(routeDetails.elevationProfile) { point in
                    AreaMark(
                        x: .value("Distance", point.distance),
                        y: .value("Elevation", point.elevation)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appInfo.opacity(0.6), Color.appInfo.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Distance", point.distance),
                        y: .value("Elevation", point.elevation)
                    )
                    .foregroundStyle(Color.appInfo)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            } else {
                // Fallback for iOS 15
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
                    
                    Text("Elevation chart requires iOS 16+")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .padding()
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Turns Section
    
    private var turnsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Turn Information")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 8) {
                TurnRowView(
                    icon: "arrow.turn.up.right",
                    label: "Right Turns",
                    count: routeDetails.rightTurns,
                    color: .appInfo
                )
                
                TurnRowView(
                    icon: "arrow.turn.up.left",
                    label: "Left Turns",
                    count: routeDetails.leftTurns,
                    color: .appSuccess
                )
                
                TurnRowView(
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
    
    // MARK: - Surface Section
    
    private var surfaceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Surface Breakdown")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 12) {
                SurfaceRowView(
                    icon: "road.lanes",
                    label: "Roads",
                    percentage: routeDetails.roadPercentage,
                    color: .appInfo
                )
                
                SurfaceRowView(
                    icon: "figure.hiking",
                    label: "Trails",
                    percentage: routeDetails.trailPercentage,
                    color: .appSuccess
                )
                
                SurfaceRowView(
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
    
    // MARK: - Additional Details
    
    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Details")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 12) {
                DetailRow(label: "Average Grade", value: String(format: "%.1f%%", routeDetails.averageGrade))
                DetailRow(label: "Max Grade", value: String(format: "%.1f%%", routeDetails.maxGrade))
                DetailRow(label: "Difficulty", value: routeDetails.difficulty.rawValue)
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    
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

// MARK: - Supporting Views

struct RouteStatCard: View {
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

struct TurnRowView: View {
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

struct SurfaceRowView: View {
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

struct DetailRow: View {
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

// MARK: - Route Details Model

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
// MARK: - Route Options Sheet

/// Sheet for displaying and selecting from multiple route options
struct RouteOptionsSheet: View {
    @ObservedObject var routePlanner: RoutePlanner
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if routePlanner.isGeneratingOptions {
                        loadingView
                    } else if routePlanner.routeOptions.isEmpty {
                        emptyView
                    } else {
                        optionsListView
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Your Route")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appInfo)
            
            Text("Generating route options...")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Text("Creating 4 unique routes for you")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.circle")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No Routes Available")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            
            Text("Unable to generate routes for this location. Try a different distance or location.")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Options List
    
    private var optionsListView: some View {
        VStack(spacing: 16) {
            Text("Select a route style that matches your mood")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            ForEach(routePlanner.routeOptions) { option in
                RouteOptionCard(
                    option: option,
                    isSelected: routePlanner.selectedRouteOption?.id == option.id,
                    onSelect: {
                        routePlanner.selectRouteOption(option)
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                )
            }
        }
    }
}

// MARK: - Route Option Card

struct RouteOptionCard: View {
    let option: RouteOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and name
                HStack {
                    Image(systemName: option.strategy.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .appInfo)
                        .frame(width: 40, height: 40)
                        .background(isSelected ? Color.appInfo : Color.appInfo.opacity(0.15))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.strategy.rawValue)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .appTextPrimary)
                        
                        Text(option.strategy.description)
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.9) : .appTextSecondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                Divider()
                    .background(isSelected ? .white.opacity(0.3) : .appTextSecondary.opacity(0.2))
                
                // Stats
                HStack(spacing: 20) {
                    RouteStatItem(
                        icon: "arrow.left.and.right",
                        value: String(format: "%.1f km", option.estimatedDistance / 1000),
                        label: "Distance",
                        isSelected: isSelected
                    )
                    
                    RouteStatItem(
                        icon: "figure.run",
                        value: "\(option.waypointCount)",
                        label: "Waypoints",
                        isSelected: isSelected
                    )
                    
                    RouteStatItem(
                        icon: "gauge.with.dots.needle.bottom.50percent",
                        value: option.complexity,
                        label: "Complexity",
                        isSelected: isSelected
                    )
                }
            }
            .padding()
            .background(
                isSelected 
                    ? LinearGradient.appPrimaryGradient
                    : LinearGradient(colors: [Color.appCardBackground], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(16)
            .shadow(color: isSelected ? Color.appInfo.opacity(0.3) : Color.appShadow, radius: isSelected ? 10 : 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.appInfo : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Route Stat Item

struct RouteStatItem: View {
    let icon: String
    let value: String
    let label: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .appInfo)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .appTextPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(isSelected ? .white.opacity(0.7) : .appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

