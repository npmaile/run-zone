# Advanced Route Planning - Multiple Route Options

## Overview
Enhanced the route planning algorithm to generate multiple route options using different strategies, allowing users to choose their preferred route before starting their run.

## New Features

### 1. Four Route Strategies

#### 🔷 Balanced (Default)
- **Description**: Mix of turns and straightaways
- **Waypoint Multiplier**: 1.0x
- **Radius Variation**: 10%
- **Best For**: Most runners, general use
- **Complexity**: Medium

#### 🍃 Scenic
- **Description**: More waypoints, varied path
- **Waypoint Multiplier**: 1.5x
- **Radius Variation**: 25%
- **Best For**: Exploring, sightseeing runs
- **Complexity**: High

#### ➡️ Direct
- **Description**: Fewer turns, efficient route
- **Waypoint Multiplier**: 0.7x
- **Radius Variation**: 5%
- **Best For**: Speed work, tempo runs
- **Complexity**: Low

#### 📊 Varied
- **Description**: Maximum variety, explore
- **Waypoint Multiplier**: 1.8x
- **Radius Variation**: 35%
- **Best For**: Discovery, new areas
- **Complexity**: High

---

## Technical Implementation

### New Models

#### RouteStrategy Enum
```swift
enum RouteStrategy: String, CaseIterable {
    case balanced = "Balanced"
    case scenic = "Scenic"
    case direct = "Direct"
    case varied = "Varied"
    
    var waypointMultiplier: Double
    var radiusVariation: Double
}
```

#### RouteOption Struct
```swift
struct RouteOption: Identifiable {
    let id: UUID
    let strategy: RouteStrategy
    let waypoints: [CLLocationCoordinate2D]
    let coordinates: [CLLocationCoordinate2D]
    let estimatedDistance: Double
    let waypointCount: Int
    let complexity: String // "Low", "Medium", "High"
}
```

### Enhanced RoutePlanner

#### New Published Properties
```swift
@Published var routeOptions: [RouteOption] = []
@Published var selectedRouteOption: RouteOption?
@Published var isGeneratingOptions = false
```

#### New Methods

**`generateRouteOptions(from:targetDistance:)`**
- Generates all 4 route strategies simultaneously
- Returns array of RouteOption objects
- Auto-selects Balanced option
- Async operation with progress indicator

**`selectRouteOption(_:)`**
- Sets selected option as current route
- Updates map display
- Preserves selection for user

**`generateRouteOption(from:targetDistance:strategy:)`**
- Private helper to generate single route
- Uses MapKit Directions API
- Falls back to geometric route if needed
- Calculates actual distance

**`calculateRouteDistance(_:)`**
- Calculates total route distance
- Uses CLLocation distance calculations
- Accurate to real walking/running distance

**`generateWaypoints(center:targetDistance:strategy:)`**
- Strategy-aware waypoint generation
- Applies waypoint multiplier
- Adds radius variation for variety
- Includes angle offsets for Varied strategy

---

## User Interface

### RouteOptionsSheet

#### Features
- **Full-screen modal sheet**
- **Loading state** with progress indicator
- **Empty state** if generation fails
- **Scrollable list** of route cards
- **Preview on tap** - Updates map immediately
- **Visual selection** - Highlighted card with checkmark
- **Confirmation button** - "Select" to confirm choice

#### Route Option Card

Displays for each route:
- **Strategy icon and name**
- **Strategy description**
- **Distance** (actual calculated)
- **Waypoint count**
- **Complexity level**
- **Preview hint** ("Tap to preview on map")
- **Selection indicator** (checkmark when selected)
- **Visual feedback** (gradient background when selected)

### Integration in ContentView

#### New Button in Idle Stats Panel
- **Icon**: `map.fill`
- **Color**: Green (appSuccess)
- **Action**: Generate and show route options
- **Position**: First button (leftmost)

#### Button Order
1. 🗺️ **Route Options** (NEW)
2. ↻ **Reverse Direction**
3. ✏️ **Edit Route**
4. ℹ️ **Route Details**

---

## Algorithm Details

### Waypoint Generation

#### Base Calculation
```swift
let baseWaypointCount = max(4, Int(targetDistance / 2000))
// Examples:
// 5km → 4 waypoints (min)
// 10km → 5 waypoints
// 20km → 10 waypoints
```

#### Strategy Adjustment
```swift
let adjustedCount = Int(Double(baseWaypointCount) * strategy.waypointMultiplier)
let clampedCount = min(adjustedCount, 12) // MapKit limit

// Example for 5km (base = 4):
// Balanced: 4 * 1.0 = 4 waypoints
// Scenic: 4 * 1.5 = 6 waypoints
// Direct: 4 * 0.7 = 2 waypoints (min 2)
// Varied: 4 * 1.8 = 7 waypoints
```

#### Radius Calculation
```swift
let radius = targetDistance / (2 * π)
let radiusInDegrees = radius / 111320.0 // meters per degree

// For each waypoint:
let radiusVariation = 1.0 + (random(-1...1) * strategy.radiusVariation)
let adjustedRadius = radiusInDegrees * radiusVariation

// Example with 10% variation (Balanced):
// radiusVariation ranges from 0.9 to 1.1
// Waypoints at 90% to 110% of base radius
```

#### Angle Calculation
```swift
let angle = 2π * i / waypointCount

// For Varied strategy, add offset:
let angleOffset = random(-0.3...0.3)
let adjustedAngle = angle + angleOffset

// Coordinates:
lat = center.lat + adjustedRadius * cos(adjustedAngle)
lon = center.lon + adjustedRadius * sin(adjustedAngle) / cos(center.lat * π / 180)
```

### Distance Calculation

```swift
func calculateRouteDistance(_ coordinates: [CLLocationCoordinate2D]) -> Double {
    var totalDistance: Double = 0
    for i in 0..<(coordinates.count - 1) {
        let loc1 = CLLocation(lat: coords[i].lat, lon: coords[i].lon)
        let loc2 = CLLocation(lat: coords[i+1].lat, lon: coords[i+1].lon)
        totalDistance += loc1.distance(from: loc2)
    }
    return totalDistance
}
```

### Complexity Classification

```swift
func complexityLevel(for waypointCount: Int) -> String {
    switch waypointCount {
    case 0...4: return "Low"     // Fewer turns, simpler
    case 5...8: return "Medium"  // Moderate turns
    default: return "High"        // Many turns, complex
    }
}
```

---

## User Flow

### Step-by-Step

1. **User opens app**
   - Route generates automatically (Balanced strategy)

2. **User taps 🗺️ Route Options button**
   - Loading screen appears
   - "Generating Routes..." message
   - App generates 4 route options simultaneously

3. **Route options appear**
   - List of 4 cards
   - Balanced pre-selected
   - Each card shows distance, waypoints, complexity

4. **User taps a route card**
   - Card highlights with green gradient
   - Checkmark appears
   - Map updates to show that route (preview)
   - User can tap others to compare

5. **User taps "Select" button**
   - Selected route becomes active
   - Sheet dismisses
   - User can start run with chosen route

### Alternative Flow

**User wants to regenerate options:**
1. Tap 🗺️ button again
2. New set of routes generated
3. Slightly different due to random variation
4. Fresh exploration possibilities

---

## Example Scenarios

### Scenario 1: Morning Commute Run

**Goal**: Quick, efficient 5km
**Choice**: **Direct** strategy
```
- 2-3 waypoints
- Minimal turns
- Straightforward path
- Low complexity
- Faster completion
```

### Scenario 2: Weekend Exploration

**Goal**: Discover new areas, 10km
**Choice**: **Varied** strategy
```
- 10-12 waypoints
- Maximum variety
- Different each time
- High complexity
- Scenic discovery
```

### Scenario 3: Training Run

**Goal**: Balanced workout, 8km
**Choice**: **Balanced** strategy (default)
```
- 5-6 waypoints
- Mix of straight and turns
- Medium complexity
- Predictable challenge
- Good for training
```

### Scenario 4: Photography Run

**Goal**: Scenic route, 7km
**Choice**: **Scenic** strategy
```
- 7-8 waypoints
- Varied terrain
- More waypoints = more variety
- High complexity
- Exploration focus
```

---

## Code Changes

### Files Modified

1. **RoutePlanner.swift** (~150 lines added)
   - New models (RouteStrategy, RouteOption)
   - New published properties
   - New generation methods
   - Enhanced waypoint algorithm

2. **ContentView.swift** (~30 lines modified)
   - New @State for showRouteOptions
   - New sheet declaration
   - New button in idleStatsPanel
   - Integration code

### Files Created

3. **RouteOptionsSheet.swift** (~300 lines)
   - New SwiftUI view
   - Route selection interface
   - RouteOptionCard component
   - Loading and empty states

---

## Performance Considerations

### Parallel Generation
- All 4 routes generated concurrently
- Each uses async/await
- No blocking of UI thread
- Progress indicator shows activity

### MapKit API Usage
- Still respects 12 waypoint limit
- Strategies adjust within limits
- Fallback to geometric routes if needed
- Efficient caching of results

### Memory Management
- RouteOptions stored temporarily
- Released when sheet dismisses
- Only selected route kept long-term
- Minimal memory footprint

---

## User Experience Benefits

### Before
- ✅ One route generated
- ❌ Take it or leave it
- ❌ No variety
- ❌ Can't explore alternatives

### After
- ✅ Four route strategies
- ✅ Preview before choosing
- ✅ Variety on tap
- ✅ Explore different approaches
- ✅ Match route to mood/goal
- ✅ Visual comparison
- ✅ Professional experience

---

## Testing

### Test Scenarios

**Test 1: Route Generation**
- [ ] Tap route options button
- [ ] All 4 strategies generate
- [ ] Loading indicator appears
- [ ] Routes display correctly

**Test 2: Route Selection**
- [ ] Tap different route cards
- [ ] Map updates with preview
- [ ] Selection indicator appears
- [ ] Visual feedback works

**Test 3: Route Confirmation**
- [ ] Select a route
- [ ] Tap "Select" button
- [ ] Sheet dismisses
- [ ] Route remains active
- [ ] Can start run with it

**Test 4: Edge Cases**
- [ ] Very short distance (1km)
- [ ] Very long distance (50km)
- [ ] Poor network connection
- [ ] MapKit API failures
- [ ] Rapid button presses

**Test 5: Visual**
- [ ] Light mode appearance
- [ ] Dark mode appearance
- [ ] Different screen sizes
- [ ] Landscape orientation
- [ ] Accessibility features

---

## Future Enhancements

### Short Term
1. **Save Favorite Strategy** - Remember user's preference
2. **Route Comparison View** - Side-by-side comparison
3. **Distance Accuracy** - Show % match to target
4. **Estimated Time** - For each route option

### Medium Term
5. **Custom Strategies** - Let users create own
6. **Route History** - "Generate like last time"
7. **Weather Integration** - Suggest strategy by weather
8. **Terrain Preferences** - Hills vs flat

### Long Term
9. **AI-Powered Suggestions** - Learn user preferences
10. **Community Routes** - Share with others
11. **Route Ratings** - User feedback system
12. **Advanced Filters** - Hills, traffic, scenery

---

## Troubleshooting

### Routes Don't Generate
**Issue**: All routes fail to generate
**Solution**: 
- Check internet connection
- Verify location permissions
- Try shorter distance
- Check MapKit availability

### Routes Look Similar
**Issue**: All 4 routes appear identical
**Solution**:
- This can happen in areas with limited roads
- Random variation may be minimal
- Try different starting location
- Increase/decrease distance

### Selection Doesn't Work
**Issue**: Tapping routes doesn't preview
**Solution**:
- Ensure location is valid
- Check routePlanner is not nil
- Verify coordinates are populated
- Check console for errors

---

## Summary

### What Was Added
- ✅ 4 route generation strategies
- ✅ Multiple route options
- ✅ Visual route selection UI
- ✅ Preview before choosing
- ✅ Enhanced waypoint algorithm
- ✅ Complexity classification

### Impact
**High** - Transforms route planning from single-option to multi-choice system

### User Benefit
Professional-grade route variety matching different running goals and preferences

### Code Quality
- Clean architecture
- Reusable components
- Async/await best practices
- Comprehensive error handling

---

**Version**: 1.2.0  
**Date**: January 11, 2026  
**Status**: ✅ Implemented  
**Documentation**: Complete
