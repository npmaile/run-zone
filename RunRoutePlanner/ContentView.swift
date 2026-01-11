import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routePlanner = RoutePlanner()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var isRunning = false
    @State private var targetDistance: Double = AppConstants.Routing.defaultDistance
    @State private var showSubscription = false

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

                    // Subscription badge
                    if !subscriptionManager.isSubscribed {
                        Button(action: {
                            showSubscription = true
                        }) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .padding(8)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(AppConstants.UI.statsCornerRadius)
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
                                    targetDistance = max(AppConstants.Routing.minDistance, targetDistance - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title)
                                }

                                Text(String(format: "%.1f km", targetDistance))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(width: 100)

                                Button(action: {
                                    targetDistance = min(AppConstants.Routing.maxDistance, targetDistance + 1)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(AppConstants.UI.cornerRadius)
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
                        .cornerRadius(AppConstants.UI.cornerRadius)
                    }

                    if isRunning {
                        Text("Follow the blue route on the map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(AppConstants.UI.controlsCornerRadius)
                .padding()
            }
        }
        .onAppear {
            locationManager.requestPermission()

            // Show subscription paywall if not subscribed
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.UI.paywallDelay) {
                if !subscriptionManager.isSubscribed {
                    showSubscription = true
                }
            }
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView(isPresented: $showSubscription)
        }
    }

    private func startRun() {
        // Check subscription before starting
        guard subscriptionManager.isSubscribed else {
            showSubscription = true
            return
        }

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
