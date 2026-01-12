# Live Route Preview Feature

## What's New

Users can now see a **live preview of their running route** on the map while selecting their target distance and time - before they even start running!

## How It Works

### 1. **Automatic Preview Generation**
- As soon as the app opens and gets the user's location, a route preview is generated
- The route automatically updates when the user adjusts the target distance
- No need to start the run to see what the route will look like

### 2. **Real-Time Updates**
- Uses the same route planning algorithm as during actual runs
- Generates circular routes that return to the starting point
- Shows realistic routes using actual roads and paths via MapKit

### 3. **Visual Feedback**
- **Top Panel**: Shows "Route Preview" with the selected distance
- **Map**: Displays the planned route in blue (dashed line)
- **Bottom Panel**: Hint text "Adjust distance to see different routes" appears when a route is visible

## User Experience Benefits

### Before Starting
- **See Before You Run**: Know exactly where you'll be going
- **Compare Distances**: Quickly adjust distance slider to see different route options
- **Plan Better**: Choose a distance based on the actual route shown
- **No Surprises**: Routes are calculated the same way as during the run

### During Running
- The preview disappears and is replaced by:
  - Live tracking with completed path (green line)
  - Updated route planning (blue dashed line)
  - Real-time stats (distance, time, pace)

### After Running
- Route preview regenerates automatically
- Ready for the next run planning session

## Implementation Details

### New Event Handlers
1. **`handleTargetDistanceChange()`**: Triggers preview update when distance changes
2. **`generateRoutePreview(from:)`**: Generates route without starting tracking
3. **Enhanced `handleLocationChange()`**: Updates preview when not running

### Modified Methods
1. **`handleAppear()`**: Now generates initial preview
2. **`stopRun()`**: Regenerates preview after run cleanup
3. **`idleStatsPanel`**: Shows "Route Preview" label instead of just "Distance"

### State Management
- Preview uses same `RoutePlanner` instance
- Route updates are handled by existing `onChange(of: routePlanner.currentRoute)`
- Clean separation between preview mode and running mode

## Technical Notes

### Performance
- Route generation happens asynchronously via `RoutePlanner`
- MapKit directions API calls are rate-limited (every 30 seconds)
- Fallback geometric routes if network is unavailable

### Route Quality
- Preview routes use the same algorithm as active runs
- Circular routes that return to starting point
- Follows actual roads and paths when MapKit data available
- Target distance divided by 2π to calculate radius

## User Flow

```
1. App Opens
   ↓
2. Location Permission Granted
   ↓
3. Initial Route Preview Generated (5km default)
   ↓
4. User Adjusts Distance Slider (1km - 50km)
   ↓
5. Route Preview Updates in Real-Time
   ↓
6. User Sees Different Route Options
   ↓
7. User Presses "Start Run"
   ↓
8. Preview Transitions to Live Tracking
```

## Visual Indicators

### Idle State (Not Running)
- **Top Panel**: "Route Preview" + target distance
- **Map**: Blue dashed route line
- **Bottom Panel**: Configuration controls + hint text
- **Button**: Green "Start Run" button

### Running State
- **Top Panel**: Live stats (distance, time, pace)
- **Map**: Green completed path + blue route ahead
- **Bottom Panel**: Red "Stop Run" button
- **Hint**: "Follow the blue route on the map"

## Future Enhancements

Potential improvements:
- Save favorite routes
- Show elevation profile preview
- Display estimated time based on average pace
- Multiple route options to choose from
- Route difficulty indicator
- Points of interest along the route
- Weather conditions preview
