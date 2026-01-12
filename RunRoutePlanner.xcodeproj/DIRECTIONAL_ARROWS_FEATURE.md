# Directional Route Indicators

## New Features Added

### 1. **Directional Arrows on Route** 🔵➡️
The route preview now displays blue arrows showing which direction to run!

#### Visual Design
- **Arrow Placement**: ~8 arrows evenly distributed along the route
- **Arrow Style**: Solid blue arrows matching the route color
- **Rotation**: Each arrow points in the direction of travel
- **Dark Mode**: Arrows automatically adjust color for visibility

#### When Arrows Appear
- ✅ **Preview mode** (not running): Arrows visible
- ❌ **During run**: Arrows hidden (cleaner view while tracking)
- ✅ **After adjusting distance**: Arrows update with new route

### 2. **Reverse Route Button** ↻
Users can now reverse the direction of their route with one tap!

#### Location
- Appears in the **top panel** next to the distance
- Only visible when a route is loaded
- Shows different icons based on direction:
  - **Clockwise** (default): `↻` icon
  - **Counter-clockwise** (reversed): `↶` icon

#### Behavior
- **Tap**: Instantly reverses the route direction
- **Haptic Feedback**: Light tap feedback on reverse
- **Arrow Update**: Directional arrows flip to show new direction
- **Persistent**: Direction choice maintained until route changes

### 3. **Updated Hint Text** 💡
New helper text guides users:
> "Blue arrows show direction • Tap ↻ to reverse"

## User Experience Flow

### Planning a Route

```
1. Open app
   ↓
2. See route preview with blue arrows
   ↓
3. Observe direction: "Oh, it goes clockwise"
   ↓
4. Tap ↻ button if want to go opposite way
   ↓
5. Arrows flip - now shows counter-clockwise
   ↓
6. Adjust distance - arrows update with new route
   ↓
7. Start run with preferred direction
```

### Visual Layout

**Top Panel (Idle):**
```
┌─────────────────────────────────┐
│ Route Preview                   │
│ 5.0 km    [↻]          [⚙️]    │
└─────────────────────────────────┘
```

**Map View:**
```
     Start 🔵
        ↓
        ➡️  (Arrow showing direction)
        |
        ➡️
       / \
      /   \
     ➡️   ➡️
    /       \
  [Route]  [Route]
    \       /
     ➡️   ➡️
      \   /
       \ /
        ➡️
        |
        ↓
     End 🔵
```

**Bottom Panel:**
```
┌─────────────────────────────────┐
│ ➡️ Blue arrows show direction • │
│ Tap ↻ to reverse                │
└─────────────────────────────────┘
```

## Technical Implementation

### Arrow Generation Algorithm

1. **Calculate Arrow Positions**
   - Take route coordinates array
   - Place arrow every `totalPoints / 8` points
   - Minimum spacing: every 10 points

2. **Calculate Bearing**
   - For each arrow position, look ahead 5 points
   - Calculate bearing using haversine formula
   - Convert to degrees (0-360)

3. **Create Arrow Annotation**
   - Custom `MKAnnotation` subclass
   - Stores coordinate and bearing
   - Rendered as rotated arrow image

4. **Arrow Image Generation**
   ```swift
   - Size: 20x20 points
   - Shape: Traditional arrow (▲ with stem)
   - Color: Matches route color (blue)
   - Rotation: Applied via CGAffineTransform
   ```

### Route Reversal

```swift
func toggleDirection() {
    isReversed.toggle()
    currentRoute.reverse()        // Reverse coordinate array
    currentWaypoints.reverse()     // Reverse waypoints too
}
```

**Effect:**
- Arrows now point opposite direction
- Start and end are swapped
- Same roads, opposite flow

### Performance Considerations

- **Arrow Count**: Capped at ~8 arrows per route
- **Rendering**: Uses MapKit's efficient annotation system
- **Updates**: Only regenerate when route changes
- **Memory**: Minimal - reuses annotation views

## Benefits

### 1. **Clear Direction Communication**
- No ambiguity about which way to go
- Especially helpful for circular routes
- Reduces confusion at intersections

### 2. **Route Customization**
- Same distance, different experience
- Might prefer certain direction based on:
  - Hills (uphill early vs late)
  - Sun direction
  - Traffic patterns
  - Personal preference

### 3. **Better Planning**
- Can visualize the run before starting
- Know if you'll be going uphill or downhill first
- Plan based on energy levels

### 4. **Improved Safety**
- Understanding route direction helps with:
  - Planning water/rest stops
  - Knowing where you'll be at different times
  - Sharing route with others

## Use Cases

### Scenario 1: Hill Strategy
```
User sees route goes uphill in first half
↓
Taps reverse button
↓
Now ends with uphill (prefers this)
↓
Starts run with preferred direction
```

### Scenario 2: Scenic Route
```
Route passes park going clockwise
↓
User prefers park at end (cool-down)
↓
Reverses to go counter-clockwise
↓
Park becomes the final stretch
```

### Scenario 3: Sun Direction
```
Morning run, route goes east first
↓
User doesn't want sun in eyes
↓
Reverses to go west first
↓
Sun behind for most of run
```

## UI States

### No Route Loaded
- No arrows visible
- No reverse button
- Standard distance display

### Route Loaded (Default Direction)
- Blue arrows visible on map
- `↻` (clockwise) icon shown
- Hint: "Blue arrows show direction • Tap ↻ to reverse"

### Route Reversed
- Blue arrows flipped 180°
- `↶` (counter-clockwise) icon shown
- Same hint text
- Visual confirmation of reversal

### During Run
- No arrows (cleaner view)
- No reverse button (locked in)
- Focus on live tracking

## Accessibility

- **Visual**: Arrows provide clear visual direction
- **Color**: Blue matches route for consistency
- **Size**: 20pt arrows visible but not overwhelming
- **Contrast**: Works in light and dark mode
- **Haptic**: Touch feedback confirms button press

## Future Enhancements

Potential improvements:
- Animated arrows (flowing along route)
- Distance markers at arrow positions
- Elevation indicators on arrows
- Gradient arrows (green=easy, red=hard)
- Custom arrow intervals
- Show estimated time at each arrow
- Turn-by-turn at arrow positions
