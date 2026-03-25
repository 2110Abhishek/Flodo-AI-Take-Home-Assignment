# Flodo AI Take-Home Assignment - Task Manager

This repository contains the Flutter Task Management application for the Flodo AI take-home assignment.

## Track and Stretch Goal Selection
- **Track B (The Mobile Specialist):** I chose this track to demonstrate a highly polished mobile experience. The app uses `shared_preferences` to persist data locally without a backend.
- **Stretch Goal 1 (Debounced Autocomplete Search):** Implemented an instant-filter search bar with a debounced underlying state update (300ms delay). The UI highlights the exact matching text strings in task titles as requested.

## Features Included
1. **Core CRUD:** Complete Create, Read, Update, and Delete capabilities for Tasks.
2. **Artificial Delay:** Task creation and updates have a simulated 2-second delay. The UI shows a clear loading indicator on the save button and disables it, preventing double taps.
3. **Task Data Model:** Full support for `Title`, `Description`, `Due Date`, `Status` (To-Do, In Progress, Done), and `Blocked By` (Selects another existing task).
4. **Drafts Persistence:** If you type in the new task form and exit or minimize the app, your session draft gets saved instantly. Re-opening the "New Task" screen will load the unsubmitted drafted text.
5. **Blocked UI Rule:** Tasks that are blocked by another incomplete task are displayed transparently/greyed-out, highlighting a "Blocked" badge with a lock icon in the list view.
6. **Search & Filter:** Debounced search text and a status filter dropdown.
7. **Polished UIDesign:** Developed using a high-quality modern color palette, `google_fonts` (Inter), and smooth interactive components leveraging Material 3.

## Setup Instructions

1. Ensure you have Flutter installed (version 3.19+ recommended).
2. Clone this repository.
3. Navigate to the project directory: `cd task_manager`
4. Run `flutter pub get` to download dependencies.
5. Run `flutter run` on your preferred device or emulator. Supported on iOS, Android, macOS, and Windows.

## AI Usage Guidelines
- Built autonomously using the Antigravity AI agent.
- High-quality code was generated with standard Flutter patterns via `provider`. State management and local data persistence were successfully unified without native complexities by using `shared_preferences`.

## 1-Minute Demo Video
- *(Replace with a Google Drive link when submitting)*

*Note to Reviewer: Provide view access to nilay@flodo.ai on Google Drive for the video link as instructed.*
