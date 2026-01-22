# Proposal: Add File Shelf

## Summary
Add a "File Shelf" tab to the Clips application. This feature serves as a temporary holding area (buffer) for files. Users can drag files from Finder (or other apps) into the Shelf, and subsequently drag them out to a destination. This simplifies moving files between different directories or full-screen applications.

## Problem Statement
Moving files in macOS often involves dragging items across long distances, switching spaces, or opening multiple Finder windows. If a user drops a file by accident during a long drag, they have to start over. There is no native "temporary holding zone" for files during drag-and-drop operations.

## Goals
- Add a new "SHELF" tab to the main UI.
- Allow dropping files (single or multiple) into this tab.
- Display dropped files with their icons and names.
- Allow dragging files *out* of the tab to Finder or other apps.
- Persist the list of shelved files across app restarts (using Security Scoped Bookmarks if necessary, or simple paths if not sandboxed/easier for v1).
- Provide a "Clear" button to empty the shelf.

## Non-Goals
- File content preview (beyond icon).
- Editing files within the shelf.
- Syncing files to cloud.

## User Impact
Users will have a "pocket" to put files while navigating the OS, making file management significantly less stressful.
