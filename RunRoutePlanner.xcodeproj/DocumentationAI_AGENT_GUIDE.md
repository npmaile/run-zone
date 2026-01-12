# AI Agent Guide - RunZone Codebase

## Quick Start for AI Assistants

This document helps AI agents quickly understand the RunZone codebase structure, make changes efficiently, and maintain consistency.

## 📁 File Organization (Current State)

### ⚠️ Current Structure (Flat - Needs Refactoring)
All files are currently in the root `/repo/` directory. This document describes the **target structure** after refactoring.

### Current Key Files
```
/repo/
├── ContentView.swift          # Main app screen (600+ lines)
├── MapView.swift              # Map display with overlays
├── RoutePlanner.swift         # Route generation logic
├── LocationManager.swift      # GPS tracking
├── NavigationManager.swift    # Voice navigation
├── HealthKitManager.swift     # HealthKit integration
├── SettingsView.swift         # Settings screen
├── RunHistoryView.swift       # Past runs display
├── Constants.swift            # App constants + color scheme
├── Models.swift               # Run/Split/WorkoutType models
└── [Various .md files]        # Documentation
```

## 🎯 Target Structure (After Refactoring)

```
RunZone/
├── Core/
│   ├── Models/
│   │   ├── RouteModels.swift
│   │   ├── RunModels.swift
│   │   └── SettingsModels.swift
│   ├── Managers/
│   │   ├── RoutePlanner.swift
│   │   ├── LocationManager.swift
│   │   ├── NavigationManager.swift
│   │   └── HealthKitManager.swift
│   └── Constants/
│       ├── AppConstants.swift
│       └── AppColors.swift
├── Features/
│   ├── Main/
│   │   └── ContentView.swift
│   ├── RouteDetails/
│   ├── RouteEditor/
│   ├── RunHistory/
│   └── Settings/
└── Documentation/
    ├── AI_GUIDE.md (this file)
    ├── PROJECT_ARCHITECTURE.md
    └── [Feature docs]
```

## 🧠 Understanding the App

### What RunZone Does
1. **Generates circular running routes** based on target distance
2. **Tracks runs** with GPS
3. **Provides voice navigation** for turn-by-turn guidance
4. **Analyzes routes** (elevation, turns, surface types)
5. **Saves workouts** to Apple Health

### Core Concept: Circular Routes
- User selects distance (e.g., 5km)
- App generates circular route returning to start
- Route follows real roads (via MapKit)
- User can customize waypoint count

## 🔑 Key Files & Their Purpose

### 1. `ContentView.swift` (Main Controller)
**Purpose**: Orchestrates the entire app
**Size**: ~700 lines
**Contains**:
- Main map view
- Stats panels (distance, time, pace)
- Control panels (distance/time selectors)
- Start/Stop buttons
- Route management buttons
- Multiple sheet presentations

**Key State**:
```swift
@StateObject private var locationManager = LocationManager()
@StateObject private var routePlanner = RoutePlanner()
@StateObject private var navigationManager = NavigationManager()
@StateObject private var settings = SettingsManager()
@State private var isRunning = false
@State private var targetDistance: Double
@State private var targetTime: Double
```

**When to modify**: Adding new features, changing UI layout, integrating new managers

### 2. `RoutePlanner.swift` (Route Logic)
**Purpose**: Generates and manages routes
**Size**: ~500 lines
**Key Methods**:
- `startPlanning(from:targetDistance:)` - Generate route
- `stopPlanning()` - Cancel route generation
- `toggleDirection()` - Reverse route
- `analyzeRoute()` - Calculate details (turns, elevation, etc.)

**Data Flow**:
```
User sets distance → RoutePlanner generates waypoints → 
Calls MapKit API → Receives route → Updates @Published properties
```

**When to modify**: Changing route generation algorithm, adding route features

### 3. `LocationManager.swift` (GPS Tracking)
**Purpose**: Tracks user location during runs
**Key Responsibilities**:
- Request location permissions
- Track distance covered
- Calculate current pace
- Record path taken

**When to modify**: Changing tracking behavior, adding location features

### 4. `NavigationManager.swift` (Voice Navigation)
**Purpose**: Provides turn-by-turn voice guidance
**Key Features**:
- Detects turns by analyzing bearing changes
- Speaks instructions ("Turn right in 50 meters")
- Provides pace coaching

**When to modify**: Changing voice prompts, navigation logic

### 5. `Constants.swift` (Configuration)
**Purpose**: Centralized app configuration
**Contains**:
- AppConstants (distances, thresholds, UI constants)
- Color scheme (all app colors for light/dark mode)

**When to modify**: Changing app-wide settings, colors, or thresholds

### 6. `Models.swift` (Data Structures)
**Purpose**: Defines data models
**Contains**:
- `Run` - SwiftData model for saved runs
- `Split` - Individual km splits
- `WorkoutType` - Enum for run types

**When to modify**: Adding new data fields, changing persistence

## 🎨 Color Scheme System

### Always Use Semantic Colors
```swift
// ✅ CORRECT
Text("Hello").foregroundColor(.appTextPrimary)
.background(Color.appCardBackground)

// ❌ WRONG
Text("Hello").foregroundColor(.black)
.background(Color.white)
```

### Available Colors
```swift
// Backgrounds
.appBackground          // Main background
.appCardBackground      // Cards, panels
.appElevatedBackground  // Floating panels

// Text
.appTextPrimary         // Main text
.appTextSecondary       // Secondary text

// Accents
.appSuccess             // Green - success, go
.appWarning             // Orange - warning
.appDanger              // Red - danger, stop
.appInfo                // Blue - information

// Running Specific
.paceOnTrack            // Green - good pace
.paceSlightlyOff        // Orange - off pace
.paceFarOff             // Red - very off pace

// Shadows
.appShadow              // Adaptive shadow color
```

## 🔄 Common Modification Patterns

### Adding a New Feature

#### Pattern 1: Simple Sheet Feature
```swift
// 1. Add state to ContentView
@State private var showMyFeature = false

// 2. Add button
Button("My Feature") {
    showMyFeature = true
}

// 3. Add sheet
.sheet(isPresented: $showMyFeature) {
    MyFeatureView()
}

// 4. Create view at bottom of ContentView.swift
struct MyFeatureView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        // Your UI
    }
}
```

#### Pattern 2: Feature with Manager
```swift
// 1. Create manager in Core/Managers/
class MyFeatureManager: ObservableObject {
    @Published var data: DataType = defaultValue
    
    func performAction() async {
        // Logic here
    }
}

// 2. Add to ContentView
@StateObject private var myFeatureManager = MyFeatureManager()

// 3. Pass to feature view
MyFeatureView(manager: myFeatureManager)
```

### Adding a New Constant
```swift
// In Constants.swift, add to appropriate enum
enum AppConstants {
    enum MyCategory {
        static let myConstant = 42.0
    }
}

// Usage
let value = AppConstants.MyCategory.myConstant
```

### Adding a New Color
```swift
// In Constants.swift, add to Color extension
extension Color {
    static var myCustomColor: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
                : UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        })
    }
}
```

## 🐛 Debugging Guide

### Common Issues

#### Issue: "Cannot find type X in scope"
**Cause**: Type defined in file not added to Xcode target
**Solution**: 
1. Check if file exists
2. If using new file, definitions must be in existing files
3. Add to `ContentView.swift` or appropriate manager file

#### Issue: "Type 'Color' has no member 'appX'"
**Cause**: Color not defined in Constants.swift
**Solution**: Add color definition to `Color` extension in Constants.swift

#### Issue: Sheet not presenting
**Cause**: State variable not triggering
**Solution**: 
1. Check `@State` declaration
2. Verify `.sheet(isPresented:)` binding
3. Ensure state is set to `true`

#### Issue: Route not updating
**Cause**: RoutePlanner not regenerating
**Solution**:
1. Check if `routePlanner.startPlanning()` is called
2. Verify location is available
3. Check MapKit API response

### Verification Checklist
```
□ File is in correct location
□ Imports are correct (SwiftUI, MapKit, etc.)
□ @Published properties used in ObservableObject
□ @StateObject used for manager instances
□ @State used for view-local state
□ Colors use semantic names (.appTextPrimary, etc.)
□ Async operations use await
□ UI updates use MainActor.run
```

## 📝 Code Style Rules

### SwiftUI View Organization
```swift
struct MyView: View {
    // 1. Environment & observed objects
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager: Manager
    
    // 2. State variables
    @State private var showSheet = false
    @State private var selectedItem: Item?
    
    // 3. Body
    var body: some View {
        // Use computed properties for complex UI
        VStack {
            headerSection
            Spacer()
            bottomSection
        }
    }
    
    // 4. Computed properties (view components)
    private var headerSection: some View {
        VStack {
            // Header UI
        }
    }
    
    private var bottomSection: some View {
        VStack {
            // Bottom UI
        }
    }
    
    // 5. Methods
    private func handleAction() {
        // Logic
    }
}

// 6. Supporting views
struct SupportingView: View {
    var body: some View {
        // Supporting UI
    }
}
```

### Manager Organization
```swift
class MyManager: ObservableObject {
    // 1. Published properties
    @Published var data: DataType
    @Published var isLoading = false
    
    // 2. Private properties
    private var internalState: State
    
    // 3. Public methods
    func publicAction() async {
        await performWork()
    }
    
    // 4. Private methods
    private func performWork() async {
        // Implementation
    }
}
```

### File Structure
```swift
import Foundation
import MapKit // Required imports

// MARK: - Main Type

class/struct MainType {
    // Implementation
}

// MARK: - Supporting Types

struct SupportingType {
    // Implementation
}

// MARK: - Extensions

extension MainType {
    // Extensions
}
```

## 🔧 Refactoring Guide

### Current Priority: Split ContentView.swift

ContentView is ~700 lines. Should be split into:

```
Features/Main/
├── ContentView.swift           # Coordinator (200 lines)
├── Components/
│   ├── StatsPanel.swift        # Running stats display
│   ├── ControlPanel.swift      # Distance/time controls
│   └── ActionButtons.swift     # Start/stop buttons
└── Sheets/
    ├── RunSummarySheet.swift   # Post-run summary
    └── RouteDetailsSheet.swift # Route details
```

### How to Extract Component

#### Before (in ContentView.swift):
```swift
private var statsPanel: some View {
    HStack {
        VStack {
            Text("Distance")
            Text("\(distance)")
        }
        // ... 50 more lines
    }
}
```

#### After:
```swift
// In ContentView.swift
StatsPanel(
    distance: locationManager.totalDistance,
    time: locationManager.elapsedTime,
    pace: locationManager.currentPace
)

// In new file: Features/Main/Components/StatsPanel.swift
struct StatsPanel: View {
    let distance: Double
    let time: TimeInterval
    let pace: Double
    
    var body: some View {
        HStack {
            VStack {
                Text("Distance")
                Text(String(format: "%.2f km", distance / 1000))
            }
            // ... rest of UI
        }
    }
}
```

## 📚 Important Concepts

### 1. Circular Routes
Routes always return to start point. Generated by:
1. Calculate radius from target distance
2. Place waypoints in circle around start
3. Call MapKit to get roads between waypoints
4. Connect back to start

### 2. Waypoints
- Intermediate points along route
- More waypoints = more detailed route
- Fewer waypoints = simpler route
- Range: 3-12 waypoints

### 3. Route Analysis
Computed in `RoutePlanner.analyzeRoute()`:
- **Turns**: Detected by bearing changes
- **Elevation**: Simulated (would use API in production)
- **Surface**: Detected from MapKit step instructions
- **Difficulty**: Calculated from elevation + turns

### 4. Dark Mode
All colors automatically adapt:
- Uses `UIColor { traitCollection in ... }`
- Brighter colors in dark mode
- Semantic naming (.appTextPrimary, not .black)

## 🎯 Quick Tasks Reference

### Change App Name
**File**: Info.plist or Project Settings
**Key**: `CFBundleDisplayName`
**Value**: "RunZone"

### Change Default Distance
**File**: Constants.swift
**Location**: `AppConstants.Routing.defaultDistance`
**Current**: 5.0 km

### Change Route Update Interval
**File**: Constants.swift
**Location**: `AppConstants.Routing.routeUpdateInterval`
**Current**: 30 seconds

### Change Pace Coaching Threshold
**File**: Constants.swift
**Location**: `AppConstants.Pace.paceTolerancePercent`
**Current**: 0.10 (10%)

### Add New Workout Type
**File**: Models.swift
**Add to**: `WorkoutType` enum
**Remember**: Add icon case too

### Change Voice Guidance Text
**File**: NavigationManager.swift
**Method**: `speakInstruction(_:)`
**Location**: Various places calling this method

## 🚀 Adding Complex Features

### Example: Add Interval Training

1. **Create Model** (Models.swift):
```swift
struct IntervalWorkout {
    let warmup: TimeInterval
    let work: TimeInterval
    let rest: TimeInterval
    let sets: Int
}
```

2. **Add to Manager** (Create IntervalManager.swift):
```swift
class IntervalManager: ObservableObject {
    @Published var currentInterval: String = "Warmup"
    @Published var remainingTime: TimeInterval = 0
    
    func startInterval(workout: IntervalWorkout) {
        // Logic
    }
}
```

3. **Add UI** (ContentView.swift):
```swift
@State private var showIntervals = false

Button("Intervals") {
    showIntervals = true
}

.sheet(isPresented: $showIntervals) {
    IntervalView(manager: intervalManager)
}
```

4. **Create View** (bottom of ContentView.swift):
```swift
struct IntervalView: View {
    @ObservedObject var manager: IntervalManager
    var body: some View {
        // Interval UI
    }
}
```

## ⚡ Performance Tips

### Do's
✅ Use `Task { }` for async operations
✅ Remove map overlays before adding new ones
✅ Limit waypoints to 12 max
✅ Use `.onChange(of:)` sparingly
✅ Extract complex views to computed properties

### Don'ts
❌ Don't call MapKit API in tight loops
❌ Don't update UI from background threads
❌ Don't create heavy views in body
❌ Don't use too many @Published properties
❌ Don't block main thread with sync operations

## 🧪 Testing Locations

For consistent testing, use these:
- **San Francisco**: 37.7749° N, 122.4194° W
- **Central Park NYC**: 40.7829° N, 73.9654° W
- **London**: 51.5074° N, 0.1278° W

## 📋 Maintenance Checklist

### Before Making Changes
- [ ] Understand which layer (Model/Manager/View)
- [ ] Check existing similar code
- [ ] Review color scheme usage
- [ ] Consider dark mode
- [ ] Plan for errors

### After Making Changes
- [ ] Code compiles
- [ ] UI looks good in light mode
- [ ] UI looks good in dark mode
- [ ] No hardcoded colors
- [ ] Async operations properly handled
- [ ] Comments added for complex logic
- [ ] Documentation updated if needed

## 🆘 Emergency Fixes

### App Won't Build
1. Clean build folder: ⌘ + Shift + K
2. Check for "Cannot find type" errors
3. Verify all types are defined in existing files
4. Check imports (SwiftUI, MapKit, etc.)

### App Crashes on Launch
1. Check Info.plist has privacy descriptions
2. Verify all @StateObject are initialized
3. Check for force unwraps (!)

### Route Won't Generate
1. Check location permissions granted
2. Verify MapKit API is reachable
3. Check console for API errors
4. Try different location

## 📖 Further Reading

- `PROJECT_ARCHITECTURE.md` - Full architecture details
- `ROUTE_PLANNING.md` - Route generation deep dive
- `DARK_MODE.md` - Dark mode implementation
- `ROUTE_EDITOR_FEATURE.md` - Route customization

## 🎓 Summary for AI Agents

**Quick Context**:
- iOS app for circular running routes
- MVVM architecture
- All files currently in `/repo/` (flat structure)
- Main file: `ContentView.swift` (~700 lines)
- Key managers: RoutePlanner, LocationManager, NavigationManager
- Uses SwiftUI, MapKit, CoreLocation, HealthKit
- Dark mode supported via semantic colors
- No external dependencies

**Common Tasks**:
- Add feature: Create view, add to ContentView
- Add color: Extend Color in Constants.swift
- Change setting: Modify AppConstants
- Fix build error: Check type definitions in existing files

**Best Practices**:
- Use semantic colors (.appTextPrimary)
- Extract complex views to computed properties
- Use async/await for network operations
- Keep managers ObservableObject
- Document complex logic

**Next Steps**:
- Refactor ContentView into smaller components
- Organize files into folders
- Improve documentation

---

*This guide is optimized for AI assistants to quickly understand and modify the RunZone codebase effectively.*
