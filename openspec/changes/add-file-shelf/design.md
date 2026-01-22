# Design: File Shelf Architecture

## UI Changes
- **`MenuBarView.swift`**:
    - Add `.shelf` case to `ClipsTab` enum.
    - Add `shelfView` implementation in the switch statement.
- **`FileShelfView.swift`**:
    - A new SwiftUI view for the shelf interface.
    - Displays a grid or list of `ShelvedFile` items.
    - Uses `.onDrop` to accept files.
    - Uses `.onDrag` (on items) to export files.

## Data Model
- **`ShelvedFile`**:
    - `id`: UUID
    - `url`: URL (to the file on disk)
    - `addedDate`: Date
- **`FileShelfStore`**:
    - `ObservableObject`
    - `files`: `[ShelvedFile]`
    - Methods: `addFile(url: URL)`, `removeFile(id: UUID)`, `clear()`.
    - **Persistence**:
        - Store file paths/bookmarks in `UserDefaults` or a JSON file.
        - Ideally use **Security Scoped Bookmarks** to ensure we can access the file even if the app restarts (though strict sandboxing might not be enabled, it's best practice). For V1 rapid prototype, simple URL path storage might suffice if we assume no sandbox or user grants access. *Decision*: Store simple paths for V1 as this is a personal tool context, but structure it to easily swap to bookmarks.

## Interactions
1.  **Drag In**:
    - `FileShelfView` accepts `public.file-url`.
    - On drop, validate URL, create `ShelvedFile`, add to `FileShelfStore`.
2.  **Drag Out**:
    - List items have `.onDrag`.
    - Returns `NSItemProvider(object: url as NSURL)`.
3.  **Visuals**:
    - Use `NSWorkspace.shared.icon(forFile:)` to get file icons.
    - Pixel-art style list items consistent with existing theme.

## Edge Cases
- **File Moved/Deleted**: If the original file disappears, the shelf item becomes invalid. We should check reachability on load or render, and perhaps show a "broken" icon or auto-remove.
- **Duplicate Files**: Allow duplicates (maybe user wants to move same file to two places)? Or dedup? *Decision*: Allow duplicates in list (by ID), but typically users just want one reference.
