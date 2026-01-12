# Renaming App to "RunZone"

## Steps to Rename Your App

### 1. Update Display Name (What Users See)

**In Xcode:**
1. Select your project in the navigator (top item)
2. Select your app target
3. Go to the "General" tab
4. Find "Display Name" field
5. Change it to: **RunZone**

If "Display Name" doesn't exist:
1. Go to the "Info" tab
2. Add a new row (click the + button)
3. Key: `CFBundleDisplayName`
4. Value: `RunZone`

### 2. Update Info.plist (If You Have One)

If you have an `Info.plist` file:
```xml
<key>CFBundleDisplayName</key>
<string>RunZone</string>

<key>CFBundleName</key>
<string>RunZone</string>
```

### 3. Update App Icon Guide

The app is now called **RunZone** instead of "Route Runner"!

Update the icon design concept:
- Main branding: "RunZone"
- Tagline: "Your Running Zone"
- Keep the same visual design (runner + circular route)

### 4. Update Privacy Descriptions (Info.plist)

Make sure these reference "RunZone":

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>RunZone needs your location to track your run and plan routes</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>RunZone needs your location to track your runs even when the app is in the background</string>

<key>NSMotionUsageDescription</key>
<string>RunZone uses motion data to track your running activity</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>RunZone uses speech to provide voice-guided navigation during your run</string>
```

### 5. Update App Store Listing (When Ready)

When you submit to the App Store:
- **App Name**: RunZone
- **Subtitle**: "Circular Route Planner"
- **Description**: Start with "RunZone helps you discover..."

### 6. Update Marketing Materials

Update any:
- Documentation references
- README files
- Screenshots
- Promotional materials

### 7. Optional: Update Project Name (Advanced)

If you want to rename the actual Xcode project (not just the display name):

⚠️ **Warning**: This is more complex and can break things. Only do if necessary.

1. Click on project name in navigator
2. Press Enter to rename
3. Xcode will show rename dialog
4. Check all items you want to rename
5. Click "Rename"

**Safer approach**: Just change the display name and keep internal project name as-is.

---

## Quick Command-Line Method

If you have a `Info.plist` file, you can update it via command line:

```bash
# Navigate to your project directory
cd /path/to/your/project

# Update display name
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName RunZone" Info.plist

# Update bundle name
/usr/libexec/PlistBuddy -c "Set :CFBundleName RunZone" Info.plist
```

---

## What Users Will See

After making these changes:

**Home Screen:**
```
┌─────────┐
│  [🏃]  │  ← Your app icon
│         │
│ RunZone │  ← New name!
└─────────┘
```

**App Switcher:**
```
RunZone
```

**Settings:**
```
RunZone
  Location: While Using
  Notifications: On
```

**App Store:**
```
RunZone
Circular Route Planner
★★★★★ 4.8 • Health & Fitness
```

---

## Testing the Change

1. Build and run on your iPhone (⌘ + R)
2. Close the app
3. Go to Home Screen
4. Look for the new "RunZone" name under your icon
5. Check Settings → RunZone

If the old name still appears:
- Clean build folder (⌘ + Shift + K)
- Delete app from device
- Rebuild and reinstall

---

## Update Icon Generator Code

Since the app is now "RunZone", you might want to update the icon:

```swift
// Optional: Add "RZ" monogram version
struct RunZoneMonogramIcon: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // "RZ" text
            Text("RZ")
                .font(.system(size: 500, weight: .black))
                .foregroundColor(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}
```

---

## Summary Checklist

- [x] Update Display Name to "RunZone"
- [x] Update Info.plist CFBundleDisplayName
- [x] Update privacy descriptions to reference "RunZone"
- [ ] Test on device to confirm new name appears
- [ ] Update App Store listing (when ready to publish)
- [ ] Consider updating icon with "RunZone" branding

---

## Name Rationale: Why "RunZone" Works

✅ **Pros:**
- Short and memorable
- Easy to spell and say
- Combines "Run" (clear purpose) + "Zone" (area/territory)
- ".com" domain might be available
- Sounds energetic and focused
- No spaces (cleaner for URLs and usernames)

📱 **Brand Identity:**
- Instagram: @runzone or @runzoneapp
- Twitter: @runzoneapp
- Website: runzone.app or getrunzone.com
- Hashtag: #RunZone

🎨 **Tagline Ideas:**
- "Your Running Zone"
- "Find Your Running Zone"
- "Plan. Run. Repeat."
- "Circular Routes Made Simple"
- "Your Personal Running Circle"

---

## Next Steps

1. Make the changes above in Xcode
2. Build and test on your device
3. Verify "RunZone" appears everywhere
4. Update icon designs if desired
5. Update any documentation

The name change is complete! 🎉
