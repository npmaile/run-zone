# Critical Logic Fix: Optimization Mode Calculations

## The Problem

When one option was locked, the other two weren't adjustable. This was due to a fundamental misunderstanding of the calculation logic with three interdependent variables.

## The Math Challenge

With distance, time, and pace, there's one fundamental relationship:
```
pace (min/km) = time (min) ÷ distance (km)
```

From this, we can derive:
```
time = distance × pace
distance = time ÷ pace
```

**Key insight**: With 3 interdependent variables, you can only independently set TWO. The third MUST be calculated.

## The Original Flawed Logic

### What Was Wrong
```swift
private func recalculateValues() {
    switch optimizationMode {
    case .distance:
        // Distance is locked, calculate time from pace  ❌ WRONG!
        targetTime = targetDistance * targetPace
    case .time:
        // Time is locked, calculate distance from pace  ❌ WRONG!
        targetDistance = targetTime / targetPace
    case .pace:
        // Pace is locked, calculate time from distance  ❌ WRONG!
        targetTime = targetDistance * targetPace
    }
}
```

**The problem**: We didn't know WHICH of the two unlocked values the user just changed!

### Example of the Failure

**Scenario**: Distance Mode (Distance = 5km locked)
1. User changes Time from 30min → 25min
2. `recalculateValues()` is called
3. It calculates Time = Distance × Pace = 5 × 6 = 30min
4. Time JUMPS BACK to 30min! ❌
5. User's change is ignored!

**Why it failed**: We needed to recalculate PACE (not Time), but we were recalculating the wrong value.

## The Solution: Separate Recalculation Methods

Instead of one generic `recalcul ateValues()`, we now have THREE specific methods that know which value was just changed:

### recalculateFromDistance()
Called when user changes distance
```swift
private func recalculateFromDistance() {
    switch optimizationMode {
    case .distance:
        // Distance is locked, shouldn't get here
        break
    case .time:
        // Time is locked, calculate pace from new distance
        targetPace = targetTime / targetDistance
    case .pace:
        // Pace is locked, calculate time from new distance
        targetTime = targetDistance * targetPace
    }
}
```

### recalculateFromTime()
Called when user changes time
```swift
private func recalculateFromTime() {
    switch optimizationMode {
    case .distance:
        // Distance is locked, calculate pace from new time
        targetPace = targetTime / targetDistance
    case .time:
        // Time is locked, shouldn't get here
        break
    case .pace:
        // Pace is locked, calculate distance from new time
        targetDistance = targetTime / targetPace
    }
}
```

### recalculateFromPace()
Called when user changes pace
```swift
private func recalculateFromPace() {
    switch optimizationMode {
    case .distance:
        // Distance is locked, calculate time from new pace
        targetTime = targetDistance * targetPace
    case .time:
        // Time is locked, calculate distance from new pace
        targetDistance = targetTime / targetPace
    case .pace:
        // Pace is locked, shouldn't get here
        break
    }
}
```

## How It Works Now

### Example 1: Distance Mode (Distance = 5km locked)

**User increases Time from 30min → 35min:**
1. `incrementTime()` is called
2. Updates `targetTime = 35`
3. Calls `recalculateFromTime()`
4. Since Distance mode: calculates `targetPace = 35 / 5 = 7 min/km`
5. ✅ Time stays at 35min, Pace updates to 7!

**User increases Pace from 6 min/km → 6.5 min/km:**
1. `incrementPace()` is called
2. Updates `targetPace = 6.5`
3. Calls `recalculateFromPace()`
4. Since Distance mode: calculates `targetTime = 5 × 6.5 = 32.5min`
5. ✅ Pace stays at 6.5, Time updates to 32.5!

### Example 2: Time Mode (Time = 30min locked)

**User increases Distance from 5km → 6km:**
1. `incrementDistance()` is called
2. Updates `targetDistance = 6`
3. Calls `recalculateFromDistance()`
4. Since Time mode: calculates `targetPace = 30 / 6 = 5 min/km`
5. ✅ Distance stays at 6km, Pace updates to 5!

**User decreases Pace from 6 min/km → 5.5 min/km:**
1. `decrementPace()` is called
2. Updates `targetPace = 5.5`
3. Calls `recalculateFromPace()`
4. Since Time mode: calculates `targetDistance = 30 / 5.5 = 5.45km`
5. ✅ Pace stays at 5.5, Distance updates to 5.45!

### Example 3: Pace Mode (Pace = 6 min/km locked)

**User increases Distance from 5km → 7km:**
1. `incrementDistance()` is called
2. Updates `targetDistance = 7`
3. Calls `recalculateFromDistance()`
4. Since Pace mode: calculates `targetTime = 7 × 6 = 42min`
5. ✅ Distance stays at 7km, Time updates to 42!

**User increases Time from 30min → 36min:**
1. `incrementTime()` is called
2. Updates `targetTime = 36`
3. Calls `recalculateFromTime()`
4. Since Pace mode: calculates `targetDistance = 36 / 6 = 6km`
5. ✅ Time stays at 36, Distance updates to 6!

## Calculation Matrix

| Mode | User Changes | What Recalculates | Formula |
|------|--------------|-------------------|---------|
| Distance | Time ↑ | Pace ↑ | pace = time / distance |
| Distance | Time ↓ | Pace ↓ | pace = time / distance |
| Distance | Pace ↑ | Time ↑ | time = distance × pace |
| Distance | Pace ↓ | Time ↓ | time = distance × pace |
| Time | Distance ↑ | Pace ↓ | pace = time / distance |
| Time | Distance ↓ | Pace ↑ | pace = time / distance |
| Time | Pace ↑ | Distance ↓ | distance = time / pace |
| Time | Pace ↓ | Distance ↑ | distance = time / pace |
| Pace | Distance ↑ | Time ↑ | time = distance × pace |
| Pace | Distance ↓ | Time ↓ | time = distance × pace |
| Pace | Time ↑ | Distance ↑ | distance = time / pace |
| Pace | Time ↓ | Distance ↓ | distance = time / pace |

## Code Changes

### Modified Functions (6 total)
```swift
// Each now calls its specific recalculation method
incrementDistance() → recalculateFromDistance()
decrementDistance() → recalculateFromDistance()
incrementTime() → recalculateFromTime()
decrementTime() → recalculateFromTime()
incrementPace() → recalculateFromPace()
decrementPace() → recalculateFromPace()
```

### New Functions (3 total)
```swift
recalculateFromDistance()  // When distance changed
recalculateFromTime()       // When time changed
recalculateFromPace()       // When pace changed
```

### Removed Functions (1 total)
```swift
recalculateValues()  // Generic version (didn't work)
```

## Why This Works

### Clear Intent
Each recalculation method KNOWS which value was just modified, so it can correctly calculate the other dependent value.

### No Ambiguity
- User changes Distance → call `recalculateFromDistance()`
- User changes Time → call `recalculateFromTime()`
- User changes Pace → call `recalculateFromPace()`

### Correct Math
Each method implements the correct formula for its situation:
- If distance changed and time is locked → recalc pace
- If distance changed and pace is locked → recalc time
- If time changed and distance is locked → recalc pace
- If time changed and pace is locked → recalc distance
- If pace changed and distance is locked → recalc time
- If pace changed and time is locked → recalc distance

## Testing

### Test Each Mode

**Distance Mode Tests:**
```
1. Lock Distance at 5km
2. Change Time: 30→35min → Pace should become 7 min/km ✓
3. Change Time: 35→30min → Pace should become 6 min/km ✓
4. Change Pace: 6→7 min/km → Time should become 35min ✓
5. Change Pace: 7→6 min/km → Time should become 30min ✓
6. Distance should stay at 5km throughout ✓
```

**Time Mode Tests:**
```
1. Lock Time at 30min
2. Change Distance: 5→6km → Pace should become 5 min/km ✓
3. Change Distance: 6→5km → Pace should become 6 min/km ✓
4. Change Pace: 6→5 min/km → Distance should become 6km ✓
5. Change Pace: 5→6 min/km → Distance should become 5km ✓
6. Time should stay at 30min throughout ✓
```

**Pace Mode Tests:**
```
1. Lock Pace at 6 min/km
2. Change Distance: 5→6km → Time should become 36min ✓
3. Change Distance: 6→5km → Time should become 30min ✓
4. Change Time: 30→36min → Distance should become 6km ✓
5. Change Time: 36→30min → Distance should become 5km ✓
6. Pace should stay at 6 min/km throughout ✓
```

## Summary

### What Was Broken
- Unlocked controls weren't adjustable
- Values would jump back to calculated values
- User changes were ignored

### Why It Was Broken
- Single `recalculateValues()` didn't know which value user changed
- Always recalculated the wrong value
- Created infinite update loops

### How It Was Fixed
- Three specific recalculation methods
- Each knows which value user changed
- Each calculates the correct dependent value
- Clear, unambiguous logic flow

### Result
✅ Locked value stays locked (as expected)  
✅ Unlocked values are adjustable (as expected)  
✅ Third value recalculates correctly (as expected)  
✅ Math is always consistent  
✅ No infinite loops  
✅ Smooth, predictable behavior  

---

**Status**: ✅ Fixed  
**Version**: 1.1.3  
**Date**: January 11, 2026  
**Impact**: Critical - Core feature now works correctly
