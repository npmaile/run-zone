# Apple Watch Companion App

The Run Route Planner now includes a companion app for Apple Watch, allowing runners to track their progress without needing to pull out their iPhone.

## Features

### Automatic Syncing
- Real-time sync with iPhone app every 2 seconds during runs
- Shows target distance and time goals set on iPhone
- Updates instantly when you change goals on iPhone

### Two-Tab Interface

#### Stats Tab (Swipe Left/Right)
- **Distance**: Current distance covered in kilometers
- **Time**: Elapsed time vs target time goal
- **Remaining**: Distance remaining to complete the goal

#### Pace Tab
- **Current Pace**: Live pace in min/km with color coding
  - 🟢 Green: On pace
  - 🟠 Orange: Slightly off pace (5-15%)
  - 🔴 Red: Significantly off pace (>15%)
- **Target Pace**: Your goal pace calculated from distance/time
- **Status Icon**: Visual indicator
  - ✓ Checkmark: On pace
  - 🐰 Hare: Running slow (speed up)
  - 🐢 Tortoise: Running fast (slow down)
- **Status Text**: Simple guidance ("Speed up!", "On pace", "Slow down!")

### Idle Screen
When not running, the Watch app shows:
- App icon and name
- Current distance and time goals
- Connection status with iPhone
- Instructions to start run on iPhone

### Connectivity
- Uses WatchConnectivity framework for real-time communication
- Shows connection status
- Gracefully handles disconnections
- Automatically reconnects when iPhone comes back in range

## How to Use

1. **Pair your Apple Watch** with your iPhone if not already done
2. **Install the Watch app** (automatically installs when you install the iPhone app)
3. **Open the iPhone app** and set your distance and time goals
4. **Open the Watch app** to see your goals synced
5. **Start your run** on the iPhone
6. **Glance at your Watch** to see live stats without pulling out your phone
7. **Swipe left/right** to switch between Stats and Pace views

## Technical Details

### Communication
- Uses `WCSession` for bidirectional communication
- Sends updates from iPhone to Watch every 2 seconds
- Payload includes:
  - Run state (running/stopped)
  - Distance traveled
  - Elapsed time
  - Current pace
  - Pace status (too slow/on pace/too fast)
  - Target goals

### Requirements
- watchOS 8.0 or later
- iPhone running iOS 15.0 or later
- Paired Apple Watch
- Bluetooth enabled on both devices

### Battery Optimization
- Uses efficient message passing (no continuous streaming)
- 2-second update interval balances responsiveness with battery life
- Watch app sleeps when not in use
- Automatic cleanup when run ends

## Future Enhancements

Potential features for future updates:
- Haptic feedback for pace coaching alerts
- Complications for watch faces
- Standalone Watch workouts (without iPhone)
- Heart rate monitoring integration
- Custom watch face with run stats

## Troubleshooting

**Watch not connecting:**
- Ensure Bluetooth is enabled on both devices
- Check that Watch is paired in Watch app on iPhone
- Restart both devices if needed

**Stats not updating:**
- Ensure iPhone app is running (can be in background)
- Check that run has been started on iPhone
- Verify Watch app shows "iPhone connected"

**Delayed updates:**
- Normal delay is 2 seconds
- Longer delays may indicate weak Bluetooth signal
- Move iPhone closer to Watch

