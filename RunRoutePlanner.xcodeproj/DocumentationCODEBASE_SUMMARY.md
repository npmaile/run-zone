# RunZone - Codebase Summary & Refactoring Plan

## Executive Summary

RunZone is a SwiftUI iOS app for generating circular running routes. The codebase is currently in a **flat structure** with all files in `/repo/`. This document outlines the current state, proposed refactoring, and complete documentation structure.

## Current State ✅

### File Count
- **8 Core Files**: ContentView, RoutePlanner, LocationManager, NavigationManager, HealthKitManager, Constants, Models, SettingsView
- **4 Feature Files**: MapView, RunHistoryView, RouteDetailsView, RouteEditorView  
- **20+ Documentation Files**: Architecture, guides, feature docs

### Lines of Code
- ContentView.swift: ~700 lines ⚠️ (needs splitting)
- RoutePlanner.swift: ~500 lines
- NavigationManager.swift: ~300 lines
- LocationManager.swift: ~150 lines
- Total: ~2500 lines

### Architecture
- **Pattern**: MVVM with ObservableObject
- **Framework**: SwiftUI
- **Dependencies**: Native iOS frameworks only
- **Persistence**: SwiftData for runs, UserDefaults for settings

## Documentation Created ✅

### Core Documentation
1. **`AI_AGENT_GUIDE.md`** - Quick reference for AI assistants
   - File locations and purposes
   - Common modification patterns
   - Code style rules
   - Quick fixes

2. **`PROJECT_ARCHITECTURE.md`** - Complete architecture
   - MVVM pattern details
   - Current & target structure
   - Data flow diagrams
   - Design patterns

3. **`QUICK_START.md`** - Developer onboarding
   - Setup instructions
   - How it works
   - Common tasks
   - Troubleshooting

4. **`README.md`** - Documentation index
   - Complete doc structure
   - Navigation guide
   - Quick reference
   - Learning paths

### Existing Feature Docs (From Previous Work)
- ROUTE_PLANNING.md
- ROUTE_EDITOR_FEATURE.md
- ROUTE_DETAILS_FEATURE.md
- DIRECTIONAL_ARROWS_FEATURE.md
- DARK_MODE_IMPLEMENTATION.md
- ROUTE_PLANNING_IMPROVEMENTS.md
- Various setup/guide docs

## Refactoring Plan 📋

### Phase 1: Create Folder Structure
```bash
mkdir -p Core/{Models,Managers,Constants}
mkdir -p Features/{Main,RouteDetails,RouteEditor,RunHistory,Settings}
mkdir -p Features/Main/{Views,Components}
mkdir -p Resources/Assets.xcassets
```

### Phase 2: Move Core Files
```
Current → Target

Constants.swift → Core/Constants/AppConstants.swift
Constants.swift (colors) → Core/Constants/AppColors.swift
Models.swift → Core/Models/RunModels.swift
RoutePlanner.swift (models) → Core/Models/RouteModels.swift
SettingsView.swift (manager) → Core/Models/SettingsModels.swift

RoutePlanner.swift → Core/Managers/RoutePlanner.swift
LocationManager.swift → Core/Managers/LocationManager.swift
NavigationManager.swift → Core/Managers/NavigationManager.swift
HealthKitManager.swift → Core/Managers/HealthKitManager.swift
```

### Phase 3: Split ContentView
```
ContentView.swift (700 lines) →

Features/Main/ContentView.swift (200 lines)
Features/Main/Components/StatsPanel.swift
Features/Main/Components/ControlPanel.swift
Features/Main/Components/ActionButtons.swift
Features/Main/Sheets/RunSummarySheet.swift
Features/Main/Sheets/RouteDetailsSheet.swift
Features/Main/Sheets/RouteEditorSheet.swift
```

### Phase 4: Organize Features
```
MapView.swift → Features/Main/Views/MapView.swift
RunHistoryView.swift → Features/RunHistory/RunHistoryView.swift
SettingsView.swift → Features/Settings/SettingsView.swift
```

### Phase 5: Update Imports
After moving files, update all import statements in each file.

### Phase 6: Test Thoroughly
- Build and run
- Test each feature
- Verify nothing broken
- Check in both light/dark mode

## Quick Reference for AI Agents 🤖

### Finding Files
**Current**: All in `/repo/`  
**Target**: Organized by Core/Features/Resources

### Making Changes

**Add Constant:**
```swift
// File: Core/Constants/AppConstants.swift
enum AppConstants {
    enum MySection {
        static let myValue = 42.0
    }
}
```

**Add Color:**
```swift
// File: Core/Constants/AppColors.swift
extension Color {
    static var myColor: Color {
        Color(uiColor: UIColor { traitCollection in
            // Dark and light variants
        })
    }
}
```

**Add Manager:**
```swift
// File: Core/Managers/MyManager.swift
class MyManager: ObservableObject {
    @Published var data: DataType
    func action() async { }
}
```

**Add View:**
```swift
// File: Features/MyFeature/MyView.swift
struct MyView: View {
    var body: some View { }
}
```

### Common Tasks

| Task | Current Location | Target Location |
|------|-----------------|-----------------|
| Change app name | Info.plist | Info.plist |
| Add constant | Constants.swift | Core/Constants/AppConstants.swift |
| Add color | Constants.swift | Core/Constants/AppColors.swift |
| Modify route logic | RoutePlanner.swift | Core/Managers/RoutePlanner.swift |
| Change UI | ContentView.swift | Features/Main/ContentView.swift |
| Add data model | Models.swift | Core/Models/[Type]Models.swift |

## Architecture Principles 🏛️

### 1. Separation of Concerns
- **Models**: Data only, no logic
- **Managers**: Business logic, no UI
- **Views**: UI only, minimal logic
- **Constants**: Configuration, no behavior

### 2. Single Responsibility
- Each file has one purpose
- Each class has one job
- Each method does one thing

### 3. Dependency Direction
```
Views → Managers → Models
  ↓         ↓
Constants ← everywhere
```

### 4. Observable Pattern
```swift
Manager (ObservableObject)
    ↓ @Published
View (@ObservedObject)
    ↓ Updates
UI (SwiftUI)
```

## Code Organization Rules 📏

### File Structure
```swift
// 1. Imports
import SwiftUI
import MapKit

// 2. Main Type
struct/class MainType {
    // Properties
    // Methods
}

// 3. Supporting Types
struct SupportingType { }

// 4. Extensions
extension MainType { }

// 5. Previews
#Preview { }
```

### View Structure
```swift
struct MyView: View {
    // 1. Environment & Observed
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: Manager
    
    // 2. State
    @State private var value = 0
    
    // 3. Body
    var body: some View {
        content
    }
    
    // 4. Computed Views
    private var content: some View { }
    
    // 5. Methods
    private func action() { }
}
```

### Manager Structure
```swift
class MyManager: ObservableObject {
    // 1. Published
    @Published var data: Type
    
    // 2. Private
    private var internal: Type
    
    // 3. Public Methods
    func publicAction() { }
    
    // 4. Private Methods
    private func privateAction() { }
}
```

## Best Practices ✨

### Do's ✅
- Use semantic colors (.appTextPrimary)
- Extract complex views
- Use async/await
- Comment complex logic
- Keep files < 300 lines
- Test in dark mode
- Document features

### Don'ts ❌
- Hardcode colors
- Inline complex views
- Block main thread
- Use force unwrap
- Create giant files
- Forget documentation
- Skip testing

## Testing Strategy 🧪

### Unit Tests
```swift
RoutePlannerTests
├── testWaypointGeneration
├── testRouteAnalysis
└── testDirectionReversal

LocationManagerTests
├── testDistanceCalculation
├── testPaceCalculation
└── testPathRecording
```

### UI Tests
```swift
AppFlowTests
├── testRouteGeneration
├── testRunStartStop
└── testSettingsChange
```

### Manual Tests
- [ ] Generate route in various locations
- [ ] Start/stop run
- [ ] Voice navigation
- [ ] Dark mode
- [ ] Different distances
- [ ] Rotate device

## Performance Guidelines ⚡

### Route Generation
- Max 12 waypoints (MapKit limit)
- Cache results
- Async operations
- Show loading state

### GPS Tracking
- 10m distance filter
- Only when running
- Stop in background
- Battery efficient

### Map Rendering
- Remove old overlays
- Limit annotations
- Efficient line widths
- Reuse views

## Accessibility 🌐

### VoiceOver
- All buttons labeled
- Images described
- Semantic structure

### Dynamic Type
- Supports all sizes
- Scales properly
- Readable at all sizes

### Color Contrast
- WCAG AA compliant
- Works in dark mode
- High contrast option

## Documentation Standards 📖

### File Headers
```swift
//
//  FileName.swift
//  RunZone
//
//  Purpose: Brief description of what this file does
//

import SwiftUI
```

### Comments
```swift
// MARK: - Section Name

/// Method description
/// - Parameter param: Description
/// - Returns: Description
func method(param: Type) -> Type {
    // Implementation comment if needed
}
```

### Documentation
- Update with code changes
- Keep examples current
- Fix broken links
- Add new features
- Archive obsolete docs

## Git Workflow 🔄

### Branch Strategy
```
main (stable)
  ↓
develop (integration)
  ↓
feature/feature-name (work)
```

### Commit Messages
```
feat: Add route customization
fix: Resolve dark mode color issue
docs: Update architecture guide
refactor: Split ContentView into components
test: Add route generation tests
```

## Future Improvements 🚀

### Short Term (v1.1)
- [ ] Refactor ContentView
- [ ] Organize folder structure
- [ ] Add unit tests
- [ ] Improve error handling
- [ ] Add route favorites

### Medium Term (v2.0)
- [ ] Save custom routes
- [ ] Share routes
- [ ] Social features
- [ ] Advanced statistics
- [ ] Apple Watch app

### Long Term (v3.0)
- [ ] AI route suggestions
- [ ] Community routes
- [ ] Training plans
- [ ] Coach features
- [ ] Gamification

## AI Agent Checklist ✓

Before making changes:
- [ ] Understand which layer (Model/Manager/View)
- [ ] Check existing similar code
- [ ] Review color scheme
- [ ] Consider dark mode
- [ ] Plan for errors

After making changes:
- [ ] Code compiles
- [ ] UI tested (light/dark)
- [ ] No hardcoded colors
- [ ] Async handled properly
- [ ] Documentation updated
- [ ] Comments added

## Quick Commands ⌨️

```bash
# Build
⌘ + B

# Run
⌘ + R

# Clean
⌘ + Shift + K

# Test
⌘ + U

# Documentation
open Documentation/README.md
```

## Resource Links 🔗

### Apple Documentation
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [MapKit](https://developer.apple.com/documentation/mapkit)
- [CoreLocation](https://developer.apple.com/documentation/corelocation)
- [HealthKit](https://developer.apple.com/documentation/healthkit)

### Project Documentation
- AI_AGENT_GUIDE.md - Quick AI reference
- PROJECT_ARCHITECTURE.md - Full architecture
- QUICK_START.md - Getting started
- README.md - Doc index

## Summary 📝

RunZone is a well-documented, SwiftUI-based iOS app with a clear MVVM architecture. The codebase is currently in a flat structure that needs refactoring into organized folders. Comprehensive documentation has been created to help developers and AI agents understand and modify the code efficiently.

**Current Status**: ✅ Documented, ⏳ Needs refactoring  
**Next Steps**: Implement folder structure, split large files  
**Goal**: Maintainable, scalable, well-organized codebase

---

**For Developers**: Start with QUICK_START.md  
**For AI Agents**: Use AI_AGENT_GUIDE.md  
**For Architecture**: Read PROJECT_ARCHITECTURE.md  
**For Features**: Check Documentation/README.md

🎉 **RunZone is ready for efficient development and collaboration!**
