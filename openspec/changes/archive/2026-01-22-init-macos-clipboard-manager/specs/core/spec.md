# Core Clipboard Functionality

## ADDED Requirements

### Requirement: Application Entry Point
The application MUST launch as a Menu Bar agent without a Dock icon.

#### Scenario: Launch
- When the user starts the application, it appears **only** in the macOS menu bar (status bar) with an icon.
- It does **not** show an app icon in the Dock.
- It does **not** open a main window by default.

### Requirement: Clipboard Monitoring
The application MUST detect when plain text is copied to the system clipboard from any other application.

#### Scenario: Copying Text
- Given the application is running
- When the user copies "Hello World" in a text editor
- Then the application detects the change
- And adds "Hello World" to the internal history list.

#### Scenario: Duplicate Content
- Given "Hello World" is the most recent item in history
- When the user copies "Hello World" again
- Then the application does **not** create a duplicate entry at the top of the list (it may update the timestamp).

### Requirement: History Storage
The application MUST persist the clipboard history between launches.

#### Scenario: App Restart
- Given the history contains "Item A" and "Item B"
- When the application is quit and restarted
- Then the history still contains "Item A" and "Item B".

### Requirement: Menu Bar Interface
The application MUST provide a visual list of clipboard history accessible from the menu bar.

#### Scenario: Viewing History
- When the user clicks the menu bar icon
- Then a popover or menu appears displaying the list of copied items (most recent at the top).

#### Scenario: Selecting an Item
- Given the menu is open
- When the user clicks on a history item
- Then that item's text is written back to the system clipboard
- And the menu closes.
