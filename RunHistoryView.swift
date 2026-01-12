import SwiftUI
import SwiftData

struct RunHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Run.date, order: .reverse) private var runs: [Run]
    @State private var selectedRun: Run?
    @State private var showingRunDetail = false
    
    var body: some View {
        NavigationView {
            Group {
                if runs.isEmpty {
                    emptyStateView
                } else {
                    runsList
                }
            }
            .navigationTitle("Run History")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingRunDetail) {
            if let run = selectedRun {
                RunDetailView(run: run)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 80))
                .foregroundColor(.appTextSecondary)
            
            Text("No Runs Yet")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            
            Text("Complete your first run to see it here!")
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var runsList: some View {
        List {
            statsSection
            
            Section("Recent Runs") {
                ForEach(runs) { run in
                    RunRowView(run: run)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRun = run
                            showingRunDetail = true
                        }
                }
                .onDelete(perform: deleteRuns)
            }
        }
    }
    
    private var statsSection: some View {
        Section("Summary") {
            HStack {
                StatCard(
                    title: "Total Runs",
                    value: "\(runs.count)",
                    icon: "figure.run",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Distance",
                    value: String(format: "%.1f km", totalDistance),
                    icon: "map",
                    color: .green
                )
            }
            
            HStack {
                StatCard(
                    title: "Total Time",
                    value: formatTotalTime(totalTime),
                    icon: "clock",
                    color: .orange
                )
                
                StatCard(
                    title: "Avg Pace",
                    value: String(format: "%.1f min/km", averagePace),
                    icon: "speedometer",
                    color: .purple
                )
            }
        }
    }
    
    private var totalDistance: Double {
        runs.reduce(0) { $0 + $1.distance } / 1000
    }
    
    private var totalTime: TimeInterval {
        runs.reduce(0) { $0 + $1.duration }
    }
    
    private var averagePace: Double {
        guard !runs.isEmpty else { return 0 }
        return runs.reduce(0) { $0 + $1.averagePace } / Double(runs.count)
    }
    
    private func formatTotalTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        if hours > 0 {
            return "\(hours)h"
        }
        let minutes = Int(seconds / 60)
        return "\(minutes)m"
    }
    
    private func deleteRuns(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(runs[index])
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
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
        .cornerRadius(10)
    }
}

struct RunRowView: View {
    let run: Run
    
    var body: some View {
        HStack {
            Image(systemName: run.workoutType.icon)
                .font(.title2)
                .foregroundColor(.appInfo)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(run.routeName ?? run.workoutType.rawValue)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                
                Text(formatDate(run.date))
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f km", run.distance / 1000))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)
                
                Text(formatDuration(run.duration))
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, secs)
    }
}

struct RunDetailView: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: run.workoutType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.appInfo)
                        
                        Text(run.routeName ?? run.workoutType.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)
                        
                        Text(formatDate(run.date))
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding()
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DetailStatCard(icon: "map", title: "Distance", value: String(format: "%.2f km", run.distance / 1000))
                        DetailStatCard(icon: "clock", title: "Duration", value: formatDuration(run.duration))
                        DetailStatCard(icon: "speedometer", title: "Avg Pace", value: String(format: "%.1f min/km", run.averagePace))
                        DetailStatCard(icon: "flame", title: "Calories", value: "\(run.calories)")
                        
                        if run.elevationGain > 0 {
                            DetailStatCard(icon: "arrow.up", title: "Elevation Gain", value: String(format: "%.0f m", run.elevationGain))
                        }
                        
                        if run.elevationLoss > 0 {
                            DetailStatCard(icon: "arrow.down", title: "Elevation Loss", value: String(format: "%.0f m", run.elevationLoss))
                        }
                    }
                    .padding()
                    
                    // Splits
                    if !run.splits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Splits")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal)
                            
                            ForEach(Array(run.splits.enumerated()), id: \.offset) { index, split in
                                SplitRowView(splitNumber: index + 1, split: split)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Notes
                    if let notes = run.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Weather
                    if let weather = run.weatherCondition {
                        HStack {
                            Image(systemName: "cloud.sun")
                                .foregroundColor(.appTextSecondary)
                            Text(weather)
                                .foregroundColor(.appTextSecondary)
                            if let temp = run.temperature {
                                Text("•")
                                    .foregroundColor(.appTextSecondary)
                                Text(String(format: "%.1f°C", temp))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .font(.caption)
                    }
                }
                .padding(.bottom)
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
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

struct DetailStatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.appInfo)
            
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
        .cornerRadius(10)
    }
}

struct SplitRowView: View {
    let splitNumber: Int
    let split: Split
    
    var body: some View {
        HStack {
            Text("Split \(splitNumber)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.appTextPrimary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text(formatDuration(split.duration))
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(String(format: "%.1f min/km", split.pace))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appInfo)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.appCardBackground)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, secs)
    }
}
