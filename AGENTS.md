# Repository Guidelines

## Project Structure & Module Organization
- `MacroBudget/`: SwiftUI app source, including `MacroBudgetApp.swift` (entry point) and views like `ContentView.swift`.
- `MacroBudget/Assets.xcassets/`: App icons, accent color, and image assets.
- `MacroBudgetTests/`: Unit tests using XCTest.
- `MacroBudgetUITests/`: UI tests and launch tests using XCTest.
- `MacroBudget.xcodeproj/`: Xcode project configuration and scheme.

## Build, Test, and Development Commands
Use Xcode for day-to-day development or `xcodebuild` for CI-style runs.
- Open project: `open MacroBudget.xcodeproj`
- Build (simulator): `xcodebuild -scheme MacroBudget -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests: `xcodebuild -scheme MacroBudget -destination 'platform=iOS Simulator,name=iPhone 15' test`
- UI tests only: `xcodebuild -scheme MacroBudget -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MacroBudgetUITests test`

## Coding Style & Naming Conventions
- SwiftUI + Swift 5 style, 4-space indentation (Xcode default).
- Types and files use PascalCase (e.g., `ContentView.swift`), properties and functions use camelCase.
- Prefer small, focused views and keep business logic out of SwiftUI body blocks.
- No formatter or linter is configured; keep code consistent with existing files.

## Testing Guidelines
- Framework: XCTest.
- Unit tests live in `MacroBudgetTests/`, UI tests in `MacroBudgetUITests/`.
- Name test methods with `test...` prefixes, and include a short scenario name (e.g., `testBudgetTotalsRenders`).
- Run tests via Xcode (Product > Test) or `xcodebuild` as above.

## Commit & Pull Request Guidelines
- Git history only includes "Initial Commit"; there is no established convention yet.
- Use concise, imperative commit subjects (e.g., "Add budget entry model").
- PRs should include: a short summary, testing performed, and screenshots for UI changes.
- Link relevant issues or tasks when available.

## Configuration Notes
- Simulator names vary by Xcode version; adjust the `-destination` value as needed (run `xcodebuild -list` to confirm schemes and destinations).
