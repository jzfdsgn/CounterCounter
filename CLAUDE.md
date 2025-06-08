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