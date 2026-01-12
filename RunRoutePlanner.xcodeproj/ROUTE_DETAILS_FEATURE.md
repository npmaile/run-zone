# Route Details Screen

## Overview
A comprehensive route analysis screen that provides detailed information about the planned route including turns, elevation changes, surface breakdown, and difficulty rating.

## Features

### 1. **Header Statistics** 📊
Four key metrics displayed prominently:
- **Turns**: Total number of significant turns
- **Elevation Gain**: Total meters climbed
- **Elevation Loss**: Total meters descended  
- **Estimated Time**: Calculated completion time

### 2. **Elevation Profile Chart** 📈
- **Visual Chart**: Line/area chart showing elevation over distance (iOS 16+)
- **Interactive**: Shows exact elevation at any point
- **Gradient Fill**: Blue gradient makes profile easy to read
- **Fallback**: Min/max elevation stats for iOS 15

### 3. **Turn Information** ↩️
Detailed breakdown of turns:
- **Right Turns**: Count of right-hand turns
- **Left Turns**: Count of left-hand turns
- **Sharp Turns**: Turns > 90 degrees

### 4. **Surface Breakdown** 🛤️
Percentage breakdown of route surface types:
- **Roads**: Paved streets and roads
- **Trails**: Running paths and trails
- **Unknown**: Unclassified segments

Each with:
- Percentage value
- Progress bar visualization
- Color-coded icons

### 5. **Additional Details** ℹ️
- **Average Grade**: Mean steepness across route
- **Max Grade**: Steepest section percentage
- **Difficulty Rating**: Easy / Moderate / Challenging / Hard

## UI Layout

```
┌─────────────────────────────────┐
│ Route Details         [Done]    │
├─────────────────────────────────┤
│                                  │
│  [8 Turns]    [↗ 45m Gain]      │
│  [↘ 42m Loss] [⏱ 28m Est]       │
│                                  │
│  Elevation Profile              │
│  ┌───────────────────┐          │
│  │    /\    /\       │          │
│  │   /  \  /  \      │          │
│  │  /    \/    \     │          │
│  └───────────────────┘          │
│                                  │
│  Turn Information               │
│  → Right Turns      5           │
│  ← Left Turns       3           │
│  ⤻ Sharp Turns      2           │
│                                  │
│  Surface Breakdown              │
│  🛣️ Roads           65.0%       │
│  ████████░░░░░░                 │
│  🥾 Trails          25.0%       │
│  ████░░░░░░░░░░                 │
│  ❓ Unknown         10.0%       │
│  ██░░░░░░░░░░░░                 │
│                                  │
│  Additional Details             │
│  Average Grade     3.2%         │
│  Max Grade         8.5%         │
│  Difficulty        Moderate     │
│                                  │
└─────────────────────────────────┘
```

## How to Access

### From Main Screen
1. Generate a route preview
2. See green info button (ℹ️) next to distance
3. Tap info button
4. Route details sheet appears

### UI Indicators
```
Top Panel:
┌──────────────────────────────┐
│ Route Preview                │
│ 5.0 km  [↻] [ℹ️]      [⚙️]  │
└──────────────────────────────┘
         ↑    ↑
      Reverse  Info (Route Details)
```

## Data Analysis

### Turn Detection
- Samples every 20 route points
- Calculates bearing change between segments
- Classifies as turn if change > 30°
- Marks as sharp turn if change > 90°

### Elevation Analysis  
- Samples every 50 route points
- Uses elevation API (or simulation for demo)
- Calculates gain/loss between points
- Computes grade percentage
- Generates profile for chart

### Surface Classification
- Analyzes MapKit route steps
- Scans instruction text for keywords:
  - "trail", "path" → Trail
  - "road", "street", "avenue" → Road
  - Other → Unknown
- Calculates percentage breakdown

### Difficulty Calculation
Based on three factors:
1. **Elevation Gain**:
   - \> 200m: +3 points
   - \> 100m: +2 points
   - \> 50m: +1 point

2. **Max Grade**:
   - \> 15%: +3 points
   - \> 10%: +2 points
   - \> 5%: +1 point

3. **Turns**:
   - \> 20: +2 points
   - \> 10: +1 point

**Final Rating**:
- 0-2 points: Easy
- 3-4 points: Moderate
- 5-6 points: Challenging
- 7+ points: Hard

### Time Estimation
```
Base Time = Distance (km) × 6 min/km
+ Elevation Adjustment = Gain (m) × 0.5 sec
+ Turn Adjustment = Turns × 2 sec
─────────────────────────────────
Total Estimated Time
```

## Benefits

### 1. **Informed Decisions**
- Know difficulty before starting
- Choose routes matching fitness level
- Plan based on elevation profile

### 2. **Better Preparation**
- Understand turn complexity
- Know when to expect hills
- Mentally prepare for challenges

### 3. **Route Comparison**
- Compare different distance options
- See which has less elevation
- Choose based on surface preference

### 4. **Training Insights**
- Find routes with desired difficulty
- Plan interval training on hilly routes
- Select flat routes for speed work

## Use Cases

### Scenario 1: Flat Route Seeker
```
User checks route details
↓
Sees 150m elevation gain
↓
Chooses shorter, flatter alternative
```

### Scenario 2: Hill Training
```
User wants challenging workout
↓
Checks difficulty: "Hard"
↓
Perfect! Selects this route
```

### Scenario 3: Trail Preference
```
User prefers natural surfaces
↓
Sees 70% roads, 30% trails
↓
Adjusts distance to find more trails
```

### Scenario 4: Turn Navigation
```
User not confident with directions
↓
Sees 15 turns
↓
Chooses simpler route with fewer turns
```

## Technical Notes

### Performance
- Route analysis runs asynchronously
- Results cached until route changes
- Only analyzes when info button tapped
- Efficient sampling (not every point)

### Accuracy
- **Turns**: Based on bearing changes (accurate)
- **Elevation**: Uses simulation (would use real API in production)
- **Surface**: Based on MapKit step instructions (good accuracy)
- **Time**: Estimation with conservative adjustments

### iOS Compatibility
- **iOS 16+**: Full chart visualization
- **iOS 15**: Text-based elevation stats
- All features work on both versions

### Memory Usage
- Lightweight analysis
- Stores minimal data
- Chart renders on demand
- Profile points sampled (not full route)

## Future Enhancements

Potential improvements:
- Real elevation API integration
- Weather conditions impact on time
- Historical pace data for personal estimates
- Route favoriting/saving
- Compare multiple routes side-by-side
- Export route details as PDF
- Share route stats with friends
- Track actual vs estimated performance
- Machine learning for better time estimates
- Point-of-interest markers
- Water fountain locations
- Restroom availability
- Lighting conditions for night runs
