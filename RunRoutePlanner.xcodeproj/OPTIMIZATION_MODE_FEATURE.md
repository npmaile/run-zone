# Optimization Mode Feature

## Overview
A powerful new feature that lets users choose what metric they want to lock (optimize for), while the app automatically calculates the other values. This provides much more flexible run planning.

## Feature Description

### Three Optimization Modes

1. **🏃 Optimize for Distance** (Default)
   - Distance is **locked** (cannot be changed)
   - User adjusts **Time** and **Pace**
   - Perfect for: "I want to run exactly 5km, how long will it take at different paces?"

2. **⏱️ Optimize for Time**
   - Time is **locked** (cannot be changed)
   - User adjusts **Distance** and **Pace**
   - Perfect for: "I have exactly 30 minutes, how far can I go at different paces?"

3. **⚡ Optimize for Pace**
   - Pace is **locked** (cannot be changed)
   - User adjusts **Distance** and **Time**
   - Perfect for: "I want to maintain a 6 min/km pace, adjust my distance or time goal"

## User Interface

### Segmented Control Picker
```
┌─────────────────────────────────────┐
│      Optimize For                   │
│  ┌──────────────────────────────┐  │
│  │ Distance │ Time │ Pace        │  │ ← Segmented picker
│  └──────────────────────────────┘  │
│  Lock distance, adjust time & pace  │ ← Hint text
└─────────────────────────────────────┘
```

### Dynamic Controls

#### When "Distance" is Selected:
```
┌─────────────────────────────────────┐
│  Target Time                        │
│  [ − ]    30m    [ + ]              │ ← Adjustable
├─────────────────────────────────────┤
│  Target Pace                        │
│  [ − ]   6.0 min/km   [ + ]         │ ← Adjustable
├─────────────────────────────────────┤
│  🔒 Locked Value                    │
│  ┌───────────────────────────────┐ │
│  │  5.0 km    10.0 mph  8:03/mi  │ │
│  │  Distance  (calculated)       │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### When "Time" is Selected:
```
┌─────────────────────────────────────┐
│  Target Distance                    │
│  [ − ]   5.0 km   [ + ]             │ ← Adjustable
├─────────────────────────────────────┤
│  Target Pace                        │
│  [ − ]   6.0 min/km   [ + ]         │ ← Adjustable
├─────────────────────────────────────┤
│  🔒 Locked Value                    │
│  ┌───────────────────────────────┐ │
│  │  30m       10.0 mph  8:03/mi  │ │
│  │  Time      (calculated)       │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### When "Pace" is Selected:
```
┌─────────────────────────────────────┐
│  Target Distance                    │
│  [ − ]   5.0 km   [ + ]             │ ← Adjustable
├─────────────────────────────────────┤
│  Target Time                        │
│  [ − ]    30m    [ + ]              │ ← Adjustable
├─────────────────────────────────────┤
│  🔒 Locked Value                    │
│  ┌───────────────────────────────┐ │
│  │ 6.0 min/km  10.0 mph  8:03/mi │ │
│  │ Pace        (calculated)      │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Technical Implementation

### New State Variables
```swift
@State private var targetPace: Double = 6.0 // minutes per km
@State private var optimizationMode: OptimizationMode = .distance
```

### OptimizationMode Enum
```swift
enum OptimizationMode: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case time = "Time"
    case pace = "Pace"
    
    var icon: String {
        switch self {
        case .distance: return "arrow.left.and.right"
        case .time: return "clock"
        case .pace: return "gauge.with.dots.needle.bottom.50percent"
        }
    }
    
    var description: String {
        switch self {
        case .distance: return "Lock distance, adjust time & pace"
        case .time: return "Lock time, adjust distance & pace"
        case .pace: return "Lock pace, adjust distance & time"
        }
    }
}
```

### Calculation Logic
```swift
private func recalculateValues() {
    switch optimizationMode {
    case .distance:
        // Distance locked: time = distance × pace
        targetTime = targetDistance * targetPace
        
    case .time:
        // Time locked: distance = time ÷ pace
        targetDistance = targetTime / targetPace
        targetDistance = clamp(targetDistance, 1.0...50.0)
        
    case .pace:
        // Pace locked: time = distance × pace
        targetTime = targetDistance * targetPace
        targetTime = clamp(targetTime, 5.0...300.0)
    }
}
```

### Control States

#### Locked Controls
- Buttons are **disabled**
- Text is **blue** (appInfo color)
- Lock icon shown 🔒
- Visual feedback that value is locked

#### Unlocked Controls
- Buttons are **enabled**
- Text is **normal** (appTextPrimary)
- No lock icon
- Full interactivity

## Mathematics

### Formulas
```
pace (min/km) = time (min) ÷ distance (km)
time (min) = distance (km) × pace (min/km)
distance (km) = time (min) ÷ pace (min/km)

speed (km/h) = 60 ÷ pace (min/km)
mph = speed (km/h) × 0.621371
min/mile = pace (min/km) ÷ 0.621371
```

### Example Calculations

**Scenario: Distance Mode**
- Lock: 5.0 km
- Adjust pace to 6.0 min/km
- Calculate: time = 5.0 × 6.0 = 30 minutes ✓

**Scenario: Time Mode**
- Lock: 30 minutes
- Adjust pace to 5.0 min/km
- Calculate: distance = 30 ÷ 5.0 = 6.0 km ✓

**Scenario: Pace Mode**
- Lock: 6.0 min/km
- Adjust distance to 10.0 km
- Calculate: time = 10.0 × 6.0 = 60 minutes ✓

## User Experience Benefits

### 1. Flexibility
- Choose what's most important to you
- Experiment with different scenarios
- Plan runs around constraints

### 2. Clarity
- Visual lock indicators
- Clear which value is fixed
- Disabled buttons prevent confusion

### 3. Discovery
- See how changes affect other metrics
- Learn relationships between distance, time, pace
- Make informed decisions

### 4. Common Use Cases

#### Use Case 1: "I must run 5km"
- Mode: Distance
- Lock: 5.0 km
- Question: "How fast do I need to run to finish in 25 minutes?"
- Answer: Adjust pace until time shows 25m

#### Use Case 2: "I have exactly 30 minutes"
- Mode: Time
- Lock: 30 minutes
- Question: "How far can I run at a comfortable 7 min/km pace?"
- Answer: Set pace to 7.0, see distance = 4.3 km

#### Use Case 3: "I want to run at 5:30/km pace"
- Mode: Pace
- Lock: 5.5 min/km
- Question: "What combinations of distance and time work?"
- Answer: Adjust either, the other follows

## Visual Design

### Colors
- **Locked value**: `appInfo` (blue)
- **Unlocked value**: `appTextPrimary`
- **Disabled buttons**: `appTextSecondary`
- **Lock icon**: `appInfo`
- **Locked panel background**: `appInfo.opacity(0.1)`

### Icons
- Distance: `arrow.left.and.right`
- Time: `clock`
- Pace: `gauge.with.dots.needle.bottom.50percent`
- Lock: `lock.fill`

### Typography
- Mode picker: `.headline`
- Lock icon: `.caption`
- Values: `.title` (controls), `.title2` (locked display)
- Labels: `.caption`, `.caption2`

### Spacing
- Section spacing: 12px
- Control internal: 12px
- Lock panel padding: 16px

## Pace Control Specifics

### Range
- **Minimum**: 3.0 min/km (elite runner, ~20 km/h)
- **Maximum**: 15.0 min/km (walking pace, ~4 km/h)
- **Default**: 6.0 min/km (recreational runner, ~10 km/h)
- **Step**: 0.5 min/km

### Display
```
┌─────────────────┐
│     6.0         │ ← Main value
│   min/km        │ ← Unit label
└─────────────────┘
```

## Interactions

### Haptic Feedback
- **Picker change**: Light haptic
- **Button press**: Light haptic
- **Value update**: No haptic (too frequent)

### Animations
- Mode switch: Instant (no animation on controls swap)
- Lock panel: Fade in/out with mode
- Value changes: Smooth number updates

### Accessibility
- All controls labeled
- Disabled state announced
- Lock state announced
- Values readable by VoiceOver

## Testing Scenarios

### Functional Tests
- [ ] Switch between all three modes
- [ ] Locked value cannot be changed
- [ ] Unlocked values affect calculations
- [ ] Values stay within valid ranges
- [ ] Initial pace calculated correctly

### Edge Cases
- [ ] Very fast pace (3.0 min/km)
- [ ] Very slow pace (15.0 min/km)
- [ ] Maximum distance (50 km)
- [ ] Minimum distance (1 km)
- [ ] Maximum time (300 min / 5 hours)
- [ ] Minimum time (5 min)

### UI Tests
- [ ] Lock icons appear correctly
- [ ] Disabled buttons visually distinct
- [ ] Locked values colored blue
- [ ] Calculations display correctly
- [ ] Dark mode appearance

### User Flow
1. Open app
2. Tap "Adjust Distance & Time"
3. See Distance mode by default
4. Distance is 5.0 km (locked, blue)
5. Adjust time → pace recalculates
6. Adjust pace → time recalculates
7. Switch to Time mode
8. Time is 30m (locked, blue)
9. Distance and pace are unlocked
10. Adjust either → other recalculates

## Performance Considerations

### Calculation Speed
- All calculations are instant (simple math)
- No async operations needed
- No network calls
- Purely local computation

### State Management
- Three state variables tracked
- Recalculation on every change
- Minimal overhead
- No performance impact

## Future Enhancements

### Potential Additions
1. **Preset Pace Options**
   - Easy: 7-8 min/km
   - Moderate: 5-6 min/km
   - Fast: 4-5 min/km
   - Elite: <4 min/km

2. **Pace Calculator Helper**
   - "What's my pace if I run 5km in 25min?"
   - Quick conversion tool

3. **Visual Pace Graph**
   - Show how distance/time relate at current pace
   - Interactive curve

4. **Pace History**
   - Remember your typical paces
   - Quick select from past runs

5. **Smart Suggestions**
   - "Based on your last 5 runs, suggest a pace"
   - AI-based recommendations

6. **Unit Preferences**
   - Support miles instead of km
   - Support min/mile as primary
   - User preference in settings

## Code Changes Summary

### Files Modified
- `ContentView.swift`

### New Code Added
- `OptimizationMode` enum (30 lines)
- `optimizationModePicker` view (20 lines)
- `lockedValueDisplay` view (80 lines)
- `paceControl` view (45 lines)
- Updated `distanceControl` (10 lines changed)
- Updated `timeControl` (10 lines changed)
- `recalculateValues()` method (25 lines)
- `incrementPace()` / `decrementPace()` methods (10 lines)
- Updated calculation methods (20 lines)

**Total**: ~250 lines added/modified

### State Variables Added
- `targetPace: Double`
- `optimizationMode: OptimizationMode`

## Documentation Files

1. **OPTIMIZATION_MODE_FEATURE.md** (this file) - Complete feature documentation
2. **OPTIMIZATION_MODE_GUIDE.md** - User-facing guide
3. Updated **ROUTE_PREVIEW_CHANGES.md** - Include this feature

## Migration Notes

### Existing Users
- Default mode is Distance (same as before)
- Existing behavior preserved
- New pace control adds flexibility
- No breaking changes

### Data Compatibility
- No persistence of optimization mode
- Resets to Distance on app restart
- No migration needed

## Conclusion

This optimization mode feature significantly enhances the route planning experience by giving users complete control over how they plan their runs. Whether optimizing for a specific distance, working within a time constraint, or maintaining a target pace, the app now adapts to the user's needs.

**Key Benefits:**
- ✅ More flexible planning
- ✅ Clear visual feedback
- ✅ Intuitive interactions
- ✅ Real-time calculations
- ✅ Professional runner experience

---

**Version**: 1.1.0
**Date**: January 11, 2026
**Status**: ✅ Implemented
**Impact**: High - Major UX improvement
