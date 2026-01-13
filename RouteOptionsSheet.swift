import SwiftUI
import MapKit

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
                    StatItem(
                        icon: "arrow.left.and.right",
                        value: String(format: "%.1f km", option.estimatedDistance / 1000),
                        label: "Distance",
                        isSelected: isSelected
                    )
                    
                    StatItem(
                        icon: "figure.run",
                        value: "\(option.waypointCount)",
                        label: "Waypoints",
                        isSelected: isSelected
                    )
                    
                    StatItem(
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

// MARK: - Stat Item

struct StatItem: View {
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

// MARK: - Preview

#Preview {
    RouteOptionsSheet(routePlanner: RoutePlanner())
}
