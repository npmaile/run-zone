# RunZone Refactoring Guide

## ⚠️ Important: Read This First

**Refactoring in Xcode requires manual file movement to maintain target membership.**

This guide provides step-by-step instructions to safely refactor the RunZone codebase from a flat structure to an organized folder hierarchy.

**Estimated Time**: 2-3 hours  
**Difficulty**: Intermediate  
**Risk Level**: Low (with backup)

## Prerequisites

- [ ] Backup created (or committed to git)
- [ ] Xcode project open
- [ ] All changes committed (recommended)
- [ ] Read this entire guide first

## Overview

We'll refactor in this order:
1. Create folder structure in Xcode
2. Split large files
3. Move files to new locations
4. Update imports
5. Test thoroughly

## Phase 1: Create Folder Structure (10 min)

### In Xcode Navigator:

1. **Right-click on project** → New Group
2. **Create these groups**:

```
RunZone (project root)
├── Core
│   ├── Models
│   ├── Managers
│   └── Constants
├── Features
│   ├── Main
│   │   ├── Views
│   │   ├── Components
│   │   └── Sheets
│   ├── RouteDetails
│   │   └── Views
│   ├── RouteEditor
│   │   └── Views
│   ├── RunHistory
│   │   └── Views
│   └── Settings
│       └── Views
├── Resources
│   └── Assets.xcassets
└── Documentation
```

**Steps**:
- Right-click → New Group (not New Group from Folder)
- Name each group as shown above
- Create nested groups by right-clicking parent groups

## Phase 2: Split Constants.swift (15 min)

### 2.1 Create AppConstants.swift

1. **Right-click** `Core/Constants/` → New File
2. **Choose**: Swift File
3. **Name**: AppConstants.swift
4. **Content**:

```swift
import Foundation
import CoreLocation

enum AppConstants {
    // MARK: - Routing
    enum Routing {
        static let waypointCount = 4
        static let routeUpdateInterval: TimeInterval = 30
        static let interpolationPoints = 10
        static let metersPerDegree = 111320.0
        static let minDistance = 1.0
        static let maxDistance = 50.0
        static let defaultDistance = 5.0
    }

    // MARK: - Location
    enum Location {
        static let distanceFilter = 10.0
        static let maxRealisticJump = 100.0
        static let mapZoomMeters = 1000.0
    }

    // MARK: - UI
    enum UI {
        static let horizontalPadding: CGFloat = 40
        static let cornerRadius: CGFloat = 15
        static let statsCornerRadius: CGFloat = 15
        static let controlsCornerRadius: CGFloat = 20
        static let completedPathWidth: CGFloat = 6
        static let completedPathAlpha: CGFloat = 0.8
        static let plannedRouteWidth: CGFloat = 4
        static let plannedRouteAlpha: CGFloat = 0.6
        static let plannedRouteDashPattern: [NSNumber] = [10, 5]
        static let paywallDelay: TimeInterval = 1.0
        static let resetDelay: TimeInterval = 1.0
    }

    // MARK: - Subscription
    enum Subscription {
        static let productID = "com.runrouteplanner.monthly_subscription"
    }

    // MARK: - Navigation
    enum Navigation {
        static let waypointReachedThreshold = 20.0
        static let instructionDistance = 50.0
        static let instructionRepeatThreshold = 30.0
        static let straightAngleThreshold = 20.0
        static let slightTurnThreshold = 45.0
        static let sharpTurnThreshold = 120.0
        static let uTurnAngleThreshold = 30.0
        static let speechRate: Float = 0.5
        static let speechVolume: Float = 1.0
    }

    // MARK: - Pace Tracking
    enum Pace {
        static let minTimeMinutes = 5.0
        static let maxTimeMinutes = 300.0
        static let defaultTimeMinutes = 30.0
        static let timeStepMinutes = 5.0
        static let paceUpdateInterval: TimeInterval = 10.0
        static let minDistanceForPace = 100.0
        static let paceTolerancePercent = 0.10
        static let paceCheckInterval: TimeInterval = 60.0
        static let minTimeBetweenCoaching: TimeInterval = 120.0
        static let slightlySlowThreshold = 0.05
        static let moderatelySlowThreshold = 0.15
        static let slightlyFastThreshold = 0.05
        static let moderatelyFastThreshold = 0.15
    }
}
```

### 2.2 Create AppColors.swift

1. **Right-click** `Core/Constants/` → New File
2. **Name**: AppColors.swift
3. **Copy** the entire `Color` extension from Constants.swift
4. **Copy** the entire `LinearGradient` extension from Constants.swift

### 2.3 Delete Original Constants.swift

1. **Select** Constants.swift in navigator
2. **Right-click** → Delete
3. **Choose**: Move to Trash

### 2.4 Update Import References

**Build project** (⌘ + B) - there should be no errors if done correctly.

## Phase 3: Extract & Organize Models (20 min)

### 3.1 Create RunModels.swift

1. **Right-click** `Core/Models/` → New File
2. **Name**: RunModels.swift
3. **Copy** from Models.swift:
   - `WorkoutType` enum
   - `Run` class
   - `Split` class

### 3.2 Create RouteModels.swift

1. **Right-click** `Core/Models/` → New File
2. **Name**: RouteModels.swift
3. **Copy** from RoutePlanner.swift (near top):
   - `RouteDetails` struct
   - `ElevationPoint` struct
   - `RouteDifficulty` enum
4. **Delete** these from RoutePlanner.swift

### 3.3 Create SettingsModels.swift

1. **Right-click** `Core/Models/` → New File
2. **Name**: SettingsModels.swift
3. **Copy** from SettingsView.swift:
   - `DistanceUnit` enum
   - `SettingsManager` class
4. **Delete** these from SettingsView.swift

### 3.4 Delete Original Models.swift

1. **Select** Models.swift
2. **Delete** → Move to Trash

## Phase 4: Move Manager Files (10 min)

### Simply Drag & Drop in Xcode:

1. **Select** `RoutePlanner.swift`
2. **Drag** to `Core/Managers/` group
3. **Repeat** for:
   - LocationManager.swift → Core/Managers/
   - NavigationManager.swift → Core/Managers/
   - HealthKitManager.swift → Core/Managers/

**Note**: Dragging in Xcode maintains target membership automatically.

## Phase 5: Move Feature Views (10 min)

### Drag these files:

1. **MapView.swift** → `Features/Main/Views/`
2. **RunHistoryView.swift** → `Features/RunHistory/Views/`
3. **SettingsView.swift** → `Features/Settings/Views/`
4. **ContentView.swift** → `Features/Main/` (root, not in Views/)

## Phase 6: Extract ContentView Components (30 min)

This is the most complex step. We'll extract large computed properties into separate files.

### 6.1 Extract RunSummarySheet

1. **Create** `Features/Main/Sheets/RunSummarySheet.swift`
2. **Copy** entire `RunSummaryView` struct from ContentView
3. **Copy** `StatRow` struct
4. **Copy** `RunStats` struct
5. **Delete** from ContentView
6. **In ContentView**, update reference:

```swift
.sheet(isPresented: $showRunSummary) {
    if let stats = completedRunStats {
        RunSummarySheet(stats: stats, settings: settings, onDismiss: {
            showRunSummary = false
            completedRunStats = nil
        })
    }
}
```

### 6.2 Extract RouteDetailsSheet

1. **Create** `Features/Main/Sheets/RouteDetailsSheet.swift`
2. **Copy** entire `RouteDetailsSheet` struct from ContentView
3. **Copy** all supporting views (RouteStatCardView, TurnRowDetailView, etc.)
4. **Delete** from ContentView

### 6.3 Extract RouteEditorSheet

1. **Create** `Features/Main/Sheets/SimpleRouteEditorSheet.swift`
2. **Copy** `SimpleRouteEditorSheet` struct
3. **Copy** `InfoRow` struct
4. **Delete** from ContentView

### 6.4 Create StatsPanel Component

1. **Create** `Features/Main/Components/StatsPanel.swift`
2. **Content**:

```swift
import SwiftUI

struct StatsPanel: View {
    let distance: Double
    let time: TimeInterval
    let pace: Double
    let isRunning: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                distanceStatView
                Spacer()
                timeStatView
                Spacer()
                paceStatView
            }
        }
        .padding()
        .background(Color.appElevatedBackground)
        .cornerRadius(AppConstants.UI.statsCornerRadius)
        .shadow(color: Color.appShadow, radius: 8, x: 0, y: 4)
        .padding()
    }
    
    // Extract distanceStatView, timeStatView, paceStatView from ContentView
}
```

3. **In ContentView**, replace computed property with:

```swift
StatsPanel(
    distance: locationManager.totalDistance,
    time: locationManager.elapsedTime,
    pace: locationManager.currentPace,
    isRunning: isRunning
)
```

## Phase 7: Build & Fix Imports (15 min)

### 7.1 Build Project

Press **⌘ + B**

### 7.2 Fix Import Errors

For each error:
1. Click error in Issue Navigator
2. File likely needs additional import
3. Common fixes:
   - Add `import MapKit` if using map types
   - Add `import SwiftData` if using @Model
   - Add `import AVFoundation` if using speech

### 7.3 Fix "Cannot find type" Errors

If type not found:
- Verify the file containing the type is in the Xcode target
- Right-click file → Show File Inspector
- Check "Target Membership" box

## Phase 8: Test Thoroughly (20 min)

### 8.1 Clean Build

**⌘ + Shift + K** (Clean Build Folder)

### 8.2 Rebuild

**⌘ + B** (Build)

### 8.3 Run on Simulator

**⌘ + R** → Test basic flow:
- [ ] App launches
- [ ] Map displays
- [ ] Route generates
- [ ] Can start/stop run
- [ ] Settings open
- [ ] History opens

### 8.4 Test on Device

**Select your iPhone** → **⌘ + R**
- [ ] Location permissions work
- [ ] GPS tracking works
- [ ] Voice navigation works
- [ ] Can complete run
- [ ] Saves to Health

### 8.5 Test Dark Mode

**Settings → Appearance → Dark**
- [ ] All screens visible
- [ ] Colors correct
- [ ] No white/black hardcoded values

## Phase 9: Clean Up (10 min)

### 9.1 Remove Old Files

Check for any leftover files in root:
- Old .md files (move to Documentation/)
- Backup files
- Temp files

### 9.2 Organize Documentation

Ensure all `.md` files are in `Documentation/` group

### 9.3 Update .gitignore (if using Git)

```gitignore
# Xcode
*.xcuserstate
xcuserdata/
DerivedData/

# Backups
*_Backup_*/
```

## Phase 10: Commit Changes (5 min)

### If using Git:

```bash
git add .
git commit -m "refactor: Organize codebase into MVVM structure

- Split Constants into AppConstants and AppColors
- Organize models into separate files
- Move managers to Core/Managers
- Organize features into Features/ folders
- Extract ContentView components
- All tests passing"
```

## Verification Checklist ✅

After refactoring:

### Structure
- [ ] All files in appropriate folders
- [ ] No files left in project root
- [ ] Folder structure matches documentation

### Functionality
- [ ] App builds without errors
- [ ] All features work
- [ ] No crashes
- [ ] GPS tracking functional
- [ ] Voice navigation works
- [ ] Health saving works

### Code Quality
- [ ] No import errors
- [ ] No "cannot find type" errors
- [ ] All colors use semantic names
- [ ] Dark mode works correctly

### Performance
- [ ] App launches quickly
- [ ] Routes generate promptly
- [ ] Map renders smoothly
- [ ] No memory leaks

## Troubleshooting

### "Cannot find type X"
**Solution**: 
1. Find file defining X
2. Right-click file → File Inspector
3. Check Target Membership box

### Import Errors
**Solution**: Add missing import at top of file

### App Crashes on Launch
**Solution**:
1. Check Console for error
2. Likely @StateObject initialization issue
3. Ensure all managers in ContentView

### Dark Mode Colors Wrong
**Solution**: Check for hardcoded colors (`.black`, `.white`)

### MapView Not Showing
**Solution**:
1. Check location permissions
2. Verify MapKit imported
3. Check coordinates valid

## Rolling Back

If something goes wrong:

1. **⌘ + Z** repeatedly (undo in Xcode)
2. **Or restore from backup**:
   ```bash
   cp -R ../RunZone_Backup_XXXXXX/* .
   ```
3. **Or Git**:
   ```bash
   git reset --hard HEAD
   ```

## Post-Refactoring Benefits

After completing refactoring:

✅ **Organization**: Files grouped by purpose
✅ **Maintainability**: Easier to find code
✅ **Scalability**: Clear where to add features
✅ **Collaboration**: Team can navigate easily
✅ **AI-Friendly**: Agents can locate code quickly

## Next Steps

After refactoring:

1. **Update README.md** - Note new structure
2. **Add unit tests** - Now easier to test
3. **Extract more components** - Continue improving
4. **Add new features** - Using new structure

## Estimated Time Breakdown

- Phase 1 (Folders): 10 min
- Phase 2 (Constants): 15 min
- Phase 3 (Models): 20 min
- Phase 4 (Managers): 10 min
- Phase 5 (Features): 10 min
- Phase 6 (Components): 30 min
- Phase 7 (Build/Fix): 15 min
- Phase 8 (Testing): 20 min
- Phase 9 (Cleanup): 10 min
- Phase 10 (Commit): 5 min

**Total**: ~2.5 hours

## Tips

- 💡 **Do one phase at a time** - Don't rush
- 💡 **Test after each phase** - Catch issues early
- 💡 **Keep Xcode open** - File movements must be in Xcode
- 💡 **Use Git** - Commit after each successful phase
- 💡 **Take breaks** - This is detailed work

## Support

If you get stuck:
1. Check Documentation/TROUBLESHOOTING.md
2. Review Documentation/AI_AGENT_GUIDE.md
3. Search error in Console
4. Restore from backup if needed

## Conclusion

This refactoring transforms the flat structure into a well-organized, maintainable codebase. Take your time, follow the steps carefully, and test thoroughly.

**Good luck! 🚀**

---

**Remember**: Always work in Xcode, not Finder. Xcode maintains target membership automatically when you drag files between groups.
