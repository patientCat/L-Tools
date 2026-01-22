# Tasks: Init macOS Clipboard Manager

1.  Initialize Swift Project
    - Create a new Swift Package Manager executable structure or scaffold a macOS app directory structure manually (since we are in a CLI environment and might not have Xcode generators available, we'll assume a standard `swift package init` or manual file creation for an App bundle structure).
    - *Note*: Since we are making a macOS GUI app, we will use a `swift` file structure that can be built via `swiftc` or `xcodebuild` if available, or just a standard Swift Package executable that leverages `NSApplication`.
    - Set up `Info.plist` for `LSUIElement` (Menu Bar app).

2.  Implement `ClipboardService`
    - Create `ClipboardService.swift`.
    - Implement `Timer` loop to check `NSPasteboard.general.changeCount`.
    - Add logic to read string and publish changes via Combine `ObservableObject`.

3.  Implement `HistoryStore`
    - Create `HistoryStore.swift` to manage the array of `ClipboardItem`.
    - Implement `save` and `load` using `UserDefaults` or JSON.
    - Integrate with `ClipboardService` to auto-save on new copies.

4.  Implement UI (`MenuBarView`)
    - Create `MenuBarView.swift` (SwiftUI).
    - Design the list row.
    - Wire up selection action to write back to `NSPasteboard`.

5.  Wire up `ClipsApp`
    - Create `main.swift` or `ClipsApp.swift` using `@main` struct conforming to `App`.
    - Configure `NSStatusItem` in `AppDelegate` (or SwiftUI equivalent).
    - Connect the Popover.

6.  Validation
    - Build and Run.
    - Test copying text from another app.
    - Test clicking item in menu to restore it.
