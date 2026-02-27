# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
- Open `CounterCounter.xcodeproj` in Xcode to build and run
- Use Xcode's built-in build system (⌘+B to build, ⌘+R to run)
- Minimum iOS version: 18.0
- Supports iPhone and iPad (both orientations)
- No external dependencies — pure SwiftUI with no CocoaPods or SPM packages

### Testing
- Run unit tests: ⌘+U in Xcode or `xcodebuild test -project CounterCounter.xcodeproj -scheme CounterCounter -destination 'platform=iOS Simulator,name=iPhone 15'`
- Unit tests are in `CounterCounterTests/` (uses Swift Testing framework, not XCTest)
- UI tests are in `CounterCounterUITests/` (uses XCTest)

## Architecture Overview

### Core Structure
- **CounterCounterApp.swift**: Main app entry point using SwiftUI App lifecycle; minimal — delegates to `ContentView`
- **ContentView.swift**: Main container handling multi-player layouts, swipe gestures, and the sliding action menu
- **CounterView.swift**: Individual player counter, life tracking gestures, `AppSettings` singleton, and `Color` extensions
- **PreferencesView.swift**: Settings sheet with a pending-state Cancel/Apply pattern

### State Management
- **AppSettings** (`CounterView.swift`): Singleton `ObservableObject` managing global app state
  - `selectedPalette: ColorPalette` — active color theme (Grayscale, Sage, Sunrise)
  - `numberOfPlayers: Int` — 1–4 player support
  - `selectedStartingLifeOption: StartingLifeOption` — preset life value (.three, .four, .five, .custom)
  - `customStartingLifeValue: String` — in-progress text input for a custom starting life value
  - `appliedCustomStartingLife: Int?` — the validated custom value actually in use
  - `effectiveStartingLife: Int` — computed; returns the active starting life (preset or applied custom)
- **PreferencesView pending state**: All settings changes are staged in local `@State` variables and only committed to `AppSettings` when the user taps "Apply"
- **settingsResetTrigger: UUID** (in `ContentView`): Changing this forces all `CounterView` instances to re-initialize with the new starting life total
- **UserDefaults**: Stores `hasShownMenuHint` to track whether the first-time swipe hint has been shown

### Key Types
- **`ColorPalette: String, CaseIterable, Identifiable`** — `.grayscale`, `.sage`, `.sunrise`
- **`StartingLifeOption: Int, CaseIterable`** — `.three` (3), `.four` (4), `.five` (5), `.custom` (-1); default is `.five`
- **`LifePickerView`** — sheet presenting a wheel picker (0–99) bound to a counter's `lifeTotal`
- **`ColorPreviewCell`** — small color swatch shown in `PreferencesView` for the active player count

### Key Patterns
- **Dynamic Layout System**: `ContentView` switches between 1–4 player layouts using `VStack`/`HStack` combinations, with orientation detection via `GeometryReader` (`width > height` = landscape)
  - 1 player: full-screen
  - 2 players: side-by-side (landscape) or stacked with top player rotated 180° (portrait)
  - 3 players: three side-by-side (landscape) or two top rotated 180° + one bottom upright (portrait)
  - 4 players: 2×2 grid with top row rotated 180° (portrait)
- **Gesture System**:
  - `DragGesture` on `ContentView`: swipe left (>100pt) opens the action menu; swipe right closes it
  - `SpatialTapGesture` on `CounterView`: top-half tap increments life, bottom-half tap decrements (minimum 0)
  - `LongPressGesture` on `CounterView`: opens the `LifePickerView` sheet
  - Drag gestures are blocked while the menu hint animation is playing
- **Action Menu** (`ContentView`): right-sliding panel with Add Player, Remove Player, and Settings (opens `PreferencesView`) buttons; uses spring animation (response: 0.4, dampingFraction: 0.8)
- **First-Time Menu Hint**: on first launch, the action menu peeks open after a 1-second delay (650ms duration), then auto-hides; controlled by `hasUsedMenuThisSession` + UserDefaults
- **Color Theming**: asset catalog colors follow a naming convention (`GrayScale_Background1`–`4`, `Sage_Foreground1`–`2`, `Sunrise_Foreground`, etc.); loaded at runtime via `Color.background(for:in:)` and `Color.foreground(for:in:)` extension methods on `Color`; Sunrise palette uses a single shared foreground, Grayscale/Sage use two (players 1–2 vs 3–4)
- **Sheet Presentations**: `PreferencesView` and `LifePickerView` use SwiftUI `.sheet(isPresented:)` with `@Environment(\.dismiss)` for dismissal
- **Animations**: `.snappy(duration: 0.2)` on life total changes, `.contentTransition(.numericText(value:))` for the counter display, spring animations for menu and hint

### Interaction Model
- **Tap Gestures**: top half of counter increases life, bottom half decreases (min 0)
- **Swipe Left**: opens the action menu (Add/Remove Player, Settings)
- **Long Press**: opens the life total picker (wheel picker 0–99)

### Asset Catalog
Color sets live in `CounterCounter/Assets.xcassets/` and follow this structure:
- **Grayscale** (6 sets): `GrayScale_Background1`–`4`, `GrayScale_Foreground1`–`2`
- **Sage** (6 sets): `Sage_Background1`–`4`, `Sage_Foreground1`–`2`
- **Sunrise** (5 sets): `Sunrise_Background1`–`4`, `Sunrise_Foreground`
- **System**: `AccentColor`, `AppIcon`
