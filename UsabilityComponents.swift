import SwiftUI
import SwiftUI
import UIKit

// MARK: - Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Distance Preset Button

struct DistancePresetButton: View {
    let title: String
    let distance: Double
    @Binding var currentDistance: Double
    
    var body: some View {
        Button(action: {
            currentDistance = distance
            hapticFeedback(.medium)
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(currentDistance == distance ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(currentDistance == distance ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Run Summary View

struct RunSummaryView: View {
    let stats: RunStats
    let settings: SettingsManager
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                Text("Run Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 20) {
                    StatRow(
                        icon: "figure.run",
                        label: "Distance",
                        value: formatDistance(stats.distance, settings: settings),
                        color: .blue
                    )
                    
                    StatRow(
                        icon: "clock.fill",
                        label: "Time",
                        value: formatTimeInterval(stats.time),
                        color: .orange
                    )
                    
                    StatRow(
                        icon: "speedometer",
                        label: "Avg Pace",
                        value: String(format: "%.1f min/km", stats.averagePace),
                        color: .green
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding()
            }
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
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Haptic Feedback Helper

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}
