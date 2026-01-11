import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routePlanner = RoutePlanner()
    @State private var isRunning = false
    @State private var targetDistance: Double = 5.0 // km

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

                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(String(format: "%.2f km", max(0, targetDistance - locationManager.totalDistance / 1000)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
                .padding()

                Spacer()

                // Bottom Control Panel
                VStack(spacing: 16) {
                    if !isRunning {
                        VStack(spacing: 12) {
                            Text("Target Distance")
                                .font(.headline)

                            HStack {
                                Button(action: {
                                    targetDistance = max(1, targetDistance - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title)
                                }

                                Text(String(format: "%.1f km", targetDistance))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(width: 100)

                                Button(action: {
                                    targetDistance = min(50, targetDistance + 1)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
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
                        .cornerRadius(15)
                    }

                    if isRunning {
                        Text("Follow the blue route on the map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .padding()
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }

    private func startRun() {
        isRunning = true
        locationManager.startTracking()
        routePlanner.startPlanning(
            from: locationManager.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            targetDistance: targetDistance * 1000 // Convert to meters
        )
    }

    private func stopRun() {
        isRunning = false
        locationManager.stopTracking()
        routePlanner.stopPlanning()

        // Show summary or reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            locationManager.reset()
            routePlanner.reset()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
