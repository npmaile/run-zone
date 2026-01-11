# Settings Feature Added - Distance Unit Preference

## What Was Added

### New Files
1. **SettingsView.swift** - Complete settings screen with:
   - Distance unit preference (Kilometers or Miles)
   - Segmented picker for easy switching
   - App version display
   - Navigation bar with Done button

### New Classes
- **SettingsManager** - ObservableObject that:
  - Manages distance unit preference
  - Persists setting to UserDefaults
  - Provides conversion helpers (toKilometers/fromKilometers)
  - Supports both kilometers and miles

- **DistanceUnit** - Enum with:
  - `.kilometers` and `.miles` cases
  - Abbreviation property ("km" or "mi")
  - Raw value for display ("Kilometers" or "Miles")

## Changes to ContentView

### Added State & Settings
```swift
@StateObject private var settings = SettingsManager()
@State private var showSettings = false
```

### Settings Button
- Added gear icon button to idle stats panel
- Opens settings sheet when tapped

### Unit-Aware Display
All distance displays now respect the user's preference:

1. **Distance Stat View** (Running & Idle)
   - Shows distance in preferred unit
   - Format: "X.XX km" or "X.XX mi"

2. **Distance Control** (Planning Screen)
   - Shows target distance in preferred unit
   - Wider frame (120pts) to accommodate unit label

3. **Calculated Pace View** (Planning Screen)
   - Speed: Shows "km/h" or "mph" based on preference
   - Pace: Shows "min/km" or "min/mi" based on preference
   - Calculations automatically convert to preferred unit

## How It Works

### User Flow
1. **Open Settings**: Tap gear icon (⚙️) on idle screen
2. **Select Unit**: Choose Kilometers or Miles
3. **Automatic Update**: All distances immediately update
4. **Persisted**: Preference saved across app launches

### Internal Flow
```
User selects unit
    ↓
SettingsManager updates @Published property
    ↓
UserDefaults saves preference
    ↓
ContentView reacts to change
    ↓
All distance displays recalculate and update
```

### Conversion Logic
- **Storage**: All distances stored internally in kilometers
- **Display**: Converted to user's preferred unit on display
- **Input**: User adjusts in kilometers (internal), sees preferred unit

## Features

### Planning Screen Calculations

#### With Kilometers Selected:
- Target: 5.0 km in 30 min
- Speed: 10.00 km/h
- Pace: 6:00 min/km

#### With Miles Selected:
- Target: 3.1 mi in 30 min (same 5.0 km internally)
- Speed: 6.21 mph
- Pace: 9:39 min/mi

### Settings Screen
- Clean, native iOS design
- Form-based layout
- Segmented picker (easy to switch)
- Version info section
- Done button to dismiss

## Technical Details

### Settings Persistence
```swift
UserDefaults.standard.set(distanceUnit.rawValue, forKey: "distanceUnit")
```

### Distance Conversion
```swift
// Kilometers to Miles
miles = kilometers * 0.621371

// Miles to Kilometers
kilometers = miles * 1.60934
```

### Format Helper
```swift
formatDistance(_ km: Double) -> String
// Returns: "5.00 km" or "3.11 mi"
```

## Benefits

1. **User Preference**: Users can choose their familiar unit
2. **Consistent**: All distances use the same unit throughout
3. **Persistent**: Choice saved between app launches
4. **Easy Access**: Settings button always visible when not running
5. **Live Updates**: Changes apply immediately without restart

## UI Locations Using Unit Preference

1. ✅ Idle stats panel (current distance)
2. ✅ Running stats panel (current distance)
3. ✅ Distance control (target distance label)
4. ✅ Calculated pace view (speed and pace labels)

## Future Enhancements (Optional)

Possible additions:
- Temperature units (Celsius/Fahrenheit)
- Voice guidance language
- Theme selection (light/dark)
- Default distance/time values
- Route color customization
- Pace coaching sensitivity

## Build & Run

The app should build successfully with:
- ✅ New SettingsView.swift file
- ✅ Updated ContentView.swift
- ✅ Settings button on main screen
- ✅ Full unit preference support

**Press ⌘ + R to test the new settings feature!** ⚙️
