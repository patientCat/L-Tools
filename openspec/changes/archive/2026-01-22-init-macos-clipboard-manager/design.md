# Design: Clips Architecture

## Overview
Clips is a macOS Status Bar (Menu Bar) application. It runs in the background and interacts with the system pasteboard.

## Architecture

### 1. Application Lifecycle (`ClipsApp`)
- Uses the SwiftUI `App` protocol.
- Does not present a Dock icon (`LSUIElement` set to `YES` in Info.plist).
- Manages an `NSStatusItem` to reside in the system menu bar.

### 2. Clipboard Monitor (`ClipboardService`)
- **Mechanism**: Since macOS doesn't have a direct "clipboard changed" notification for background apps, we will use a polling mechanism combined with `NSPasteboard.general.changeCount`.
- **Logic**: A `Timer` fires every 0.5s to check if `changeCount` has incremented. If so, it reads the string content from the pasteboard.

### 3. Data Persistence (`HistoryStore`)
- **Storage**: JSON file stored in the app's sandbox `Application Support` directory or `UserDefaults` for simplicity in v1. Given the "last 50 items" constraint, `UserDefaults` is sufficient, but a JSON file is more extensible. We will use a simple `Codable` struct array persisted to disk.
- **Model**: `ClipboardItem(id: UUID, content: String, timestamp: Date)`.
- **Deduplication**: Consecutive duplicate copies are ignored. Moving an old item to the top if copied again.

### 4. User Interface (`MenuBarView`)
- **Structure**: A `Popover` or `NSMenu` attached to the status bar button.
- **View**: A SwiftUI `List` displaying truncated text of history items.
- **Interaction**: Clicking an item writes it back to `NSPasteboard` and optionally simulates `Cmd+V` (out of scope for v1, user can manually paste).
- **Controls**: "Quit" and "Clear History" buttons.

## Tech Stack
- **Language**: Swift 5+
- **Frameworks**: SwiftUI, AppKit, Combine
- **Platform**: macOS 12.0+

## Trade-offs
- **Polling vs. Global Hooks**: Polling `changeCount` is battery efficient and sandboxing-friendly compared to installing global event hooks which require Accessibility permissions.
