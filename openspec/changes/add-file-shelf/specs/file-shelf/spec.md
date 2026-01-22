# Spec: File Shelf

## ADDED Requirements

### Requirement: File Shelf UI
The application SHALL provide a dedicated "Shelf" tab that acts as a container for file references.

#### Scenario: Selecting the Shelf tab
- **Given** the application is running
- **When** the user clicks the "SHELF" tab icon
- **Then** the main view switches to the File Shelf view
- **And** the list of currently shelved files is displayed

### Requirement: Drop Files to Shelf
The application SHALL accept file drops from Finder or other applications and move the files into the shelf storage.

#### Scenario: Dropping files onto the shelf
- **Given** the user has selected the "SHELF" tab
- **When** the user drags one or more files from Finder into the shelf area
- **Then** the files are **moved** (not copied) from their original location to the application's internal storage
- **And** the files appear in the list with their icons and names

### Requirement: Batch Selection and Drag
The application SHALL allow users to select multiple files and drag them out together.

#### Scenario: Selecting multiple files
- **Given** there are multiple files in the shelf
- **When** the user clicks files while holding Command or Shift
- **Then** the files are visually selected (highlighted)

#### Scenario: Dragging multiple files
- **Given** multiple files are selected in the shelf
- **When** the user drags from the selection to a Finder window
- **Then** **all** selected files are moved/copied to the Finder location

### Requirement: Management and Persistence
The application SHALL persist the shelf contents and allow clearing.

#### Scenario: Clearing the shelf
- **Given** there are files in the shelf
- **When** the user clicks the "CLR" (Clear) button
- **Then** all files are removed from the shelf list

#### Scenario: Persistence
- **Given** the user has files in the shelf
- **When** the application is restarted
- **Then** the files appear in the shelf again
