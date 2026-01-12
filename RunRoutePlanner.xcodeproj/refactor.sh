#!/bin/bash

# RunZone Refactoring Script
# This script reorganizes the codebase into the target folder structure
# Run from the project root directory

set -e  # Exit on error

echo "🚀 Starting RunZone Codebase Refactoring..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup
echo "📦 Creating backup..."
BACKUP_DIR="RunZone_Backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "../$BACKUP_DIR"
cp -R . "../$BACKUP_DIR/"
echo -e "${GREEN}✓ Backup created at ../$BACKUP_DIR${NC}"
echo ""

# Phase 1: Create folder structure
echo "📁 Phase 1: Creating folder structure..."

mkdir -p Core/Models
mkdir -p Core/Managers
mkdir -p Core/Constants
mkdir -p Features/Main/Views
mkdir -p Features/Main/Components
mkdir -p Features/Main/Sheets
mkdir -p Features/RouteDetails/Views
mkdir -p Features/RouteEditor/Views
mkdir -p Features/RunHistory/Views
mkdir -p Features/Settings/Views
mkdir -p Resources/Assets.xcassets

echo -e "${GREEN}✓ Folders created${NC}"
echo ""

# Phase 2: Split Constants.swift
echo "📝 Phase 2: Splitting Constants.swift..."

# Note: This requires manual intervention to split the file
# The script will create placeholders

cat > Core/Constants/AppConstants.swift << 'EOF'
import Foundation
import CoreLocation

// TODO: Move AppConstants enum from Constants.swift here
// Keep only the constants, not the color extensions

enum AppConstants {
    // Copy from Constants.swift
}
EOF

cat > Core/Constants/AppColors.swift << 'EOF'
import SwiftUI
import UIKit

// TODO: Move Color extension from Constants.swift here
// This should contain all the color definitions

extension Color {
    // Copy color definitions from Constants.swift
}

extension LinearGradient {
    // Copy gradient definitions from Constants.swift
}
EOF

echo -e "${YELLOW}⚠ Constants.swift needs manual splitting${NC}"
echo "  1. Copy AppConstants enum to Core/Constants/AppConstants.swift"
echo "  2. Copy Color extension to Core/Constants/AppColors.swift"
echo "  3. Delete original Constants.swift"
echo ""

# Phase 3: Split Models.swift
echo "📝 Phase 3: Organizing Models..."

cat > Core/Models/RunModels.swift << 'EOF'
import Foundation
import SwiftData

// TODO: Move Run, Split, WorkoutType from Models.swift here

// @Model
// class Run { }
// @Model  
// class Split { }
// enum WorkoutType { }
EOF

cat > Core/Models/RouteModels.swift << 'EOF'
import Foundation

// TODO: Move RouteDetails, ElevationPoint, RouteDifficulty from RoutePlanner.swift here

// struct RouteDetails { }
// struct ElevationPoint { }
// enum RouteDifficulty { }
EOF

cat > Core/Models/SettingsModels.swift << 'EOF'
import Foundation
import SwiftUI

// TODO: Move SettingsManager, DistanceUnit from SettingsView.swift here

// class SettingsManager { }
// enum DistanceUnit { }
EOF

echo -e "${YELLOW}⚠ Models need manual organization${NC}"
echo "  1. Move types to appropriate model files"
echo "  2. Update imports in original files"
echo ""

# Phase 4: Move Managers (these can be moved directly)
echo "📦 Phase 4: Moving Manager files..."

# These files can be moved if they exist
if [ -f "RoutePlanner.swift" ]; then
    echo "  Moving RoutePlanner.swift..."
    # Can't actually move in this script - needs Xcode
fi

if [ -f "LocationManager.swift" ]; then
    echo "  Moving LocationManager.swift..."
fi

if [ -f "NavigationManager.swift" ]; then
    echo "  Moving NavigationManager.swift..."
fi

if [ -f "HealthKitManager.swift" ]; then
    echo "  Moving HealthKitManager.swift..."
fi

echo -e "${YELLOW}⚠ Manager files need to be moved in Xcode${NC}"
echo "  Drag these files to Core/Managers/ in Xcode:"
echo "  - RoutePlanner.swift"
echo "  - LocationManager.swift"
echo "  - NavigationManager.swift"
echo "  - HealthKitManager.swift"
echo ""

# Phase 5: Feature Views
echo "📦 Phase 5: Organizing Feature Views..."

cat > Features/Main/Views/MainView.swift << 'EOF'
import SwiftUI

// TODO: This will become the simplified ContentView
// Extract components to separate files first

struct MainView: View {
    var body: some View {
        Text("Main View")
    }
}
EOF

echo -e "${YELLOW}⚠ Feature views need manual organization${NC}"
echo "  1. MapView.swift → Features/Main/Views/"
echo "  2. RunHistoryView.swift → Features/RunHistory/Views/"
echo "  3. SettingsView.swift → Features/Settings/Views/"
echo ""

# Phase 6: Create README in each directory
echo "📄 Phase 6: Creating directory READMEs..."

cat > Core/README.md << 'EOF'
# Core

Contains core business logic and data structures.

## Structure

- **Models/**: Data structures
- **Managers/**: Business logic (ObservableObject classes)
- **Constants/**: Configuration and theming

## Guidelines

- Models should be pure data (no business logic)
- Managers should be ObservableObject
- Constants should be static values only
EOF

cat > Features/README.md << 'EOF'
# Features

Contains feature-specific UI and logic.

## Structure

- **Main/**: Main app screen
- **RouteDetails/**: Route analysis
- **RouteEditor/**: Route customization
- **RunHistory/**: Past runs
- **Settings/**: User preferences

## Guidelines

- Each feature is self-contained
- Share via Core/ not between features
- Keep views focused and small
EOF

echo -e "${GREEN}✓ READMEs created${NC}"
echo ""

# Summary
echo "═══════════════════════════════════════════════"
echo "📋 Refactoring Summary"
echo "═══════════════════════════════════════════════"
echo ""
echo "✅ Completed:"
echo "  - Folder structure created"
echo "  - Placeholder files created"
echo "  - Directory READMEs added"
echo "  - Backup created"
echo ""
echo "⚠️  Manual Steps Required (IN XCODE):"
echo ""
echo "1. Split Constants.swift:"
echo "   a. Open Constants.swift"
echo "   b. Copy AppConstants to Core/Constants/AppConstants.swift"
echo "   c. Copy Color extensions to Core/Constants/AppColors.swift"
echo "   d. Delete Constants.swift"
echo ""
echo "2. Organize Models:"
echo "   a. Move Run/Split/WorkoutType to Core/Models/RunModels.swift"
echo "   b. Move RouteDetails to Core/Models/RouteModels.swift"
echo "   c. Move SettingsManager to Core/Models/SettingsModels.swift"
echo ""
echo "3. Move Managers (Drag in Xcode):"
echo "   a. RoutePlanner.swift → Core/Managers/"
echo "   b. LocationManager.swift → Core/Managers/"
echo "   c. NavigationManager.swift → Core/Managers/"
echo "   d. HealthKitManager.swift → Core/Managers/"
echo ""
echo "4. Move Feature Views (Drag in Xcode):"
echo "   a. MapView.swift → Features/Main/Views/"
echo "   b. RunHistoryView.swift → Features/RunHistory/Views/"
echo "   c. SettingsView.swift → Features/Settings/Views/"
echo ""
echo "5. Extract ContentView Components:"
echo "   a. Create Features/Main/Components/StatsPanel.swift"
echo "   b. Create Features/Main/Components/ControlPanel.swift"
echo "   c. Create Features/Main/Sheets/RunSummarySheet.swift"
echo "   d. Update ContentView to use these"
echo ""
echo "6. Update Imports:"
echo "   a. Build project (⌘ + B)"
echo "   b. Fix any import errors"
echo "   c. Ensure all files in Xcode target"
echo ""
echo "7. Test Thoroughly:"
echo "   a. Clean build (⌘ + Shift + K)"
echo "   b. Build (⌘ + B)"
echo "   c. Run on device (⌘ + R)"
echo "   d. Test all features"
echo "   e. Check light and dark mode"
echo ""
echo "═══════════════════════════════════════════════"
echo ""
echo "📚 See Documentation/REFACTORING_GUIDE.md for detailed instructions"
echo ""
echo -e "${GREEN}🎉 Folder structure is ready! Now complete manual steps in Xcode.${NC}"
EOF

chmod +x refactor.sh
