# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
- Open `CounterCounter.xcodeproj` in Xcode to build and run
- Use Xcode's built-in build system (⌘+B to build, ⌘+R to run)
- Minimum iOS version: 18.0
- Supports iPhone and iPad

### Testing
- Run unit tests: ⌘+U in Xcode or `xcodebuild test -project CounterCounter.xcodeproj -scheme CounterCounter -destination 'platform=iOS Simulator,name=iPhone 15'`
- Unit tests are in `CounterCounterTests/` 
- UI tests are in `CounterCounterUITests/`

## Architecture Overview

### Core Structure
- **CounterCounterApp.swift**: Main app entry point using SwiftUI App lifecycle
- **ContentView.swift**: Main container handling multi-player layouts and swipe gestures
- **CounterView.swift**: Individual player counter with tap gestures and life tracking
- **PreferencesView.swift**: Settings sheet for game configuration

### State Management
- **AppSettings**: Singleton ObservableObject managing global app state
  - `selectedPalette`: Color theme (Grayscale, Sage, Sunrise)
  - `numberOfPlayers`: 1-4 player support with dynamic layouts
  - `defaultStartingLife`: Starting life total for new games

### Key Patterns
- **Dynamic Layout System**: ContentView switches between 1-4 player layouts using VStack/HStack combinations
- **Gesture System**: ContentView handles global swipe gestures for player management and preferences, while CounterView handles individual counter taps
- **Color Theming**: Asset catalog-based color system with extensions on Color for dynamic palette support
- **Sheet Presentations**: Preferences and life picker use SwiftUI sheets with proper dismiss handling

### Interaction Model
- **Tap Gestures**: Top half of counter increases life, bottom half decreases
- **Swipe Gestures**: Left/right adjusts player count, down opens preferences
- **Long Press**: Opens life total picker for precise value setting
- **Visual Feedback**: Swipe indicators slide in from edges, numeric transitions animate value changes

## Current Development Todo List

### ✅ COMPLETED
1. **Analyze player orientation issues** - Completed analysis of 1-4 player layouts
2. **Fix 2-player layout orientations** - Fixed portrait (top/bottom with rotation) and landscape (side-by-side, both upright)
3. **Fix 3-player layout orientations** - Fixed portrait (top 2 rotated 180°, bottom 1 upright) and landscape (all 3 side-by-side upright)
4. **Fix 4-player layout orientations** - Fixed portrait (top: P3,P4 rotated 180°, bottom: P1,P2 upright) and landscape (same positions, all upright, fontSize 120, vStackSpacing 0)

### 🔄 IN PROGRESS  
5. **Fix swipe gesture for increasing player count** - Current: swipe right increases
6. **Fix swipe gesture for decreasing player count** - Current: swipe left decreases

### ⏳ PENDING
7. **Implement smooth animation for adding counter views** - Add transition animations when player count increases
8. **Implement smooth animation for removing counter views** - Add transition animations when player count decreases  
9. **Update and improve PreferencesView/settings functionality** - Enhance settings interface
10. **Test all player count transitions and orientations** - Comprehensive testing of all layouts and gestures