# RunZone - Project Architecture

## Overview
RunZone is a circular running route planner iOS app that generates customizable routes, provides real-time tracking, voice navigation, and detailed route analytics.

## Architecture Pattern
**MVVM (Model-View-ViewModel) with Observable Objects**
- **Models**: Data structures (Route, Run, Settings)
- **Views**: SwiftUI views (ContentView, RouteDetailsSheet, etc.)
- **ViewModels**: Observable managers (RoutePlanner, LocationManager, NavigationManager)
- **Services**: Utility services (HealthKit, Analytics)

## Project Structure

```
RunZone/
├── App/
│   ├── RunZoneApp.swift              # App entry point
│   └── Info.plist                     # App configuration
│
├── Core/
│   ├── Models/
│   │   ├── RouteModels.swift         # RouteDetails, ElevationPoint, RouteDifficulty
│   │   ├── RunModels.swift           # Run, Split, WorkoutType (SwiftData)
│   │   └── SettingsModels.swift      # SettingsManager, DistanceUnit
│   │
│   ├── Managers/
│   │   ├── RoutePlanner.swift        # Route generation & planning
│   │   ├── LocationManager.swift     # GPS tracking & location services
│   │   ├── NavigationManager.swift   # Turn-by-turn navigation & pace coaching
│   │   └── HealthKitManager.swift    # HealthKit integration
│   │
│   └── Constants/
│       ├── AppConstants.swift        # App-wide constants
│       └── AppColors.swift           # Color scheme & theming
│
├── Features/
│   ├── Main/
│   │   ├── Views/
│   │   │   ├── ContentView.swift              # Main app screen
│   │   │   ├── MapView.swift                  # Map display with routes
│   │   │   └── Components/
│   │   │       ├── StatsPanel.swift           # Running stats display
│   │   │       ├── ControlPanel.swift         # Distance/time controls
│   │   │       └── RunSummaryView.swift       # Post-run summary
│   │   │
│   │   └── ViewModels/
│   │       └── ContentViewModel.swift         # Main screen logic (if needed)
│   │
│   ├── RouteDetails/
│   │   └── Views/
│   │       ├── RouteDetailsSheet.swift        # Route analysis view
│   │       └── Components/
│   │           ├── ElevationSection.swift     # Elevation profile
│   │           ├── TurnsSection.swift         # Turn information
│   │           └── SurfaceSection.swift       # Surface breakdown
│   │
│   ├── RouteEditor/
│   │   └── Views/
│   │       └── SimpleRouteEditorSheet.swift   # Route customization
│   │
│   ├── RunHistory/
│   │   └── Views/
│   │       ├── RunHistoryView.swift           # List of past runs
│   │       └── RunDetailView.swift            # Individual run details
│   │
│   └── Settings/
│       └── Views/
│           └── SettingsView.swift             # App settings
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/               # App icons
│   │   └── Colors/                           # Color assets
│   │
│   └── Localization/
│       └── en.lproj/                         # English strings (future)
│
└── Documentation/
    ├── Architecture/
    │   ├── PROJECT_STRUCTURE.md              # This file
    │   ├── ARCHITECTURE_DECISIONS.md         # Key decisions & rationale
    │   └── DATA_FLOW.md                      # How data flows through app
    │
    ├── Features/
    │   ├── ROUTE_PLANNING.md                 # Route generation system
    │   ├── NAVIGATION.md                     # Turn-by-turn navigation
    │   ├── ROUTE_EDITING.md                  # Route customization
    │   ├── ROUTE_DETAILS.md                  # Route analysis
    │   ├── TRACKING.md                       # GPS tracking
    │   └── DARK_MODE.md                      # Dark mode implementation
    │
    ├── Setup/
    │   ├── GETTING_STARTED.md                # Quick start guide
    │   ├── DEPENDENCIES.md                   # External dependencies
    │   └── BUILD_CONFIGURATION.md            # Build settings
    │
    └── Guides/
        ├── ADDING_FEATURES.md                # How to add new features
        ├── TESTING.md                        # Testing guidelines
        └── TROUBLESHOOTING.md                # Common issues & solutions
```

## Core Components

### Models Layer
**Purpose**: Define data structures
**Location**: `Core/Models/`
**Files**:
- `RouteModels.swift` - Route-related data (RouteDetails, ElevationPoint, RouteDifficulty)
- `RunModels.swift` - Run tracking data (Run, Split, WorkoutType)
- `SettingsModels.swift` - User settings (SettingsManager, DistanceUnit)

### Managers Layer
**Purpose**: Business logic & state management
**Location**: `Core/Managers/`
**Files**:
- `RoutePlanner.swift` - Generates and manages routes
- `LocationManager.swift` - Handles GPS and location services
- `NavigationManager.swift` - Provides voice navigation and coaching
- `HealthKitManager.swift` - Integrates with Apple Health

### Constants Layer
**Purpose**: Centralized configuration
**Location**: `Core/Constants/`
**Files**:
- `AppConstants.swift` - Numeric constants, thresholds, settings
- `AppColors.swift` - Color scheme and theming

## Features Organization

### Main Feature
**Purpose**: Primary running interface
**Location**: `Features/Main/`
**Key Files**:
- `ContentView.swift` - Main screen orchestrating all features
- `MapView.swift` - Map display with route overlays
- Components for stats, controls, and summaries

### Route Details Feature
**Purpose**: Analyze route characteristics
**Location**: `Features/RouteDetails/`
**Shows**: Elevation, turns, surface types, difficulty

### Route Editor Feature
**Purpose**: Customize generated routes
**Location**: `Features/RouteEditor/`
**Allows**: Adjusting route complexity via waypoint count

### Run History Feature
**Purpose**: View past runs
**Location**: `Features/RunHistory/`
**Uses**: SwiftData for persistence

### Settings Feature
**Purpose**: App configuration
**Location**: `Features/Settings/`
**Manages**: Distance units, preferences

## Data Flow

```
User Interaction
    ↓
ContentView (Coordinator)
    ↓
Managers (Business Logic)
    ├→ RoutePlanner → MapKit API → Route Generation
    ├→ LocationManager → CoreLocation → GPS Tracking
    ├→ NavigationManager → AVFoundation → Voice Guidance
    └→ HealthKitManager → HealthKit → Workout Saving
    ↓
Models (Data Structures)
    ↓
SwiftData / UserDefaults (Persistence)
```

## Key Design Patterns

### 1. Observable Objects
Managers use `@Published` properties for reactive updates:
```swift
class RoutePlanner: ObservableObject {
    @Published var currentRoute: [CLLocationCoordinate2D] = []
    @Published var isLoadingRoute = false
}
```

### 2. Coordinator Pattern (ContentView)
ContentView coordinates between managers:
```swift
@StateObject private var locationManager = LocationManager()
@StateObject private var routePlanner = RoutePlanner()
@StateObject private var navigationManager = NavigationManager()
```

### 3. Async/Await for Concurrency
All network and intensive operations use async/await:
```swift
func generateRoute() async {
    await fetchDirectionsRoute(waypoints: waypoints)
}
```

### 4. SwiftUI Sheets for Features
Each major feature is a sheet:
```swift
.sheet(isPresented: $showRouteDetails) {
    RouteDetailsSheet(routeDetails: details)
}
```

## Dependencies

### Apple Frameworks
- **SwiftUI**: UI framework
- **MapKit**: Maps and directions
- **CoreLocation**: GPS tracking
- **HealthKit**: Workout integration
- **AVFoundation**: Voice synthesis
- **SwiftData**: Data persistence
- **Charts**: Elevation charts (iOS 16+)

### No External Dependencies
All functionality uses native Apple frameworks.

## Testing Strategy

### Unit Tests
- `RoutePlannerTests` - Route generation logic
- `NavigationManagerTests` - Turn detection
- `LocationManagerTests` - Distance calculation

### UI Tests
- Route creation flow
- Run start/stop
- Settings changes

### Integration Tests
- MapKit integration
- HealthKit saving
- Voice navigation

## Code Style Guidelines

### Naming Conventions
- **Views**: Descriptive nouns (`RouteDetailsSheet`, `RunHistoryView`)
- **Managers**: Noun + "Manager" (`RoutePlanner`, `LocationManager`)
- **Models**: Descriptive nouns (`RouteDetails`, `Run`)
- **Methods**: Verb phrases (`generateRoute()`, `startTracking()`)

### File Organization
- MARK comments for sections
- Extensions at bottom of file
- Supporting types after main type

### SwiftUI Best Practices
- Computed properties for view components
- Extract complex views to separate structures
- Use @ViewBuilder for conditional views

## Adding New Features

### Step-by-Step Process

1. **Create Model** (if needed)
   - Add to `Core/Models/`
   - Define data structure

2. **Create Manager** (if needed)
   - Add to `Core/Managers/`
   - Implement business logic
   - Use `@Published` for observable state

3. **Create Views**
   - Add to appropriate `Features/` subfolder
   - Break into components if complex
   - Use existing color scheme

4. **Integrate in ContentView**
   - Add `@State` for sheet presentation
   - Add button to trigger feature
   - Add `.sheet()` modifier

5. **Document**
   - Add to `Documentation/Features/`
   - Update this architecture doc

## Common Patterns

### Presenting a Sheet
```swift
// 1. Add state
@State private var showFeature = false

// 2. Add button
Button("Show Feature") {
    showFeature = true
}

// 3. Add sheet
.sheet(isPresented: $showFeature) {
    FeatureView()
}
```

### Creating a Manager
```swift
class MyManager: ObservableObject {
    @Published var data: DataType
    
    func performAction() async {
        // Business logic
        await updateData()
    }
}
```

### Using Colors
```swift
// Always use semantic colors from AppColors.swift
Text("Hello")
    .foregroundColor(.appTextPrimary)
    .background(Color.appCardBackground)
```

## Performance Considerations

### Route Generation
- Limit waypoints to 12 max (MapKit API limits)
- Cache route details to avoid recomputation
- Use async operations to prevent UI blocking

### Location Tracking
- Distance filter: 10 meters (reduces battery usage)
- Only track when run is active
- Stop updates when app backgrounds

### Map Rendering
- Remove old overlays before adding new ones
- Use appropriate line widths for performance
- Limit annotation count

## Accessibility

### VoiceOver Support
- All buttons have labels
- Images have accessibility descriptions
- Dynamic Type supported

### Color Contrast
- All text meets WCAG AA standards
- Dark mode fully supported
- High contrast color choices

## Future Architecture Improvements

### Potential Enhancements
1. **Dependency Injection**: Replace `@StateObject` with DI container
2. **Repository Pattern**: Abstract data persistence
3. **Use Cases**: Separate business logic from managers
4. **Modularization**: Create Swift Packages for features
5. **State Management**: Consider TCA or similar framework

### Scalability Considerations
- Current architecture supports up to ~50 files comfortably
- Beyond that, consider feature modules as Swift Packages
- Could split into: CoreModule, RoutingModule, TrackingModule, UIModule

## AI Assistant Guidelines

### When Modifying Code
1. Check which layer (Model/Manager/View)
2. Maintain existing patterns
3. Update related documentation
4. Keep dependencies minimal
5. Use existing color scheme

### When Adding Features
1. Determine if it needs a new manager
2. Create in appropriate `Features/` subfolder
3. Integrate via ContentView
4. Document in `Documentation/Features/`

### When Debugging
1. Check manager state (Observable Objects)
2. Verify async operations complete
3. Check sheet presentation state
4. Review MapKit API limits
5. Ensure models are properly defined

## Quick Reference

### File Locations
- **Add constant**: `Core/Constants/AppConstants.swift`
- **Add color**: `Core/Constants/AppColors.swift`
- **Add model**: `Core/Models/[Type]Models.swift`
- **Add manager**: `Core/Managers/[Name]Manager.swift`
- **Add view**: `Features/[Feature]/Views/`
- **Add docs**: `Documentation/[Category]/`

### Common Tasks
- **Change app name**: Update Info.plist CFBundleDisplayName
- **Add icon**: Assets.xcassets/AppIcon.appiconset
- **Change colors**: Core/Constants/AppColors.swift
- **Add setting**: Core/Models/SettingsModels.swift
- **New route feature**: Features/RouteDetails/ or Features/RouteEditor/

## Version History

- **v1.0** - Initial architecture (current)
- Future versions will be documented here

---

## Summary

RunZone follows a clean MVVM architecture with clear separation of concerns:
- **Models** hold data
- **Managers** handle logic
- **Views** present UI
- **Features** are self-contained modules

This structure makes it easy to:
- Find relevant code
- Add new features
- Test components
- Understand data flow
- Maintain codebase

For detailed information on specific features, see `Documentation/Features/`.
