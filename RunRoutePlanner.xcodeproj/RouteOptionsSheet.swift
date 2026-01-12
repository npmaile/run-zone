import SwiftUI
import MapKit

struct RouteOptionsSheet: View {
    @ObservedObject var routePlanner: RoutePlanner
    @Environment(\.dismiss) var dismiss
    @State private var selectedOption: RouteOption?
    
    var body: some View {
        NavigationView {
            ZStack {
                if routePlanner.isGeneratingOptions {
                    loadingView
                } else if routePlanner.routeOptions.isEmpty {
                    emptyStateView
                } else {
                    routeOptionsListView
                }
            }
            .navigationTitle("Choose Your Route")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                if !routePlanner.routeOptions.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Select") {
                            if let selected = selectedOption {
                                routePlanner.selectRouteOption(selected)
                            }
                            dismiss()
                        }
                        .disabled(selectedOption == nil)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            selectedOption = routePlanner.selectedRouteOption
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appInfo)
            
            Text("Generating Routes...")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Text("Creating multiple route options for you")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            
            Text("No Routes Available")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            
            Text("Unable to generate route options for this location")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Route Options List
    
    private var routeOptionsListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Tap a route to preview, then select your favorite")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ForEach(routePlanner.routeOptions) { option in
                    RouteOptionCard(
                        option: option,
                        isSelected: selectedOption?.id == option.id,
                        onTap: {
                            selectedOption = option
                            // Preview the route on map
                            routePlanner.selectRouteOption(option)
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Route Option Card

struct RouteOptionCard: View {
    let option: RouteOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: option.strategy.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .appInfo)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(option.strategy.rawValue)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .appTextPrimary)
                        
                        Text(option.strategy.description)
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .appTextSecondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                Divider()
                    .background(isSelected ? .white.opacity(0.3) : .appTextSecondary.opacity(0.3))
                
                // Stats
                HStack(spacing: 20) {
                    statItem(
                        icon: "arrow.left.and.right",
                        label: "Distance",
                        value: String(format: "%.1f km", option.estimatedDistance / 1000)
                    )
                    
                    statItem(
                        icon: "map",
                        label: "Waypoints",
                        value: "\(option.waypointCount)"
                    )
                    
                    statItem(
                        icon: "chart.bar",
                        label: "Complexity",
                        value: option.complexity
                    )
                }
                
                // Preview hint
                if !isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption2)
                        Text("Tap to preview on map")
                            .font(.caption2)
                    }
                    .foregroundColor(.appTextSecondary)
                    .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          LinearGradient.appSuccessGradient : 
                          LinearGradient(colors: [Color.appCardBackground], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appSuccess : Color.appTextSecondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color.appSuccess.opacity(0.3) : Color.appShadow, radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func statItem(icon: String, label: String, value: String) -> some View {
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
