#!/bin/bash

# Documentation Cleanup Script
# Removes unnecessary/redundant markdown files
# Keeps only essential documentation

echo "🧹 Cleaning up unnecessary documentation files..."
echo ""

# Files to delete
FILES_TO_DELETE=(
    "REFACTORING_INSTRUCTIONS.md"
    "RENAME_TO_RUNZONE.md"
    "RUNZONE_BRANDING.md"
    "BUILD_ERRORS_FIXED.md"
    "APP_ICON_GUIDE.md"
    "ICON_QUICK_START.md"
    "ROUTE_PREVIEW_FEATURE.md"
    "BUILD_FIXES.md"
    "IMPROVEMENTS_COMPLETE.md"
    "ALL_FEATURES_IMPLEMENTED.md"
    "SETTINGS_FEATURE.md"
    "DARK_MODE_BUILD_FIXES.md"
    "Documentation/REFACTORING_GUIDE.md"
    "Documentation/CODEBASE_SUMMARY.md"
    "Documentation/README.md"
    "Documentation/PROJECT_STRUCTURE.md"
    "refactor.sh"
    "CLEANUP_PLAN.md"
)

# Delete files
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "✓ Deleted: $file"
    fi
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📚 Remaining documentation:"
echo "  - README.md (project overview)"
echo "  - Documentation/AI_AGENT_GUIDE.md (AI reference)"
echo "  - Documentation/PROJECT_ARCHITECTURE.md (architecture)"
echo "  - Documentation/QUICK_START.md (setup guide)"
echo ""
echo "🎉 All unnecessary files removed!"
