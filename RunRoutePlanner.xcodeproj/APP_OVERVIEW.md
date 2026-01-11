# Run Route Planner - App Overview

## What This App Does

This is a **Run Route Planner** app that dynamically generates circular running routes and provides turn-by-turn voice navigation with pace coaching. **All features are completely free!**

## Key Features

1. **Dynamic Route Planning**: Generates circular running routes based on your target distance
2. **GPS Tracking**: Tracks your location and running path in real-time
3. **Turn-by-Turn Navigation**: Voice guidance to help you follow the planned route
4. **Pace Coaching**: Real-time feedback to help you meet your time goals
5. **Completely Free**: No subscriptions or in-app purchases required!

## How to Use

### First Launch
1. Grant location permissions when prompted
2. You're ready to start planning runs immediately!

### Planning a Run
1. Use the **+/- buttons** to set your target distance (1-50 km)
2. Use the **+/- buttons** to set your target time (5-300 minutes)
3. Toggle **Voice Guidance** on/off for turn-by-turn directions
4. Toggle **Pace Coaching** on/off for pace feedback

### Starting a Run
1. Tap **"Start Run"**
2. The app will generate a circular route from your current location
3. Follow the blue dashed line on the map
4. Voice guidance will tell you when to turn
5. Pace coaching will let you know if you're too fast/slow

### During a Run
- **Top panel** shows: Distance, Time, and Current Pace
- **Pace color coding**:
  - 🟢 Green = On pace
  - 🟠 Orange = Slightly off pace
  - 🔴 Red = Significantly off pace
- The **green path** on the map shows where you've been
- The **blue dashed path** shows where you should go

### Stopping a Run
1. Tap **"Stop Run"**
2. Your stats will be displayed briefly
3. After 1 second, the app resets for a new run

## Technical Requirements

- **iOS 17.0+** required
- **Location permissions** must be granted
- **Active subscription** required to use running features
- **Network connection** recommended for optimal routing

## Testing the App

### Testing Without Subscription
If you're testing in development, you may want to temporarily bypass the subscription requirement by:
1. Modifying the `startRun()` method in ContentView.swift
2. Commenting out the subscription check temporarily

### Testing Location
- Use Xcode's location simulation to test without actually running
- Try "City Run" or "Freeway Drive" from the simulator location options

### Testing StoreKit
- Use the Configuration.storekit file for testing in-app purchases
- Enable StoreKit testing in Xcode scheme settings

## Known Limitations

1. Routes are generated as circles around your starting point
2. Routes may not always follow ideal running paths (depends on available roads/paths)
3. Voice guidance requires device volume to be on
4. GPS accuracy affects tracking quality
5. Background tracking may drain battery faster

## Architecture

- **ContentView**: Main UI and app coordination
- **LocationManager**: GPS tracking and distance calculation
- **RoutePlanner**: Route generation using MapKit Directions
- **NavigationManager**: Turn-by-turn voice guidance and pace coaching
- **SubscriptionManager**: StoreKit integration for premium features
- **MapView**: Custom map display with route overlays
