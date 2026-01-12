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
