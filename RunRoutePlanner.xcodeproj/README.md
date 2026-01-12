# RunZone 🏃‍♂️

**Circular Running Route Planner for iOS**

Generate perfect circular running routes that bring you back to your starting point. Track your runs with GPS, get voice guidance, and save to Apple Health.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)](https://developer.apple.com/xcode/swiftui/)

## Features

### Core Functionality
- ✅ **Auto-Generate Circular Routes** - Pick distance, get a route
- ✅ **Real-Time GPS Tracking** - Track distance, pace, and path
- ✅ **Voice Navigation** - Turn-by-turn guidance while running
- ✅ **Pace Coaching** - Stay on target with voice feedback
- ✅ **Route Preview** - See your route before you run
- ✅ **Route Customization** - Adjust complexity and direction
- ✅ **Route Analysis** - View elevation, turns, and surface types
- ✅ **Dark Mode** - Beautiful in light and dark themes
- ✅ **HealthKit Integration** - Save workouts to Apple Health
- ✅ **Run History** - View all past runs with details

### User Experience
- 🎯 Routes always return to start (circular)
- 🗺️ Routes follow real roads and paths
- 🔄 Reverse direction with one tap
- 📊 Detailed route statistics
- 🎨 Adaptive dark mode
- 🔊 Voice prompts for navigation
- 💚 Saves to Apple Health automatically

## Quick Start

### Requirements
- iOS 17.0+
- Xcode 15.0+
- iPhone with GPS (for actual tracking)

### Setup

1. **Clone or open project**
   ```bash
   cd /repo/
   open RunZone.xcodeproj
   ```

2. **Build and run**
   ```
   ⌘ + R
   ```

3. **Grant permissions**
   - Allow location access
   - Allow motion & fitness (optional)

4. **Start using**
   - Select distance (1-50km)
   - View route preview
   - Tap Start Run!

### First Run
1. App opens with map showing your location
2. Route preview generates automatically (default 5km)
3. Adjust distance with slider
4. Tap blue "Start Run" button
5. Follow the route (blue dashed line)
6. Voice prompts guide you through turns
7. Tap red "Stop Run" when finished
8. View summary and save to Health

## Screenshots

```
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   Route Preview     │  │   Active Run        │  │   Route Details     │
│                     │  │                     │  │                     │
│  🗺️ Map with route  │  │  🏃 Live tracking   │  │  📊 Analysis        │
│  📏 5.0 km          │  │  📍 2.3 km          │  │  ⛰️ Elevation       │
│                     │  │  ⏱️ 12:45           │  │  ↩️ 8 turns         │
│  [↻] [✏️] [ℹ️]      │  │  ⚡ 5:30 /km        │  │  🛣️ Surface types   │
│                     │  │                     │  │                     │
│  [Start Run]        │  │  [Stop Run]         │  │  [Done]             │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

## Architecture

### Pattern: MVVM (Model-View-ViewModel)
```
Views (SwiftUI)
    ↓
Managers (ObservableObject)
    ↓
Models (Data Structures)
    ↓
Persistence (SwiftData/UserDefaults)
```

### Project Structure
```
RunZone/
├── Core/
│   ├── Models/          # Data structures
│   ├── Managers/        # Business logic
│   └── Constants/       # Configuration
├── Features/
│   ├── Main/            # Main screen
│   ├── RouteDetails/    # Route analysis
│   ├── RouteEditor/     # Route customization
│   ├── RunHistory/      # Past runs
│   └── Settings/        # User preferences
└── Documentation/       # Complete docs
```

### Key Components

**Managers** (Business Logic):
- `RoutePlanner` - Generates circular routes via MapKit
- `LocationManager` - Tracks GPS and calculates stats
- `NavigationManager` - Provides voice guidance
- `HealthKitManager` - Saves workouts to Health

**Views** (UI):
- `ContentView` - Main app coordinator
- `MapView` - Map display with overlays
- `RunHistoryView` - Past runs list
- `SettingsView` - User preferences

**Models** (Data):
- `Run`, `Split`, `WorkoutType` - Run data (SwiftData)
- `RouteDetails`, `ElevationPoint` - Route analysis
- `SettingsManager` - User settings

## Documentation

### 📚 Complete documentation in `/Documentation/`

**Start Here:**
- [`QUICK_START.md`](Documentation/QUICK_START.md) - Setup and basics
- [`AI_AGENT_GUIDE.md`](Documentation/AI_AGENT_GUIDE.md) - Quick reference for AI
- [`PROJECT_ARCHITECTURE.md`](Documentation/PROJECT_ARCHITECTURE.md) - Full architecture
- [`README.md`](Documentation/README.md) - Documentation index

**Features:**
- Route generation system
- GPS tracking details
- Voice navigation logic
- Route customization
- Dark mode implementation
- HealthKit integration

**Guides:**
- Adding new features
- Code style guidelines
- Testing strategies
- Troubleshooting

## Technology Stack

### Apple Frameworks (All Native)
- **SwiftUI** - UI framework
- **MapKit** - Maps and directions
- **CoreLocation** - GPS tracking
- **HealthKit** - Workout integration
- **AVFoundation** - Voice synthesis
- **SwiftData** - Data persistence
- **Charts** - Elevation visualization

### No External Dependencies
Everything uses native iOS frameworks. No CocoaPods, SPM packages, or third-party libraries required.

## Development

### Adding Features
```swift
// 1. Create view
struct MyFeature: View {
    var body: some View { }
}

// 2. Add to ContentView
@State private var showFeature = false

.sheet(isPresented: $showFeature) {
    MyFeature()
}

// 3. Document in /Documentation/
```

### Code Style
- Use semantic colors (`.appTextPrimary`, not `.black`)
- Extract complex views to computed properties
- Use `async/await` for concurrency
- Follow MVVM pattern
- Document complex logic

### Testing
```bash
# Unit tests
⌘ + U

# Manual testing
⌘ + R (on device with GPS)
```

## Configuration

### App Constants
File: `Constants.swift`

```swift
// Default settings
defaultDistance = 5.0 km
waypointCount = 4
paceTolerancePercent = 0.10

// Change these to customize behavior
```

### Colors
All colors in `Constants.swift` with light/dark mode support:

```swift
// Semantic colors automatically adapt
.appTextPrimary      // Main text
.appBackground       // Main background
.appSuccess          // Green accents
.appInfo             // Blue accents
```

## Features in Detail

### Route Generation
1. User selects target distance
2. App calculates circular waypoints
3. MapKit fetches walking directions
4. Route displayed on map
5. Can adjust complexity (3-12 waypoints)

### GPS Tracking
- 10m distance filter (battery efficient)
- Real-time pace calculation
- Path recording with green line
- Only active during runs

### Voice Navigation
- Detects turns by bearing analysis
- Announces in advance (50m)
- Includes distance in instructions
- Pace coaching optional

### Route Analysis
- **Turns**: Counted from bearing changes
- **Elevation**: Calculated profile
- **Surface**: Roads vs trails detection
- **Difficulty**: Based on terrain
- **Time**: Estimated from distance + factors

### Dark Mode
- All colors adapt automatically
- Consistent semantic naming
- Brighter accents in dark mode
- Tested in both modes

## Contributing

### Guidelines
1. Follow existing code style
2. Use semantic colors
3. Test in light and dark mode
4. Update documentation
5. Add tests for new features

### Pull Requests
- Clear description
- Tested on device
- Documentation updated
- Follows architecture

## Troubleshooting

### Route Won't Generate
- Check location permissions
- Verify internet connection
- Try different distance
- See console for errors

### App Crashes
- Clean build folder (⌘ + Shift + K)
- Check Info.plist privacy keys
- Verify iOS 17+ deployment

### Voice Not Working
- Check voice guidance toggle
- Verify phone not on silent
- Test with other apps

### Build Errors
- Types must be in existing files
- Check imports (SwiftUI, MapKit)
- Verify file in Xcode target

See [`Documentation/TROUBLESHOOTING.md`](Documentation/TROUBLESHOOTING.md) for more.

## Performance

### Optimizations
- Waypoint limit prevents API overload
- Distance filter reduces GPS updates
- Async operations don't block UI
- Map overlays efficiently managed
- Route results cached

### Battery Life
- GPS only active during runs
- 10m distance filter
- Stops tracking in background
- Minimal network usage

## Privacy

### Data Collection
- **Location**: Only when using app
- **Motion**: For activity tracking
- **Health**: Only with explicit permission

### Data Storage
- Runs stored locally (SwiftData)
- Settings stored locally (UserDefaults)
- No cloud sync (privacy first)
- No analytics or tracking

### Permissions Required
1. Location (When In Use) - Required
2. Motion & Fitness - Optional but recommended
3. HealthKit - Optional

## Roadmap

### v1.0 (Current) ✅
- Circular route generation
- GPS tracking
- Voice navigation
- Route analysis
- Dark mode
- Health integration

### v1.1 (Planned)
- Save favorite routes
- Route sharing
- More customization
- Better error handling
- Unit tests

### v2.0 (Future)
- Apple Watch app
- Advanced statistics
- Training plans
- Social features
- Route recommendations

## License

[Add your license here]

## Contact

[Add contact information]

## Acknowledgments

- Built with SwiftUI
- Maps powered by Apple Maps
- Icons from SF Symbols
- Designed for iOS 17+

## Links

- [Documentation](Documentation/README.md)
- [Architecture Guide](Documentation/PROJECT_ARCHITECTURE.md)
- [Quick Start](Documentation/QUICK_START.md)
- [AI Agent Guide](Documentation/AI_AGENT_GUIDE.md)

---

## Quick Links for Developers

**Getting Started**: [`Documentation/QUICK_START.md`](Documentation/QUICK_START.md)  
**Architecture**: [`Documentation/PROJECT_ARCHITECTURE.md`](Documentation/PROJECT_ARCHITECTURE.md)  
**For AI Agents**: [`Documentation/AI_AGENT_GUIDE.md`](Documentation/AI_AGENT_GUIDE.md)  
**All Docs**: [`Documentation/README.md`](Documentation/README.md)

**Current Status**: Well-documented, needs folder refactoring  
**Build Status**: ✅ Compiling  
**Documentation**: ✅ Complete  
**Test Coverage**: ⏳ In progress

---

Made with ❤️ for runners who love circular routes

**RunZone** - Find Your Running Zone 🏃‍♂️🔄
