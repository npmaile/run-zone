# Manual Route Editing Feature

## Overview
Users can now manually edit their routes by dragging waypoints, adding new points, and deleting unnecessary ones. This gives complete control over route customization.

## How to Access

### From Main Screen
1. Generate a route preview
2. See the orange **pencil icon (✏️)** next to distance
3. Tap to open Route Editor

### UI Location
```
Route Preview
5.0 km  [↻] [✏️] [ℹ️]    [⚙️]
         ↑   ↑    ↑
      Reverse Edit Info
```

## Features

### 1. **Drag Waypoints** 🖐️
- **Tap** any waypoint marker to select it
- **Drag** the marker to a new location
- Route automatically updates in real-time
- Works with all waypoints except start/end (they're the same)

### 2. **Add New Waypoints** ➕
- Tap **"Add Point"** button
- Tap anywhere on the map
- New waypoint inserted into route
- Can add unlimited waypoints

### 3. **Delete Waypoints** 🗑️
- Select a waypoint by tapping it
- Tap **"Delete"** button
- Waypoint removed from route
- Minimum 3 waypoints required

### 4. **Reset Route** ↻
- Tap **"Reset"** button
- Returns to original auto-generated route
- Discards all manual edits
- Useful for starting over

### 5. **Save Changes** ✅
- Tap **"Save"** in top-right
- Applies all edits to your route
- Returns to main screen with custom route
- Can start run with edited route

### 6. **Cancel/Discard** ❌
- Tap **"Cancel"** in top-left
- If you have unsaved changes, shows confirmation
- All edits are discarded
- Returns to original route

## User Interface

### Top Banner
Shows context-aware instructions:
- **Default**: "Tap waypoint to select or drag to move"
- **Add Mode**: "Tap on map to add waypoint"
- **Selected**: "Drag waypoint X to new position"

### Map
- **Green Flag**: Start/End point (same location)
- **Blue Pins**: Intermediate waypoints
- **Blue Dashed Line**: Route path
- **Highlighted Pin**: Currently selected waypoint

### Bottom Panel

**Waypoint Chips:**
```
[Flag] [1] [2] [3] [4] ...
Start
```
- Horizontal scrollable list
- Tap to select waypoint
- Selected chip highlighted in blue

**Action Buttons:**
```
┌─────────────┬──────────┬──────────┐
│ + Add Point │  Delete  │   Reset  │
└─────────────┴──────────┴──────────┘
```

## Use Cases

### Scenario 1: Avoid Busy Street
```
1. Generate 5km route
2. Notice it goes through busy street
3. Tap Edit button
4. Drag waypoint to quieter parallel street
5. Save changes
6. Start run on safer route
```

### Scenario 2: Add Scenic Detour
```
1. Auto-generated route is too direct
2. Tap Edit → Add Point
3. Add waypoint at scenic park
4. Route now includes park
5. Save and enjoy scenic run
```

### Scenario 3: Create Specific Shape
```
1. Start with any distance
2. Enter Edit mode
3. Drag waypoints to spell letters
4. Create heart shape, initials, etc.
5. Run your custom shape!
```

### Scenario 4: Remove Unnecessary Turn
```
1. Route has extra zigzag
2. Select unnecessary waypoint
3. Tap Delete
4. Route becomes more direct
5. Save streamlined route
```

## Technical Details

### Waypoint Management
- **Minimum**: 3 waypoints (ensures closed loop)
- **Maximum**: Unlimited (performance depends on device)
- **Order**: Maintained throughout editing
- **Start/End**: Always same point (circular route)

### Route Regeneration
When you move/add/delete waypoints:
1. New waypoint positions sent to RoutePlanner
2. MapKit recalculates route on real roads
3. New route displayed immediately
4. If MapKit fails, uses straight-line fallback

### Persistence
- Edits saved when you tap "Save"
- Unsaved changes lost if you cancel
- Edited routes stay until you change distance
- Can re-edit saved routes anytime

### Map Gestures
- **Single Tap (on waypoint)**: Select
- **Single Tap (on map, add mode)**: Add waypoint
- **Drag (on waypoint)**: Move waypoint
- **Pinch**: Zoom map
- **Two-finger drag**: Pan map

## Best Practices

### For Best Results:
✅ **Do:**
- Keep waypoints on roads/paths
- Space waypoints evenly for smooth routes
- Test route before starting run
- Use zoom for precise placement
- Add waypoints gradually

❌ **Don't:**
- Place too many waypoints close together
- Put waypoints in water or buildings
- Make dramatic angles (causes sharp turns)
- Move start point (it's fixed)
- Delete too many waypoints (min 3)

### Performance Tips
- **Fewer waypoints**: Faster route calculation
- **On roads**: Better MapKit routing
- **Moderate distance**: Easier to edit
- **Save regularly**: Don't lose work

## Visual Feedback

### Waypoint States

**Normal:**
```
  📍
   1
Blue, unselected
```

**Selected:**
```
  📍
   2
Blue highlight, ready to drag/delete
```

**Start:**
```
  🚩
Start
Green, cannot delete
```

### Route Line
- **Solid blue**: Successfully routed on roads
- **Dashed blue**: Preview or fallback

## Keyboard Shortcuts (Future)

Potential enhancements:
- **Delete**: Remove selected waypoint
- **Escape**: Deselect / Cancel add mode
- **Command+Z**: Undo last change
- **Command+S**: Save changes

## Error Handling

### If MapKit Fails:
- Shows simplified straight-line route
- Can still edit waypoints
- Will retry routing when you save

### If Too Many Waypoints:
- App may slow down
- Consider removing some points
- Reset to start over

### If Waypoints Too Close:
- Route might zigzag
- Spread waypoints further apart
- Use fewer, well-placed points

## Accessibility

- **VoiceOver**: All buttons labeled
- **Dynamic Type**: Text scales properly
- **Haptic Feedback**: Confirms actions
- **Color Blind**: Shape + color differentiation
- **Touch Target**: All buttons >44pt

## Integration with Other Features

### Works With:
✅ **Route Details**: Analyze edited route
✅ **Directional Arrows**: Show on custom route
✅ **Route Reversal**: Reverse edited route
✅ **Live Tracking**: Run custom route
✅ **Voice Navigation**: Navigate edited route

### Before Starting Run:
1. Edit route manually
2. Check route details (info button)
3. Reverse if needed
4. Start run with custom route

## Future Enhancements

Potential additions:
- **Save favorite routes**: Keep custom routes
- **Share routes**: Export to friends
- **Route templates**: Common patterns
- **Undo/Redo**: Step-by-step editing
- **Snap to roads**: Auto-align waypoints
- **Elevation aware**: See hills while editing
- **POI suggestions**: Add parks, water fountains
- **Route import**: Load GPX files
- **Multi-route comparison**: Edit & compare side-by-side

## Tips & Tricks

### Pro Tips:
1. **Zoom in** before dragging for precision
2. **Add waypoints first**, then fine-tune positions
3. **Use reset** if you make mistakes
4. **Preview route** before saving (check route details)
5. **Start simple** - can always add more points

### Common Patterns:

**Figure-8:**
```
1. Add waypoint at top
2. Add waypoint at middle crossing
3. Add waypoint at bottom
4. Adjust for perfect figure-8
```

**Out-and-Back:**
```
1. Keep 3 waypoints
2. Put middle waypoint far away
3. Creates there-and-back route
```

**Neighborhood Tour:**
```
1. Add waypoint at each corner
2. Creates route visiting all streets
3. Adjust for interesting spots
```

## Summary

The Route Editor gives you complete control over your running routes. Whether avoiding obstacles, adding scenic detours, or creating custom patterns, you can craft the perfect route for any run.

**Quick Access:** Route Preview → ✏️ Edit button

**Main Actions:**
- **Drag** waypoints to move
- **Add** waypoints by tapping map
- **Delete** selected waypoints
- **Reset** to start over
- **Save** to apply changes

Happy route editing! 🗺️✏️
