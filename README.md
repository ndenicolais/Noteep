# Noteep

**Version:** 2.0.0  
**Author:** Nicola De Nicolais  
**Contact:** ndn21dev@gmail.com  
**License:** GNU GPL v3 with Additional Commercial Restrictions

> A digital notebook — notes, tasks, and calendar events in one place, synced via Firebase.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Screens](#screens)
- [State Management](#state-management)
- [Services & Utilities](#services--utilities)
- [Firebase Integration](#firebase-integration)
- [Theme & Styling](#theme--styling)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [License](#license)

---

## Overview

Noteep is a full-featured Flutter note-taking and productivity app. It combines **notes**, **tasks**, and a **calendar** into a single interface, backed by **Firebase Firestore** for real-time cloud sync and **Firebase Auth** for user authentication.

---

## Features

### Authentication
- **Google Sign-In** via Firebase Auth
- **Email / Password** sign-in and registration
- **Password reset** by email
- Persistent session — on app launch the user is redirected to Home if already authenticated

### Notes
| Feature | Details |
|---|---|
| Note types | Free-text note or Checklist |
| Rich styling | Font family, font size, bold, italic, strikethrough, text color, background color — with separate overrides for the title |
| Markdown | Full Markdown rendering inside notes |
| Audio notes | Record audio clips (AAC/M4A) directly inside a note; playback with waveform visualisation |
| Checklist items | Each item has its own `id`, text, and checked state |
| Pin | Pins a note to the top of the list |
| Archive | Moves note out of the main list without deleting it |
| Soft-delete / Trash | Moves note to Trash; auto-purged after **7 days** |
| Note lock | Protects a note behind biometric authentication (`local_auth`) |
| Reminders | Schedule a local notification for any note |
| Tags / Labels | Add multiple tags per note; manage (rename, delete) all tags from the Labels screen |
| Note linking | Cross-reference notes by linking their IDs |
| Reorder | Drag-and-drop reordering in both grid and list layouts |
| Search | Real-time full-text search across title and content |
| Sort | Sort by creation date, modification date, or custom order |
| Templates | 6 built-in templates (Meeting Notes, Daily Journal, Project Plan, Shopping List, Travel Packing, Brainstorming) |

### Tasks
| Feature | Details |
|---|---|
| Task lists | Create and manage named lists; tabs in the Tasks screen |
| Special tasks | Star a task to mark it as high-priority; visible in the "Speciali" tab |
| Subtasks | Nest sub-items under any task |
| Due date | Set a due date for each task |
| Recurrence | none / daily / weekly / monthly / yearly |
| Reminders | Schedule a local notification for any task |
| Tags | Same tagging system as notes |
| Pin / Archive | Same mechanics as notes |
| Soft-delete | 7-day auto-purge from Trash |
| Search & Sort | Real-time search; sort by date or custom order |
| Move between lists | Reassign a task to a different list |

### Calendar
| Feature | Details |
|---|---|
| Event types | Standard event, Birthday (`isBirthday`), Name day (`isNameDay`) |
| All-day events | Toggle for all-day duration |
| Recurrence | none / daily / weekly / monthly / yearly |
| Reminders | Local notification per event |
| Tags | Tagging system shared with notes and tasks |
| ICS Export | Export calendar events as an `.ics` file |
| ICS Import | Import events from an external `.ics` file |
| Mini calendar | Compact monthly calendar widget; full workspace view |
| Archive / Trash | Same soft-delete pipeline as notes and tasks |

### Reminders Screen
Dedicated screen listing all upcoming reminders across notes, tasks, and calendar events in a single view.

### Statistics
Visual dashboard with counts broken down by entity type (Notes, Tasks, Calendar Events) and state (Active, Archived, Trashed). Charts powered by `fl_chart`.

### Export
Export notes to **PDF** format (rendered with the `pdf` / `printing` packages); download link on web, share sheet on mobile.

### Backup & Restore
- Manual backup to a local **ZIP** file containing `notes.json`, `tasks.json`, `calendar.json`, and `metadata.json`
- Automatic backups with configurable frequency (daily / weekly / monthly)
- Up to **30** backup files retained; older ones purged automatically
- Restore any saved backup from the backup list in Settings (tap it, confirm, current data is replaced)

### Settings
| Option | Values |
|---|---|
| Theme | System / Light / Dark |
| Home layout | Grid / List |
| Show completed tasks | Toggle |
| Group tasks by priority | Toggle |
| Backup frequency | Daily / Weekly / Monthly |
| ICS import / export | Calendar interoperability |
| Export notes | Opens the PDF export screen |
| Statistics | Opens the statistics screen |
| App info | Version, build number, changelog, author |

### Home Screen Widget
Android home screen widget support via `home_widget`.

### Changelog
After an update, a "Changelog" dialog lists what changed since the last version the user saw (nothing is shown on a fresh install). The full history is always available from **Info app**.

---

## Architecture

```
Flutter (Dart)
├── State Management   → Riverpod (StateNotifier + Provider)
├── Backend            → Firebase (Auth + Firestore)
├── Local Storage      → SharedPreferences (settings)
├── Notifications      → flutter_local_notifications (timezone-aware)
├── Audio              → record + just_audio + audio_waveforms
├── PDF Export         → pdf + printing
├── Charts             → fl_chart
├── Biometrics         → local_auth
├── Home Widget        → home_widget
└── Backup             → archive (ZIP)
```

Data flow for notes and tasks:

```
UI Widget
  └─ reads/writes via Riverpod provider
       └─ StateNotifier mutates in-memory state + writes to Firestore
            └─ Firestore collection: users/{uid}/notes | tasks | task_lists | calendar_events
```

---

## Project Structure

```
lib/
├── main.dart                     # App entry point, Firebase init, routing
├── models/
│   ├── note_model.dart           # NoteModel, NoteStyle, ChecklistItem, NoteType
│   ├── audio_note.dart           # AudioNote
│   ├── task_model.dart           # TaskModel
│   ├── task_list_model.dart      # TaskListModel
│   ├── subtask_model.dart        # SubtaskModel
│   ├── calendar_model.dart       # CalendarEventModel
│   ├── note_template.dart        # NoteTemplate + kNoteTemplates
│   └── change_history.dart       # Undo/redo history model
├── providers/
│   ├── auth_provider.dart        # Firebase Auth stream, AuthNotifier
│   ├── notes_provider.dart       # NotesNotifier (Firestore CRUD)
│   ├── notes_undo_redo_provider.dart
│   ├── tasks_provider.dart       # TasksNotifier, TaskListsNotifier
│   ├── tasks_undo_redo_provider.dart
│   ├── audio_provider.dart       # Audio recording/playback state
│   ├── calendar_provider.dart    # CalendarNotifier
│   └── settings/
│       ├── theme_provider.dart   # ThemeMode (SharedPreferences)
│       ├── ui_provider.dart      # Layout, sort order, search query
│       ├── backup_provider.dart  # Backup frequency settings
│       └── backup_restore.dart   # Full-backup parsing + restore (JSON and ZIP)
├── screens/
│   ├── home_screen.dart          # Main notes list (grid / list)
│   ├── tasks_screen.dart         # Tasks list with tab bar
│   ├── archive_screen.dart
│   ├── trash_screen.dart
│   ├── labels_screen.dart        # Tag management
│   ├── reminders_screen.dart
│   ├── export_screen.dart        # PDF export
│   ├── info_screen.dart
│   ├── note_template_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   ├── reorderable_grid_view.dart
│   │   ├── reorderable_list_view.dart
│   │   ├── speed_dial_fab.dart
│   │   └── home_layout_utils.dart
│   ├── note_editor/
│   │   ├── note_editor_screen.dart
│   │   ├── note_checklist_editor.dart
│   │   └── note_link_sheet.dart
│   ├── task_editor/
│   │   └── task_editor_screen.dart
│   ├── calendar/
│   │   ├── calendar_screen.dart
│   │   ├── calendar_event_editor_screen.dart
│   │   ├── calendar_day_cell.dart
│   │   ├── calendar_mini_month.dart
│   │   ├── calendar_search_bar.dart
│   │   └── calendar_utils.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   └── settings_section_header.dart
│   └── statistics/
│       ├── statistics_screen.dart
│       └── statistics_widgets.dart
├── theme/
│   ├── app_theme.dart            # Light and Dark MaterialTheme
│   ├── app_colors.dart           # AppColors palette
│   └── app_font_sizes.dart
├── utils/
│   ├── audio_service.dart        # AudioRecordingService singleton
│   ├── backup_service.dart       # BackupService (ZIP create/restore)
│   ├── notification_service.dart # NotificationService singleton
│   ├── widget_service.dart       # Home widget updates
│   ├── note_lock_service.dart    # Biometric lock
│   ├── recurrence.dart           # RecurrenceType enum + helpers
│   ├── ics_export_service.dart   # Calendar → ICS
│   ├── ics_import_service.dart   # ICS → CalendarEventModel
│   ├── downloader.dart           # Platform-aware file download
│   ├── downloader_io.dart        # Mobile implementation
│   └── downloader_web.dart       # Web implementation
└── widgets/
    ├── app_drawer.dart           # Shared navigation drawer
    ├── nav_scaffold.dart         # Scaffold with drawer
    ├── note_card.dart            # Note preview card
    ├── sort_sheet.dart           # Bottom sheet for sort options
    ├── shared/
    │   ├── empty_state.dart
    │   └── search_field.dart
    └── style_editor/             # Note styling controls
```

---

## Data Models

### NoteModel
| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `title` | `String` | Note title |
| `content` | `String` | Note body (Markdown) |
| `type` | `NoteType` | `note` or `checklist` |
| `style` | `NoteStyle` | Visual styling configuration |
| `checklistItems` | `List<ChecklistItem>` | Items for checklist notes |
| `audioNotes` | `List<AudioNote>` | Attached audio recordings |
| `isArchived` | `bool` | |
| `isPinned` | `bool` | |
| `isLocked` | `bool` | Biometric lock |
| `reminder` | `DateTime?` | Scheduled reminder |
| `linkedNoteIds` | `List<String>` | IDs of linked notes |
| `tags` | `List<String>` | User-defined tags |
| `createdAt` | `DateTime` | |
| `updatedAt` | `DateTime` | |
| `deletedAt` | `DateTime?` | Set on soft-delete; null = not trashed |

### NoteStyle
Font family, size, bold, italic, strikethrough, text color, background color — with separate optional overrides for the title only.

### TaskModel
| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `title` | `String` | |
| `description` | `String` | |
| `isCompleted` | `bool` | |
| `dueDate` | `DateTime?` | |
| `isPinned` | `bool` | |
| `isSpecial` | `bool` | Star / high-priority flag |
| `isArchived` | `bool` | |
| `listId` | `String?` | Parent task list ID (null = no list) |
| `recurrence` | `RecurrenceType` | none / daily / weekly / monthly / yearly |
| `reminder` | `DateTime?` | |
| `tags` | `List<String>` | |
| `subtasks` | `List<SubtaskModel>` | |
| `createdAt` / `updatedAt` / `deletedAt` | `DateTime` | |

### CalendarEventModel
Same timestamp fields as `NoteModel` and `TaskModel`, plus `startTime`, `endTime`, `isAllDay`, `isBirthday`, `isNameDay`, `recurrence`, `reminder`, `tags`.

### AudioNote
| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `filename` | `String` | Display name |
| `filepath` | `String` | Absolute path on device |
| `duration` | `Duration` | |
| `createdAt` | `DateTime` | |
| `transcription` | `String?` | Optional transcript text |

---

## Screens

| Screen | Route | Description |
|---|---|---|
| `LoginScreen` | — | Email/password and Google sign-in |
| `HomeScreen` | `/` | Notes grid/list with FAB (speed dial) |
| `NoteEditorScreen` | push | Create or edit a note / checklist |
| `TasksScreen` | `/tasks` | Tabbed tasks view (All / Special / custom lists) |
| `TaskEditorScreen` | push | Create or edit a task |
| `RemindersScreen` | `/reminders` | All upcoming reminders |
| `CalendarWorkspaceView` | `/calendar` | Full calendar with event editor |
| `LabelsScreen` | `/labels` | Manage tags |
| `ArchiveScreen` | `/archive` | Archived notes and tasks |
| `TrashScreen` | `/trash` | Trashed items (7-day auto-purge) |
| `SettingsScreen` | `/settings` | App preferences and backup |
| `ExportScreen` | push from Settings | PDF export |
| `StatisticsScreen` | push from Settings | Usage statistics |
| `InfoScreen` | push from Settings | App version and author info |

### Navigation
The `AppDrawer` (slide-in from the left) is present on all main screens and provides direct access to every top-level route.

---

## State Management

Noteep uses **Riverpod** with `StateNotifier` for mutable collections and `Provider` for derived read-only views.

### Key Providers

| Provider | Type | Purpose |
|---|---|---|
| `notesProvider` | `StateNotifierProvider` | Full notes list (Firestore-backed) |
| `activeNotesProvider` | `Provider` | Notes that are not archived or trashed |
| `archivedNotesProvider` | `Provider` | Archived, not trashed |
| `trashedNotesProvider` | `Provider` | Soft-deleted notes |
| `filteredNotesProvider` | `Provider` | Applies search query and sort order |
| `tasksProvider` | `StateNotifierProvider` | Full tasks list |
| `taskListsProvider` | `StateNotifierProvider` | Task lists |
| `activeTasksProvider` | `Provider` | Active tasks sorted by `taskSortOrderProvider` |
| `specialTasksProvider` | `Provider` | Tasks with `isSpecial == true` |
| `filteredTasksProvider` | `Provider` | Applies search + sort |
| `taskListTasksProvider` | `Provider.family` | Tasks filtered by list ID + search |
| `calendarProvider` | `StateNotifierProvider` | Calendar events |
| `authStateProvider` | `StreamProvider` | Firebase Auth stream |
| `currentUserProvider` | `Provider` | Current `User?` |
| `authNotifierProvider` | `StateNotifierProvider` | Sign-in / sign-out operations |
| `themeModeProvider` | `StateNotifierProvider` | Persisted in SharedPreferences |
| `homeLayoutProvider` | `StateProvider` | Grid or List |
| `sortOrderProvider` | `StateProvider` | Notes sort order |
| `taskSortOrderProvider` | `StateProvider` | Tasks sort order |
| `searchQueryProvider` | `StateProvider` | Notes search string |
| `taskSearchQueryProvider` | `StateProvider` | Tasks search string |
| `backupSettingsProvider` | `StateNotifierProvider` | Backup frequency |

---

## Services & Utilities

### `NotificationService`
Singleton. Initialises `flutter_local_notifications` with timezone support. Provides:
- `scheduleNotification(id, title, body, scheduledAt)` — zones-aware scheduling
- `cancelNotification(id)` / `cancelAllNotifications()`
- Static ID helpers: `idForNote`, `idForTask`, `idForEvent` (offset ranges to avoid collisions)

### `AudioRecordingService`
Singleton. Wraps `record` (recording) and `just_audio` (playback):
- `startRecording()` → records AAC/M4A to `<appDocDir>/audio_notes/`
- `stopRecording()` → returns an `AudioNote`
- `cancelRecording()` → deletes partial file
- `playAudio(filePath)`, `pauseAudio()`, `resumeAudio()`, `stopAudio()`, `seek(duration)`
- Streams: `playerStateStream`, `positionStream`

### `BackupService`
Static class:
- `createBackup(notesData, tasksData, calendarData)` → writes a ZIP to `<appDocDir>/noteep_backups/`
- `restoreBackup(backupPath)` → extracts ZIP and returns parsed JSON maps
- `listBackups()` → sorted list of backup files
- `deleteBackup(path)`, auto-purge (keeps last 30)
- `getLastBackupTime()` / `setLastBackupTime()` via SharedPreferences

### `NoteLockService`
Wraps `local_auth` to prompt biometric or device credential authentication before showing a locked note.

### `WidgetService`
Manages the Android home screen widget state via `home_widget`.

### `RecurrenceType`
Enum: `none | daily | weekly | monthly | yearly`  
Includes `label` (Italian display string), `shortLabel`, and `toShortString()` helpers.

### ICS Export / Import
- `IcsExportService` — serialises `CalendarEventModel` list to RFC 5545 `.ics` format
- `IcsImportService` — parses `.ics` files back into `CalendarEventModel` objects

### Downloader
Platform-adaptive file download:
- `downloader_io.dart` — uses `path_provider` on mobile
- `downloader_web.dart` — triggers browser download on web
- `downloader.dart` — conditional export selecting the correct implementation

---

## Firebase Integration

All user data is stored under `users/{uid}/` in Firestore:

```
users/
  {uid}/
    notes/          ← NoteModel documents
    tasks/          ← TaskModel documents
    task_lists/     ← TaskListModel documents
    calendar_events/ ← CalendarEventModel documents
```

Each `StateNotifier` holds the `uid` and a `FirebaseFirestore` reference, loading its collection on construction. Write operations use `doc(id).set(...)` for upserts and `batch.commit()` for bulk changes (reorder, tag rename/delete, replaceAll, clearAll).

### Security Rules
`firestore.rules` restricts every signed-in user to their own `users/{uid}/` branch; everything else is denied. Deploy with:
```bash
firebase deploy --only firestore:rules
```

### Trash Auto-Purge
On every load, items with `deletedAt` older than 7 days are batch-deleted from Firestore and removed from in-memory state.

---

## Theme & Styling

| Item | Value |
|---|---|
| Font | **Exo 2** (variable weight + italic variant) |
| Theme engine | Material 3 (`useMaterial3: true`) |
| Color palette | `AppColors` — white `#FFFFFF`, dark `#3D3F4D`, warm yellow `#FEDFA9`, warm brown `#CCA775` |
| Themes | `AppTheme.light` / `AppTheme.dark` |
| Selection | System / Light / Dark — persisted via `themeModeProvider` |

---

## Getting Started

### Prerequisites
- Flutter SDK **≥ 3.7.2** / Dart SDK **^3.7.2**
- A Firebase project with **Authentication** and **Firestore** enabled
- `google-services.json` placed in `android/app/`
- `lib/firebase_options.dart` generated with [`flutterfire configure`](https://firebase.google.com/docs/flutter/setup) (both files are git-ignored)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/ndenicolais/Noteep.git
cd Noteep

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
# Web: keep port 5000, it is the authorized OAuth origin / API key referrer
flutter run -d chrome --web-port 5000
```

### Android Release Signing
Release builds are signed with the keystore described in `android/key.properties` (git-ignored):
```properties
storeFile=C:/path/to/noteep-release.jks
storePassword=...
keyAlias=noteep
keyPassword=...
```
Without this file, release builds fall back to the debug key (local testing only). Register the release keystore SHA-1 in the Firebase console, otherwise Google Sign-In fails.

```bash
flutter build apk --release --target-platform android-arm64
```

### Testing

```bash
flutter test
```

- `test/providers/`: unit tests for `NotesNotifier`, `TasksNotifier` and `TaskListsNotifier` against [`fake_cloud_firestore`](https://pub.dev/packages/fake_cloud_firestore) (CRUD, trash lifecycle, tags, cross-notifier `taskLists → tasks` coupling, derived/filtered providers).
- `test/screens/`: widget tests for `NoteEditorScreen` and `TaskEditorScreen` (render, edit + save, overflow-menu actions), with `notesProvider`/`tasksProvider` overridden to a fake-Firestore-backed notifier so no real Firebase project is needed to run them.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `firebase_core` | ^3.13.1 | Firebase initialisation |
| `firebase_auth` | ^5.5.3 | Authentication |
| `cloud_firestore` | ^5.6.6 | Cloud database |
| `google_sign_in` | ^6.2.2 | Google OAuth |
| `shared_preferences` | ^2.3.4 | Local settings storage |
| `flutter_local_notifications` | ^18.0.1 | Local notifications |
| `flutter_timezone` | ^3.0.0 | Timezone detection |
| `timezone` | ^0.9.4 | Timezone data |
| `record` | ^6.0.0 | Audio recording |
| `just_audio` | ^0.9.39 | Audio playback |
| `audio_waveforms` | ^1.1.3 | Waveform visualisation |
| `table_calendar` | ^3.1.3 | Calendar UI |
| `fl_chart` | ^0.68.0 | Statistics charts |
| `pdf` | ^3.11.1 | PDF generation |
| `printing` | ^5.13.1 | PDF preview & print |
| `local_auth` | ^2.3.0 | Biometric authentication |
| `home_widget` | ^0.9.1 | Android home screen widget |
| `archive` | ^3.6.1 | ZIP backup |
| `background_fetch` | ^1.3.0 | Background auto-backup |
| `share_plus` | ^10.1.4 | Share sheet |
| `file_picker` | ^8.1.7 | File picker (ICS, backup) |
| `flutter_markdown` | ^0.7.6 | Markdown rendering |
| `path_provider` | ^2.1.4 | File system paths |
| `intl` | ^0.20.2 | Date formatting / i18n |
| `flutter_localizations` | SDK | Italian Material/Cupertino widgets (pickers, menus) |
| `uuid` | ^4.5.1 | UUID generation |
| `fake_cloud_firestore` *(dev)* | latest | Firestore fake for provider/widget tests |

---

## License

Copyright © 2026 Nicola De Nicolais — All Rights Reserved.

Licensed under the **GNU General Public License v3** with Additional Commercial Restrictions.  
Commercial use — including publishing or monetising on any app store — requires explicit written permission from the copyright holder.

Contact: ndn21dev@gmail.com  
GitHub: https://github.com/ndenicolais
