# MacroBudget

MacroBudget is a local-only iOS 17+ SwiftUI app for tracking calories and macros like a daily budget.

## Features
- Daily limits for calories, protein, fat, and carbs.
- Log meals quickly with meal type, time, and optional notes.
- Analytics for day/week/month using Swift Charts.
- Presets and norm calculation to set recommended limits.
- CSV export and JSON backup/restore (local only).
- Gentle streaks based on daily logging (no penalties).

## Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

## Run
- Open `MacroBudget.xcodeproj` in Xcode.
- Select an iOS 17+ simulator or device.
- Press Run.

## Tests
- Run in Xcode (Product -> Test) or:

```sh
xcodebuild -scheme MacroBudget -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Data & Privacy
All data stays on device. Exports and backups are files you explicitly share.
