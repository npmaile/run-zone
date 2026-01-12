# Optimization Mode - User Guide

## What is Optimization Mode?

Optimization Mode lets you **lock** one running metric (distance, time, or pace) and adjust the others. The app automatically calculates the locked value for you!

## Quick Start

### Step 1: Open Settings
Tap **"Adjust Distance & Time"** at the bottom of the map

### Step 2: Choose Your Mode
Select what you want to lock:
- 🏃 **Distance** - "I must run exactly 5km"
- ⏱️ **Time** - "I have exactly 30 minutes"  
- ⚡ **Pace** - "I want to run at 6 min/km pace"

### Step 3: Adjust the Other Values
Use the **+** and **−** buttons to change unlocked values

### Step 4: See Results
The locked value updates automatically in the blue panel!

---

## The Three Modes

### 🏃 Distance Mode (Default)

**When to use**: You need to run a specific distance

**Example**: Training for a 5K race
```
✅ Lock: 5.0 km
🔧 Adjust: Time and Pace
💡 Result: "If I run at 6 min/km, it'll take 30 minutes"
```

**Perfect for**:
- Race training (5K, 10K, etc.)
- Route must be exact distance
- Building endurance at specific distances

---

### ⏱️ Time Mode

**When to use**: You have a fixed amount of time

**Example**: Lunch break run
```
✅ Lock: 30 minutes
🔧 Adjust: Distance and Pace
💡 Result: "In 30 minutes at 7 min/km, I can run 4.3 km"
```

**Perfect for**:
- Time-constrained workouts
- "I have 30 minutes before dinner"
- Fitting runs into busy schedule

---

### ⚡ Pace Mode

**When to use**: You want to maintain a specific pace

**Example**: Tempo run training
```
✅ Lock: 5.5 min/km
🔧 Adjust: Distance and Time
💡 Result: "At this pace, 10km will take 55 minutes"
```

**Perfect for**:
- Tempo runs
- Building speed consistency
- Training at target race pace
- Following training plan pace goals

---

## How It Works

### The Math
```
Pace (min/km) = Time (min) ÷ Distance (km)
Time (min) = Distance (km) × Pace (min/km)
Distance (km) = Time (min) ÷ Pace (min/km)
```

Don't worry - the app does this instantly for you! 🎯

### Visual Indicators

**Locked Value** (Blue 🔒):
- Cannot be changed
- Shows with lock icon
- Displays in blue color
- Buttons are grayed out

**Unlocked Values** (White):
- Can be adjusted
- Normal text color
- Active +/− buttons
- Changes affect locked value

---

## Examples

### Example 1: "I Want to Run 5K in Under 25 Minutes"

**Setup**:
1. Choose **Distance Mode** 🏃
2. Distance locks at **5.0 km**
3. Adjust **Pace** to see time result

**Try different paces**:
- 6.0 min/km → Time: 30 min ❌ (too slow)
- 5.5 min/km → Time: 27.5 min ❌ (still slow)
- 5.0 min/km → Time: 25 min ❌ (just barely)
- 4.8 min/km → Time: 24 min ✅ (success!)

**Result**: Need to run at 4.8 min/km pace to finish in under 25 minutes

---

### Example 2: "I Have 45 Minutes, How Far Can I Go?"

**Setup**:
1. Choose **Time Mode** ⏱️
2. Time locks at **45 minutes**
3. Adjust **Pace** to see distance

**Try different paces**:
- 8.0 min/km → Distance: 5.6 km (easy pace)
- 6.0 min/km → Distance: 7.5 km (moderate)
- 5.0 min/km → Distance: 9.0 km (fast!)

**Result**: Choose the pace you're comfortable with and see how far you'll go

---

### Example 3: "I Want to Run at My Marathon Pace"

**Setup**:
1. Choose **Pace Mode** ⚡
2. Pace locks at **5.5 min/km** (your target)
3. Adjust **Distance** and **Time** together

**Plan your workout**:
- 5 km @ 5.5 min/km = 27.5 minutes
- 10 km @ 5.5 min/km = 55 minutes
- 15 km @ 5.5 min/km = 82.5 minutes

**Result**: Perfect for tempo runs at race pace!

---

## Tips & Tricks

### 💡 Quick Switching
- Switch modes anytime to explore scenarios
- Values automatically recalculate
- No data is lost

### 💡 Experiment Freely
- Try different combinations
- See how pace affects time
- Learn what's realistic for you

### 💡 Use with Route Preview
- See the actual route on map
- Combine with route editor
- Visualize your plan

### 💡 Pace Guide
```
3.0-4.0 min/km → Elite runner (15-20 km/h)
4.0-5.0 min/km → Advanced runner (12-15 km/h)
5.0-6.0 min/km → Intermediate runner (10-12 km/h)
6.0-7.0 min/km → Recreational runner (8.5-10 km/h)
7.0-9.0 min/km → Beginner runner (6.5-8.5 km/h)
9.0+ min/km → Walking/Jogging (<6.5 km/h)
```

### 💡 Common Goals
- **5K in 30 min** = 6.0 min/km
- **5K in 25 min** = 5.0 min/km
- **10K in 60 min** = 6.0 min/km
- **10K in 50 min** = 5.0 min/km
- **Half Marathon in 2h** = 5.7 min/km

---

## Controls Reference

### Distance Control
```
Target Distance
[ − ]  5.0 km  [ + ]

Range: 1.0 - 50.0 km
Step: 1.0 km
```

### Time Control
```
Target Time
[ − ]  30m  [ + ]

Range: 5 - 300 minutes
Step: 5 minutes
```

### Pace Control
```
Target Pace
[ − ]  6.0 min/km  [ + ]

Range: 3.0 - 15.0 min/km
Step: 0.5 min/km
```

---

## Locked Value Display

The blue panel shows your locked value plus conversions:

```
┌─────────────────────────────────┐
│ 🔒 Locked Value                 │
│                                 │
│  5.0 km      10.0 mph  8:03/mi │
│  Distance    (calculated)       │
└─────────────────────────────────┘
```

**Shows**:
- Your locked value
- Speed in mph
- Pace in min/mile

---

## Common Questions

### Q: Can I lock multiple values?
**A**: No, only one value can be locked at a time. The other two adjust the locked value.

### Q: What happens if I switch modes?
**A**: Your values recalculate based on the new locked value. Nothing is lost.

### Q: Can I use miles instead of kilometers?
**A**: Currently km only, but mile support coming soon! Change distance unit in Settings.

### Q: Why can't I change the locked value?
**A**: That's the point! The locked value is calculated from the other two. Switch modes if you want to lock a different value.

### Q: What's a good pace for beginners?
**A**: Start around 7-8 min/km (11-12 min/mile). Listen to your body!

### Q: The calculations seem wrong?
**A**: Make sure you're in the right mode. Check which value is locked (blue with 🔒).

---

## Workflow Examples

### Planning a Training Week

**Monday - Recovery Run**
- Mode: Time ⏱️
- Lock: 30 minutes
- Pace: 7.5 min/km (easy)
- Result: ~4 km

**Wednesday - Tempo Run**
- Mode: Pace ⚡
- Lock: 5.5 min/km (target pace)
- Distance: 8 km
- Result: 44 minutes

**Saturday - Long Run**
- Mode: Distance 🏃
- Lock: 15 km
- Pace: 6.5 min/km
- Result: 97.5 minutes

### Race Day Planning

**Goal: 5K in under 25 minutes**

1. **Distance Mode**: Lock 5.0 km
2. **Try paces**:
   - 5.0 min/km = 25:00 (just made it!)
   - 4.8 min/km = 24:00 (comfortable margin)
3. **Decision**: Train for 4.8 min/km
4. **Pace Mode**: Lock 4.8 min/km
5. **Plan training**: 
   - 3 km @ pace = 14:24
   - 5 km @ pace = 24:00
   - 8 km @ pace = 38:24

---

## Troubleshooting

### Values Jump Around
- This is normal when switching modes
- The app recalculates based on new locked value
- Values always stay within valid ranges

### Can't Increase/Decrease
- Check if that value is locked (blue)
- Switch to a different mode if needed
- Check you haven't hit min/max limit

### Pace Seems Too Fast/Slow
- Compare with past runs
- Use the conversion to min/mile if more familiar
- Check mph speed for reference

---

## Benefits

✅ **Flexible Planning** - Adapt to any constraint  
✅ **Real-time Feedback** - See results instantly  
✅ **Learn Relationships** - Understand pace/distance/time  
✅ **No Math Required** - App calculates for you  
✅ **Professional Features** - Train like the pros  

---

## Next Steps

1. **Try all three modes** - Get familiar with each
2. **Plan your next run** - Use your constraint
3. **Start your run** - Tap "Start Run"
4. **Track progress** - See live stats during run
5. **Review results** - Check run history

---

## Related Features

- **Route Editor** - Adjust route complexity
- **Route Details** - See elevation and turns
- **Voice Guidance** - Turn-by-turn directions
- **Pace Coaching** - Real-time pace feedback
- **Run History** - Review past runs

---

**Happy Running! 🏃‍♂️💨**

*For questions or feedback, see the app settings or documentation.*

---

**Version**: 1.1.0  
**Updated**: January 11, 2026
