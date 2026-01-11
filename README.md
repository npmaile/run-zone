# Run Route Planner

A native iPhone app that dynamically plans running routes in real-time while you're running.

## Features

- **Real-time Location Tracking**: Uses GPS to track your position accurately during your run
- **Dynamic Route Planning**: Generates a circular route based on your target distance
- **Visual Route Display**: Shows your planned route (blue dashed line) and completed path (green solid line) on an interactive map
- **Customizable Distance**: Select your target distance from 1-50 km
- **Live Statistics**: View distance covered and remaining distance in real-time
- **Background Location**: Continues tracking even when the app is in the background

## How It Works

1. **Set Your Distance**: Choose how far you want to run (default 5km)
2. **Start Running**: Tap "Start Run" to begin tracking
3. **Follow The Route**: A blue dashed line shows your suggested route
4. **Track Progress**: Green line shows where you've been, stats show your progress
5. **Complete Your Run**: The route loops back to your starting point

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **MapKit**: Apple's mapping framework for route visualization
- **CoreLocation**: High-accuracy GPS tracking
- **Combine**: Reactive programming for real-time updates

### Key Components

- `LocationManager.swift`: Handles GPS tracking and distance calculation
- `RoutePlanner.swift`: Generates dynamic circular routes
- `MapView.swift`: Renders the map with route overlays
- `ContentView.swift`: Main UI with controls and statistics

### Route Algorithm

The app generates a circular route with the following characteristics:
- Radius calculated as: `targetDistance / (2 * π)`
- 12 segments for smooth route visualization
- ±20% randomization for route variety
- Loops back to starting point

### Permissions Required

- **Location When In Use**: Required for tracking during active use
- **Background Location**: Optional, for continued tracking when app is backgrounded

## Building The App

### Requirements

- Xcode 15.0 or later
- iOS 15.0 or later
- Valid Apple Developer account (for device deployment)

### Setup

1. Open `RunRoutePlanner.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on a physical device (GPS required)

### Note

This app requires a physical iPhone device with GPS. The iOS Simulator will not provide accurate location data for testing the route planning features.

## Usage Tips

- Start the app in an open area for best GPS accuracy
- Wait a few seconds for GPS to lock before starting your run
- The route updates every 30 seconds to adapt to your actual path
- For best results, try to follow the suggested blue route
- The app works best in areas with good GPS signal (avoid dense urban canyons)

## Future Enhancements

Possible improvements for future versions:
- Multiple route patterns (figure-8, rectangular, out-and-back)
- Route preferences (prefer parks, avoid hills, etc.)
- Save and share routes
- Integration with Health app
- Voice guidance
- Elevation tracking
- Social features

## License

This is a demonstration project created for educational purposes.
