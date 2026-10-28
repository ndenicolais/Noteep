# Noteep — Full documentation

> Copyright © 2026 Nicola De Nicolais — source-available, non-commercial license (see [LICENSE](LICENSE)).

---

## Table of contents

1. [App overview](#1-app-overview)
2. [Architecture and tech stack](#2-architecture-and-tech-stack)
3. [Project structure](#3-project-structure)
4. [Data models](#4-data-models)
   - [Security rules](#security-rules)
5. [Screens and features](#5-screens-and-features)
6. [State management](#6-state-management)
7. [Services](#7-services)
8. [Theme and style](#8-theme-and-style)
9. [Navigation](#9-navigation)
10. [Localization](#10-localization)
11. [Dependencies](#11-dependencies)
12. [System requirements](#12-system-requirements)
13. [Build and distribution](#13-build-and-distribution)

---

## 1. App overview

Noteep is a digital notebook for Android and the web: notes, tasks and calendar events in one place, synced to the user's account through Firebase.

- Sign in with email/password or Google; first launch shows an onboarding.
- Write text notes (Markdown preview, web links) and checklists, styled per note (font, size, colors), with audio recordings, labels, links to other notes and reminders.
- Organize notes in a reorderable masonry grid or a list, sort and search them, start from a template.
- Manage tasks in custom lists, with subtasks, due dates, recurrence, a "special" flag and reminders.
- Plan events in a calendar (day, multi-day, month, year and schedule views), with recurrence, birthdays and name days, ICS import/export.
- See all reminders in one screen, browse notes by label, archive and restore items, recover deleted ones from the trash for 7 days.
- Export notes (PDF, TXT, JSON, CSV, HTML), back up and restore data (manual JSON and automatic local backups), read statistics.
- Use five Android Home screen widgets (summary and quick actions).

Languages: Italian and English (see [Localization](#10-localization)). Themes: light, dark or system (see [Theme and style](#8-theme-and-style)).

---

## 2. Architecture and tech stack

| Component | Technology |
|---|---|
| Framework | Flutter (Android + Web) |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) (`Notifier`/`NotifierProvider` declared by hand, no code generation) |
| Authentication | [firebase_auth](https://pub.dev/packages/firebase_auth), [google_sign_in](https://pub.dev/packages/google_sign_in) |
| Database | [cloud_firestore](https://pub.dev/packages/cloud_firestore) with offline persistence |
| Local persistence | [shared_preferences](https://pub.dev/packages/shared_preferences) (settings), [path_provider](https://pub.dev/packages/path_provider) (audio files, automatic backups) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), [timezone](https://pub.dev/packages/timezone), [flutter_timezone](https://pub.dev/packages/flutter_timezone) |
| Audio | [record](https://pub.dev/packages/record) (recording), [just_audio](https://pub.dev/packages/just_audio) (playback) |
| Markdown | [flutter_markdown](https://pub.dev/packages/flutter_markdown) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| PDF and sharing | [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing), [share_plus](https://pub.dev/packages/share_plus) |
| Files and backups | [file_picker](https://pub.dev/packages/file_picker), [archive](https://pub.dev/packages/archive) |
| Home screen widgets | [home_widget](https://pub.dev/packages/home_widget) + native Kotlin `AppWidgetProvider`s |
| Links | [url_launcher](https://pub.dev/packages/url_launcher) |
| Ids, dates | [uuid](https://pub.dev/packages/uuid), [intl](https://pub.dev/packages/intl) |

**Pattern.** Models (`lib/models/`) are plain classes with `copyWith` and `toJson`/`fromJson`. One Riverpod notifier per Firestore collection owns the list of that collection for the signed-in user and exposes the CRUD methods. Derived `Provider`s compute filtered and sorted views. Screens read providers and call notifier methods; logic that does not need a `BuildContext` lives in action classes behind providers (`DataActions`, `BackupRestorer`, `RemindersActions`) or in plain services in `lib/utils/` that do not depend on Riverpod. Every write is an optimistic update: the state changes first, then Firestore is written, and a failure rolls the state back (see [State management](#6-state-management)).

---

## 3. Project structure

```
noteep/
├── android/              # Android app: Gradle config, manifest, Kotlin widgets, signing
├── web/                  # Web entry point, favicon, PWA manifest and icons
├── assets/
│   ├── fonts/            # Bundled note fonts (see Theme and style)
│   └── images/           # In-app logo and launcher icon sources
├── design/app-icon/      # Icon sources: SVGs and the monochrome logo (not bundled)
├── images/icons/         # Store, OAuth and web icons (not bundled)
├── lib/                  # Dart code (below)
├── test/                 # Unit and widget tests, mirrors lib/
├── firestore.rules       # Firestore security rules (see Security rules)
├── firebase.json, .firebaserc   # Firebase CLI config, project `noteep`
├── l10n.yaml             # gen-l10n config
├── PRIVACY.md            # Privacy policy (IT + EN)
└── DOCUMENTATION.md, README.md, LICENSE
```

```
lib/
├── main.dart             # Bootstrap, auth gate, MaterialApp
├── firebase_options.dart # Firebase config (git-ignored, generated by flutterfire configure)
├── core/
│   ├── constants/        # app_version.dart, changelog.dart, app_info.dart (developer, URLs, privacy date)
│   └── routing/          # AppRoutes, AppRouter, AppNav; notification and Home widget deep links
├── l10n/                 # ARB files, generated AppLocalizations, l10n.dart helpers
├── models/               # Data classes
├── providers/            # Riverpod providers, one file per domain
│   └── settings/         # Settings, backup and data-management providers
├── screens/              # One file per simple screen, one folder per complex screen
├── theme/                # Colors, font sizes, spacing, radii, ThemeData
├── utils/                # Services without Riverpod (notifications, backup, ICS, audio, widgets…)
└── widgets/              # Widgets shared across screens
    ├── shared/           # Design-system components
    └── style_editor/     # Note style editor
```

**Complex screens** (`auth/`, `calendar/`, `note_editor/`, `settings/`, `statistics/`, `task_editor/`, `tasks/`, `home/`) are folders: a `*_screen.dart` orchestrator owns the state and the `BuildContext` work (dialogs, sheets, snackbars) and delegates rendering to child widgets in the same folder.

**Conventions**

- File names are the snake_case of their main class.
- Shared building blocks live in `widgets/shared/` and must be reused instead of rebuilt per screen (see [Theme and style](#8-theme-and-style)).
- Navigation always goes through `AppNav` helpers, never `Navigator.push(MaterialPageRoute(...))` (see [Navigation](#9-navigation)).
- Free-text fields (note title/content, checklist items, task and event fields, link text, list and label names) use `TextCapitalization.sentences`; search, URL, email and password fields do not. `showAppTextInputDialog` defaults to `none`, so it must be passed explicitly.
- UI never deletes for good: delete actions call `softDelete`, and the notifiers' hard-delete methods are used only by trash purge and data management.

---

## 4. Data models

All models generate an `id` with `uuid` when none is given, have `copyWith` (with `clear*` flags for nullable fields) and serialize dates as ISO 8601 strings. Parsing is **lenient**: missing fields fall back to defaults (`''`, `false`, `[]`, `RecurrenceType.none`), unknown enum values fall back to the first value. The only required fields are `startTime`/`endTime` of an event.

Firestore stores one document per item, with the model `id` as document id, under `users/{uid}/<collection>`.

### NoteModel

A note or a checklist. Collection: `users/{uid}/notes`.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `title`, `content` | `String` | Content is Markdown for text notes |
| `type` | `NoteType` | `note` or `checklist` (stored by name) |
| `style` | `NoteStyle` | Per-note text style (below) |
| `checklistItems` | `List<ChecklistItem>` | `id`, `text`, `isChecked` |
| `audioNotes` | `List<AudioNote>` | Recordings attached to the note (below) |
| `isArchived`, `isPinned` | `bool` | |
| `reminder` | `DateTime?` | Scheduled local notification |
| `linkedNoteIds` | `List<String>` | Ids of linked notes |
| `tags` | `List<String>` | Label **names** (see `LabelModel`) |
| `createdAt`, `updatedAt` | `DateTime` | |
| `deletedAt` | `DateTime?` | Set when moved to the trash; purged after 7 days |

**NoteStyle**: `fontFamily` (default `Exo 2`), `fontSize` (default 16), `backgroundColor?`, `fontColor?`, `isBold`, `isItalic`, `isStrikethrough`, and optional title overrides `titleFontColor`, `titleFontFamily`, `titleFontSize`, `titleIsBold`, `titleIsItalic` (null = same as content). Colors are stored as ARGB ints; null fields are omitted.

**AudioNote**: `id`, `filename`, `filepath` (file in the app documents folder `audio_notes/`, device-local), `duration` (stored in milliseconds), `createdAt`, `transcription?`.

### TaskModel

A to-do item. Collection: `users/{uid}/tasks`.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `title`, `description` | `String` | |
| `isCompleted`, `isPinned`, `isSpecial`, `isArchived` | `bool` | `isSpecial` = shown in the "Special" tab |
| `dueDate` | `DateTime?` | |
| `listId` | `String?` | `TaskListModel.id`; null = no list |
| `recurrence` | `RecurrenceType` | `none`, `daily`, `weekly`, `monthly`, `yearly` |
| `reminder` | `DateTime?` | |
| `tags` | `List<String>` | |
| `subtasks` | `List<SubtaskModel>` | `id`, `title`, `isCompleted`, `createdAt`, `updatedAt` |
| `createdAt`, `updatedAt` | `DateTime` | |
| `deletedAt` | `DateTime?` | Trash timestamp |

### TaskListModel

A user-defined task list, shown as a tab in Tasks. Collection: `users/{uid}/task_lists`. Fields: `id`, `name`, `createdAt`, `updatedAt`. Deleting a list clears `listId` on its tasks.

### LabelModel

A user-created label. Collection: `users/{uid}/labels`. Fields: `id`, `name`, `createdAt`. A label exists even if no note uses it; notes reference labels by name in `tags`.

### CalendarEventModel

A calendar event. Collection: `users/{uid}/calendar_events`.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `title`, `description` | `String` | |
| `startTime`, `endTime` | `DateTime` | Required. `endTime == startTime` means "no end time" (`hasEndTime` getter); new events start without one |
| `isAllDay`, `isBirthday`, `isNameDay`, `isPinned`, `isArchived` | `bool` | |
| `recurrence` | `RecurrenceType` | Shared with tasks |
| `recurrenceEndDate` | `DateTime?` | Inclusive; filled from `UNTIL`/`COUNT` on ICS import |
| `reminder` | `DateTime?` | |
| `tags` | `List<String>` | |
| `createdAt`, `updatedAt` | `DateTime` | |
| `deletedAt` | `DateTime?` | Trash timestamp |

### Non-persisted models

- `NoteChange` / `TaskChange` (`change_history.dart`, `task_change_history.dart`): Command pattern for undo/redo in the editors (note title/text, task title/description).
- `NoteTemplate` (`note_template.dart`): the six built-in templates (meeting, journal, project, shopping, travel, brainstorming), built in the UI language by `noteTemplates(AppLocalizations)`.

### Local data

| Data | Where |
|---|---|
| Settings (theme, language, layout, sort orders, task options, onboarding, backup settings, last seen changelog) | `SharedPreferences` |
| Audio recordings | `<documents>/audio_notes/` |
| Automatic backups | `<documents>/noteep_backups/`, ZIP files, last 30 kept |

Audio files and automatic backups stay on the device: they are not uploaded to Firestore.

### Security rules

The rules are versioned in [`firestore.rules`](firestore.rules) and published with `firebase deploy --only firestore:rules` (Firebase CLI, project `noteep`) or by pasting the file in Console → Firestore → Rules. The app uses no Cloud Storage and no Realtime Database.

| Path | Allowed operations | Who |
|---|---|---|
| `users/{uid}` and every subcollection (`notes`, `tasks`, `task_lists`, `calendar_events`, `labels`) | read, write | The signed-in user whose `uid` matches the path |

Everything else is denied by default. A collection added outside `users/{uid}/` needs a new rule. The app never queries Firestore before sign-in.

Unauthenticated REST check (expected `403 PERMISSION_DENIED`):

```
curl.exe -s -w "\nHTTP %{http_code}\n" "https://firestore.googleapis.com/v1/projects/noteep/databases/(default)/documents/users"
```

---

## 5. Screens and features

### 5.1 Startup and authentication

**Path:** `lib/main.dart`, `lib/screens/auth/`, `lib/screens/onboarding_screen.dart`, `lib/screens/boot_error_screen.dart`

Gets the user from launch to the Home screen.

**Features:**
- Auth gate in `NotesApp`: while Firebase Auth loads, a splash with `AppLogo`; signed in → `HomeScreen`; signed out → `LoginScreen`, or `OnboardingScreen` if the onboarding has not been seen yet.
- `LoginScreen`: tabs for sign-in and sign-up (`LoginForm`, `RegisterForm`), Google button, password reset dialog. Validators (`login_validators.dart`) are pure functions taking `AppLocalizations`. Firebase error codes become localized messages through `authErrorMessage`.
- `OnboardingScreen({replay})`: five pages with Skip/Next/Start. On first launch it replaces the login until `onboarding_seen` is set; with `replay: true` it is the `/onboarding` route opened from Info and only pops.
- `BootErrorApp`: standalone `MaterialApp` shown when a required startup step fails, with **Retry** that reruns the whole bootstrap (the exception is shown in debug only). It follows the device language because preferences may not be loaded.

### 5.2 Home and notes

**Path:** `lib/screens/home_screen.dart`, `lib/screens/home/`, `lib/screens/note_editor/`, `lib/screens/note_template_screen.dart`

The list of active notes and the note editor.

**Features:**
- Grid (masonry: one lazy column per `SliverList`, natural card height, note *i* in column *i % columns*) or list layout, chosen in Settings. Drag and drop reorders notes in the grid; in the list, swipe right archives and swipe left trashes.
- Search and sort sheet (created or modified date, newest or oldest first, or custom order by drag and drop). Pinned notes always come first; each group keeps the chosen order, so with the custom order a note dragged across the boundary only moves to the edge of its own group.
- Cards show up to 8 lines of the content as plain text (`markdownToPlainText`): Markdown is rendered only in the editor preview, because `MarkdownBody` cannot be truncated to a number of lines and would make links inside the card steal the tap that opens the note.
- States: skeleton (`NotesSkeleton`) during the first load, empty state with "Create your first note" (hidden when the list is empty only because of a search), sync-error state with "Retry", pull to refresh (`notesProvider.reload`). Transitions between these states use `FadeSwitcher`.
- FAB: a speed dial (note, checklist, task, audio, from template) or, if disabled in Settings, a plain FAB that creates a note.
- Opens the "What's new" dialog after an update and runs the automatic backup when it is due.
- Note editor: title and content with undo/redo, Markdown preview with clickable links (plain `https://` and `www.` URLs are auto-linked), "Insert link" dialog, checklists, style editor, labels sheet (filter, create, toggle; chips under the content), linked notes, audio recorder and player, reminder banner, pin/archive/delete with Undo. Persistence goes through `NoteEditorController`, which owns the note and keeps it out of the widget.
- A `NoteHero` transition animates card → editor and back (disabled with reduced motion).
- Note cards are a single semantic node; their quick actions are also TalkBack custom actions, and the grid adds "Move before/after" as an alternative to drag and drop.

### 5.3 Tasks

**Path:** `lib/screens/tasks/`, `lib/screens/task_editor/`

**Features:**
- Tabs: All, Special and one per task list. A new task is created in the current tab's list (or as special).
- Active and completed sections (`sortTasksForDisplay`, pure function), optional "group by priority" and "show completed" settings.
- Swipe right completes/reopens (the row stays), swipe left trashes; menu to edit, move to another list or delete; star toggles "special".
- Skeleton on first load, error state with Retry, pull to refresh.
- Task editor: title and description with undo/redo, due date, recurrence, list, subtasks, reminder.

### 5.4 Calendar

**Path:** `lib/screens/calendar/`

**Features:**
- Views: day, multi-day (week / 7 days), month, year, schedule (90-day look-ahead), search results. Month days open a bottom sheet with the day's events.
- Event editor: date, start time, optional end time (an end before the start moves to the next day, an end equal to the start removes it), all day (clears the end), birthday, name day, recurrence, reminder, pin/archive/delete.
- Recurring events are expanded by `calendarEventOccursOn` (monthly on the 31st skips short months, yearly on 29 February only in leap years).

### 5.5 Reminders, labels, archive and trash

**Path:** `lib/screens/reminders_screen.dart`, `labels_screen.dart`, `label_notes_screen.dart`, `archive_screen.dart`, `trash_screen.dart`

**Features:**
- Reminders: reminders of active notes and tasks, in "Upcoming" and "Past" sections. Removing one, or "Clear past" in the section header, goes through `RemindersActions` and offers Undo, which restores and reschedules the reminders.
- Labels: create, rename (merges into an existing label with the same name), delete; note count per label; tapping a label opens its notes (active, then archived).
- Archive: three tabs (notes, tasks, events).
- Trash: three tabs, restore, delete for good, empty trash; each item shows the days left before the automatic purge.

### 5.6 Statistics and export

**Path:** `lib/screens/statistics/`, `lib/screens/export_screen.dart`

**Features:**
- Statistics: summary of notes, tasks and events computed by a screen-local provider, charts with `fl_chart`.
- Export: active notes as PDF, TXT, JSON, CSV or HTML. File text (labels, headers, date format) is in the UI language; JSON keys are fixed. Mobile saves/shares the file, web downloads it.

### 5.7 Settings

**Path:** `lib/screens/settings/`

The screen handles dialogs, file pickers and snackbars; data work is in `DataActions` and `BackupRestorer` (see [State management](#6-state-management)).

**Features:**
- Appearance (System/Light/Dark) and language (System/Italiano/English) as `SegmentedChoice`.
- Notes and tasks preferences (layout, FAB menu, completed tasks, grouping).
- Automatic backup: enable, frequency (daily, weekly, monthly), history with restore and delete.
- Data per section (notes, tasks, calendar) and global: JSON export/import, ICS export/import for the calendar, clear. Imports and clears ask for confirmation; persistence errors show a snackbar.
- Account: delete account (destructive confirmation → password for email accounts → non-dismissible progress dialog → `AuthNotifier.deleteAccount`; on success the app returns to the login).
- Info tile with the app version.

### 5.8 Info and privacy

**Path:** `lib/screens/info_screen.dart`, `lib/screens/privacy_policy_screen.dart`, `lib/widgets/changelog_dialog.dart`

**Features:**
- Info: logo, name, tagline, version (without build number), "What is Noteep", feature grid, links (source code, GitHub profile, email — external; onboarding, full changelog, privacy policy, open-source licenses — internal), credits. Max width 600. External links that fail to open show a snackbar.
- Privacy policy: native localized copy of `PRIVACY.md`, with the last-updated date from `privacyPolicyUpdatedAt` and a link to the online version.
- Changelog dialog: one block per version with sections Added / Improved / Fixed / Security (empty ones hidden).

### 5.9 Home screen widgets (Android)

**Path:** `android/app/src/main/kotlin/com/ndn21/noteep/`, `lib/utils/widget_service.dart`, `lib/core/routing/home_widget_*.dart`

**Features:**
- **Summary** (`NoteepWidget`): note and task counts and the latest note, written by `WidgetService`; tapping opens the app.
- **Quick actions** (`QuickActionsWidget`, 3×1 resizable): New note / New task / New event.
- **New note / New task / New event** (1×1): a single button each.
- Buttons open `MainActivity` with a `noteep://new/{note,task,event}` URI; `HomeWidgetLaunchHandler` opens an empty editor (see [Navigation](#9-navigation)).
- All widgets are `AppWidgetProvider`s with `RemoteViews`. Picker names and descriptions are Android string resources (`res/values`, `res/values-it`).

### 5.10 Shared behavior

- **Drawer** (`AppDrawer`, `NavScaffold`): Notes, Tasks, Reminders, Calendar, Labels, Archive, Trash, Settings and sign out. Statistics and Export open from Settings → Notes data, Info from Settings → Info.
- **Undo**: trash and archive actions show a snackbar with Undo (`notifyWithUndo`), which still works after the editor pops.
- **Errors**: fire-and-forget writes go through `notifyOnError`, which shows an error snackbar if the write fails.
- **Sync status**: `SyncStatusListener` (in `MaterialApp.builder`) shows a banner while writes are queued offline and a snackbar if the server later rejects one.
- **Unknown routes**: `UnknownRouteScreen` ("Page not found" + "Back to home").
- **Accessibility**: text up to 200% without overflow on a 360 dp phone; search fields clamp text scale to 1.5×; animations stop with reduced motion.

---

## 6. State management

Riverpod with `NotifierProvider`, `Provider`, `StreamProvider` and `FutureProvider`, all declared by hand. Simple values set from outside (search queries, loading and error flags) use `valueStateProvider<T>(initial)` from `core_providers.dart`. `ProviderScope` overrides `sharedPreferencesProvider` with the instance loaded at startup.

| Controller | Path | Responsibility |
|---|---|---|
| `NotesNotifier` (`notesProvider`) | `providers/notes_provider.dart` | Notes CRUD, trash, archive, reorder, `renameTag`/`deleteTag`; derived `activeNotesProvider`, `archivedNotesProvider`, `trashedNotesProvider`, `notesByIdProvider`, `noteByIdProvider(id)`, loading and error flags |
| `TasksNotifier` (`tasksProvider`) | `providers/tasks_provider.dart` | Tasks CRUD, trash, `clearListReferences`; derived active/special/archived/trashed/by-list providers |
| `TaskListsNotifier` (`taskListsProvider`) | `providers/tasks_provider.dart` | Task lists; deleting one calls `tasksProvider.notifier.clearListReferences()` |
| `CalendarNotifier` (`calendarProvider`) | `providers/calendar_provider.dart` | Events CRUD and trash; search and filtered views |
| `LabelsNotifier` (`labelsProvider`) | `providers/labels_provider.dart` | Labels on Firestore: `add`/`addAll` (trim, no empty or duplicate names), `rename` (merges), `delete`; migrates labels stored by older versions in `SharedPreferences` (`custom_labels`) once, then deletes the key |
| `SyncStatusNotifier` (`syncStatusProvider`) | `providers/sync_provider.dart` | Counts queued offline writes and late rejections; mixin `FirestoreListMutations` used by the data notifiers |
| `AuthNotifier` (`authNotifierProvider`) | `providers/auth_provider.dart` | Google and email sign-in, sign-up, password reset, sign-out, `deleteAccount`; `authStateProvider`, `currentUidProvider` |
| `RecordingStateNotifier` | `providers/audio_provider.dart` | Audio recording state |
| `noteChangeHistoryProvider(id)`, `taskChangeHistoryProvider(id)` | `providers/*_undo_redo_provider.dart` | Undo/redo stacks (limit 50), used through `NoteUndoRedoManager`/`TaskUndoRedoManager` |
| `ThemeModeNotifier`, `AppLanguageNotifier` | `providers/settings/theme_provider.dart`, `locale_provider.dart` | Theme and language, persisted by enum name through `PersistedEnumNotifier` |
| UI settings and filters | `providers/settings/ui_provider.dart` | Layout, sort orders, FAB menu, task options, onboarding flag, search queries, `filteredNotesProvider`, `filteredNoteIdsProvider`, `filteredTasksProvider`, `allTagsProvider`, `tagNoteCountsProvider`, `notesWithTagProvider(tag)`; base class `PersistedEnumNotifier` |
| `BackupSettingsNotifier`, `BackupStatusNotifier`, `availableBackupsProvider` | `providers/settings/backup_provider.dart` | Automatic backup settings and status, list of local backups |
| `BackupRestorer` (`backupRestorerProvider`) | `providers/settings/backup_restore.dart` | `FullBackupData` parsing (flat JSON and ZIP layouts), `apply` (replaces each section present), `readZip` |
| `DataActions` (`dataActionsProvider`) | `providers/settings/data_actions.dart` | Export payloads, per-section import, ICS export/import, clear, `wipeRemoteData`/`wipeLocalData` for account deletion |
| `RemindersActions` (`remindersActionsProvider`) | `providers/reminders_actions.dart` | Clear and restore reminders with their notifications |

**Non-obvious behavior**

- **User switch**: data notifiers watch `currentUidProvider` and `firestoreProvider` in `build()`, start `_load()` and return `[]`. A fetch still running for the previous user is discarded by comparing the uid after the `await`.
- **Optimistic writes** (`FirestoreListMutations.mutate(apply, persist)`): the state changes first. With Firestore persistence a write future completes only when the server acknowledges it, so `mutate` waits at most `writeGrace` (3 s): an error within the window rolls back and rethrows; after it, the write is tracked as queued and the caller continues (no stuck spinners offline). A late server rejection increments `failures` and triggers `reload()`.
- **Batches**: `commitInChunks` splits into batches of 500 and commits them together, so offline they are all queued at once.
- **Load vs reload**: the first load merges Firestore results with the current state; `reload()` replaces it.
- **Loading and errors**: `notesLoadingProvider`/`tasksLoadingProvider` start `true` and turn `false` in a `finally`; load errors go to `notesLoadErrorProvider`/`tasksLoadErrorProvider`, so screens tell "loading", "empty" and "sync error" apart.
- **Trash purge**: on load, items trashed more than 7 days ago are deleted through `mutate`, without blocking the loading flag.
- **Rebuild granularity**: lists watch only ids (`IdList`, equal by content) and each row watches its item (`noteByIdProvider`, `taskByIdProvider`), so editing one note rebuilds only its card. Notifiers keep untouched item instances unchanged for this to work. Archive, Trash, Statistics and Calendar watch whole lists.
- **Account deletion order**: re-authenticate first (password or Google; cancelling aborts), then `wipeRemoteData` (reads every subcollection from the **server**, so it fails offline instead of deleting halfway), `User.delete()`, `wipeLocalData` (best-effort: cancels notifications, deletes local backups), Google sign-out.
- **Restore**: `FullBackupData` parses every section before any provider is touched; `replaceAll` also deletes Firestore documents not in the backup, otherwise they would come back on the next load.

---

## 7. Services

Plain classes in `lib/utils/`, not tied to Riverpod.

### 7.1 AppBootstrap

**Path:** `lib/utils/app_bootstrap.dart`

- `installErrorHandlers()`: `PlatformDispatcher.onError` logs (debug only) unhandled async errors instead of crashing; in release `ErrorWidget.builder` shows a neutral icon.
- `init()`: **required** steps (failure shows `BootErrorApp`): `Firebase.initializeApp` (skipped if already done, for Retry), Firestore `Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)` (persistence is not the default on the web), `SharedPreferences`, then `Intl.defaultLocale = startupLanguageCode(prefs)` so text built before the first frame is already localized. **Optional** steps (failure only logged): `initializeDateFormatting` for `it`/`en`, `NotificationService.init()`, `WidgetService.init()`.

### 7.2 NotificationService

**Path:** `lib/utils/notification_service.dart`

- `init()`, `scheduleNotification(...)`, `cancelNotification(id)`, `scheduleNoteReminder(note)`, `scheduleTaskReminder(task)`.
- Deterministic ids: `idForNote`, `idForTask`, `idForEvent`. Schedules with `AndroidScheduleMode.exactAllowWhileIdle`.
- Permissions are requested on the first scheduled reminder, not at startup.
- Every notification carries a `NotificationTarget` payload (`note:<id>`, `task:<id>`, `event:<id>`); a tap (app open or cold start) publishes it in `pendingTarget`.
- Channel name and description are passed on every schedule with `currentL10n()`, so Android updates them to the current language. Already scheduled notifications keep the language they were created in.
- Tests: `test/core/notification_target_test.dart`, `notification_launch_handler_test.dart`.

### 7.3 BackupService

**Path:** `lib/utils/backup_service.dart`

- `createBackup(...)`, `restoreBackup(path)`, `listBackups()`, `deleteBackup(path)`, `getBackupInfo(file)`, `isBackupDue(frequency)`, `getLastBackupTime()`.
- ZIP in `<documents>/noteep_backups/` with notes, tasks, task lists and calendar as JSON plus `metadata.json` (`appVersion`); keeps the 30 most recent; `last_backup_time` in `SharedPreferences`.
- `restoreBackup` waits for the asynchronous extraction before reading; corrupt or incomplete ZIPs return `null`.
- The Home screen runs a silent backup at startup when `isBackupDue` says so.
- Tests: `test/utils/backup_service_test.dart`, `test/providers/backup_restore_test.dart`.

### 7.4 ICS import and export

**Path:** `lib/utils/ics_import_service.dart`, `ics_export_service.dart`

- Export: `VCALENDAR`/`VEVENT` with recurrences; a recurrence end becomes `UNTIL=` (a date for all-day events, end of the local day in UTC otherwise).
- Import: hand-written parser with line unfolding, `DTSTART`/`DTEND`/`RRULE`/`TZID`, `UNTIL`/`COUNT` resolution, birthdays from `CATEGORIES`. Daily/weekly `COUNT` is computed in calendar days (a `Duration` would be off by one across a DST change); `TZID` times become plain local `DateTime`s; unescaping is single-pass, so `\\n` stays a backslash followed by `n`.
- Tests: `test/utils/ics_service_test.dart`.

### 7.5 AudioRecordingService

**Path:** `lib/utils/audio_service.dart`

Records with `record` into `<documents>/audio_notes/` and plays with `just_audio` (play, pause, resume, stop, seek). Errors are logged in debug and swallowed.

### 7.6 WidgetService

**Path:** `lib/utils/widget_service.dart`

- `init()`, `scheduleSync(notes, tasks)`: no-op on the web.
- Debounces 500 ms, finds the latest note in one pass and skips the write when nothing changed.
- Writes ready-made localized labels (`currentL10n()`), which the Kotlin widget shows as-is; `main.dart` resyncs when the language changes. Android string resources are used only before the first sync.

### 7.7 Other services

| Class / file | What it does |
|---|---|
| `ChangelogService.pendingEntries(prefs, version)` | Compares `appVersion` with `last_seen_changelog_version`: first install → save and show nothing; same version → nothing; otherwise the newer entries (all if the seen version is unknown). Test: `test/utils/changelog_service_test.dart` |
| `DataExportService` | JSON and ICS file writing and picking for Settings |
| `downloader.dart` (`_io`, `_web`, `_stub`) | Conditional import: save/share a file on mobile, download it on the web |
| `link_utils.dart` | `normalizeUrl` (adds `https://`, `null` if invalid), `buildMarkdownLink` (escapes brackets and URL characters), `openExternalLink` (external app). Allowed schemes: `http`, `https`, `mailto`, `tel`; the matching `<queries>` are in the Android manifest |
| `markdown_text.dart` | `markdownToPlainText(source)`: removes Markdown syntax (headings, emphasis, code, quotes, rules, links, images) and turns list items into `• `, keeping escaped characters and `snake_case` words literal. Used by previews that show note text unrendered: `NoteCard`, the reminder notification body and the link sheet. Test: `test/utils/markdown_text_test.dart` |
| `recurrence.dart` | `RecurrenceType`, `recurrenceTypeFromString`, labels, `calendarEventOccursOn`. Test: `test/utils/recurrence_test.dart` |
| `dialogs/move_to_list_dialog.dart` | Dialog to move a task to another list |

### 7.8 Deep links

**Path:** `lib/core/routing/`

- `NotificationTarget` encodes/parses payloads (missing or malformed → `null`, the app just opens) and resolves the non-trashed item.
- `NotificationLaunchHandler` wraps the signed-in `HomeScreen` (so it is under the `MaterialApp` navigator): it listens to `pendingTarget`, waits for the item to load and opens it with `AppNav`. If the item is still missing when loading ends (notes/tasks) or after 10 s (events), it shows "Reminder item not found". A tap before sign-in waits for the user to sign in.
- `HomeWidgetAction.parse` reads `noteep://new/...` URIs. `HomeWidgetLaunchHandler` (Android only) handles the cold start once per process (`initialLaunchHandled`, otherwise the intent left on the activity would reopen the editor at every sign-in) and taps while the app runs (`singleTop` → `onNewIntent`).

---

## 8. Theme and style

**Fonts.** The UI uses **Exo 2**, bundled in `assets/fonts/`. Notes can also use Montserrat, Open Sans, Dancing Script, Playfair Display and Pacifico (`kNoteFonts` in `font_family_picker.dart`). All fonts are bundled variable fonts, so they work offline.

**App icon.** Source logo `assets/images/app_logo.png` (1024×1024, transparent, rendered from `design/app-icon/foreground.svg`) and `design/app-icon/app_logo_mono.png` (themed icons: the check mark is cut out, otherwise the full silhouette would disappear). The local script `tool/icons/generate_icons.ps1` (`/tool/` is git-ignored) uses background `#3D3F4D` and writes:

- in `assets/images/`: `app_icon_legacy.png` (logo at 64% on a rounded square), `app_icon_foreground.png` and `app_icon_monochrome.png` (62%, transparent);
- in `images/icons/` (not bundled): `icon_512.png` (store), `icon_192.png`, `oauth_logo_120.png` (Google Auth Platform → Branding), `favicon_32.png`.

Then `dart run flutter_launcher_icons` (config in `pubspec.yaml`) generates `@mipmap/launcher_icon` (legacy, adaptive with 16% inset, monochrome), also used by notifications and the summary widget. Web icons and `favicon.png` come from `design/app-icon/icon.svg` (symbol inside the central 80%, so it also works as maskable); `web/manifest.json` uses `#3D3F4D` for `theme_color`/`background_color`. In the app, `AppLogo({size})` shows the logo on an `AppColors.dark` rounded square, like the launcher icon.

**Themes.** Light, dark or system, chosen in Settings and persisted as `theme_mode_v2` by `ThemeModeNotifier`. Both are Material 3 (`AppTheme.light`/`dark` in `app_theme.dart`), from `ColorScheme.fromSeed(seedColor: warmBrown)` with the main roles overridden.

| Name | Value | Usage |
|---|---|---|
| `AppColors.white` | `#FFFFFF` | Light surface, dark `onSurface` |
| `AppColors.dark` | `#3D3F4D` | Dark surface, light `onSurface`, `onPrimary` in both themes, icon background |
| `AppColors.warmBrown` | `#CCA775` | Seed; light `primary`, dark `primaryContainer`/`secondary` |
| `AppColors.warmYellow` | `#FEDFA9` | Light `primaryContainer`/`secondary`, dark `primary` |
| light `secondaryContainer` | `#FFF3DC` | Tag chips |
| light `surfaceContainerHighest` | `#F5EDD8` | Skeletons, filled fields |
| dark `secondaryContainer` | `#5A4A32` | Tag chips |
| dark `surfaceContainerHighest` | `#4A4C5A` | Skeletons, filled fields |
| `noteSwatchesLight` / `noteSwatchesDark` | 8 colors each | Note background presets |

Screens use `ColorScheme` roles (`primary`, `surface`, `secondaryContainer`, `surfaceContainerHighest`, `error`/`onError` for destructive actions), not `AppColors` directly. On arbitrary note backgrounds the text color comes from `AppColors.contrastingTextColor`, which picks black or white by WCAG contrast ratio (≥ 4.5 on every swatch, tested in `test/theme/app_colors_test.dart`).

**Scales.**

| Scale | Values |
|---|---|
| `AppFontSizes` | xs 10, sm 12, md 14, lg 16, xl 18, xxl 22, headline 24, display 28 |
| `AppSpacing` | xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32 |
| `AppRadius` | sm 8 (tiles in sheets), md 12 (cards), lg 16 (small sheets), xl 20 (dialogs, full-height sheets) |

`_textTheme` maps headline/title/body/label roles to `AppFontSizes` in Exo 2 (titles `w600`; display and `headlineLarge` keep the M3 defaults). Screens use `Theme.of(context).textTheme.*`, and `AppFontSizes` only when an explicit size is needed. `dialogTheme` and `bottomSheetTheme` set radius `xl`, so dialogs and sheets do not redeclare the shape. Off-scale spacing values (6, 10, 14, 20, 28) still appear as literals.

**Layout.** Home grid columns depend on the width (`gridColumns` in `home_layout_utils.dart`); Info is centered with a max width of 600.

**Shared components** (`lib/widgets/shared/`):

| Component | Non-obvious behavior |
|---|---|
| `SectionHeader` | `labelLarge` w600 in `primary` (`muted`: `outline`), announced as a header; optional `trailing`; `listPadding` vs `inlinePadding` |
| `SegmentedChoice<T>` | Full-width single-choice `SegmentedButton` without check mark |
| `ActionTile` | Row with primary icon and chevron; `destructive` uses `error` |
| `ItemCard` / `ItemCardList` | Card + `ListTile` rows for archive, trash and reminders |
| `TagChip` | Non-interactive chip in `secondaryContainer`; `dense` on note cards |
| `app_dialogs.dart` | `showAppTextInputDialog` (trimmed text or `null`; untrimmed with `obscureText`), `showAppConfirmDialog` (`true` only on confirm; `destructive` → `FilledButton` in `error`), `showAppMessageDialog`, `showAppSheet` (wraps content in `SafeArea(top: false)`: with Android 15 edge-to-edge, sheets would otherwise go under the navigation bar) |
| `EmptyState` | Icon + message + optional action button |
| `PullToRefresh` | Works with non-scrollable children; scrollable children need `AlwaysScrollableScrollPhysics` |
| `SwipeActions` | `Dismissible` wrapper; `removesItem: false` puts the row back (for actions after which the item stays) |
| `SkeletonPulse` / `SkeletonBox` / `ListSkeleton` | One shared pulse, one semantic "Loading…" node, static with reduced motion |
| `FadeSwitcher` | 250 ms cross-fade on key change; the outgoing child keeps its state (e.g. scroll) and its `Hero`s are disabled |
| `NoteHero` | Lightweight container transform card ↔ editor; the editor content is laid out at its final size inside an `OverflowBox` and clipped |
| `SearchField` | Bound to a `ValueStateProvider<String>`; text scale clamped to 1.5× inside the 40 px AppBar field |
| `error_feedback.dart` | `notifyOnError`, `notifyWithUndo` (captures the `ScaffoldMessenger` first, so it works after the editor pops; replaces the Undo snackbar with an error one if the write fails) |

---

## 9. Navigation

Named routes with `MaterialApp.onGenerateRoute: AppRouter.onGenerateRoute` (`lib/core/routing/app_router.dart`). Screens call the typed helpers in `AppNav` (`openNote`, `openTask`, `openEvent`, `openLabel`, `openTasks`, `openStatistics`, `openExport`, `openInfo`, `openOnboarding`, `openPrivacyPolicy`). Detail routes with a missing or wrongly typed argument, and unknown names, go to `AppRouter.onUnknownRoute` → `UnknownRouteScreen` instead of crashing.

Drawer sections (`AppRouter.sectionRoutes`) use `FadeThroughPageRoute` (fade + scale 0.92 → 1, 300 ms, instant with reduced motion) because they are siblings, not a drill-down; detail screens use `MaterialPageRoute`. The drawer returns to Home with `popUntil` on the root.

| Route | Screen | Description |
|---|---|---|
| *(home)* | `HomeScreen` / `LoginScreen` / `OnboardingScreen` | Chosen by the auth gate (see [5.1](#51-startup-and-authentication)) |
| `/note` | `NoteEditorScreen` | Argument `NoteRouteArgs(note, autoOpenRecorder)` |
| `/tasks` | `TasksScreen` | Drawer section |
| `/task` | `TaskEditorScreen` | Argument `TaskModel` |
| `/calendar` | `CalendarWorkspaceView` | Drawer section |
| `/event` | `CalendarEventEditorScreen` | Argument `CalendarEventModel` |
| `/reminders` | `RemindersScreen` | Drawer section |
| `/labels` | `LabelsScreen` | Drawer section |
| `/label` | `LabelNotesScreen` | Argument `String` (label name) |
| `/archive` | `ArchiveScreen` | Drawer section |
| `/trash` | `TrashScreen` | Drawer section |
| `/statistics` | `StatisticsScreen` | |
| `/export` | `ExportScreen` | |
| `/settings` | `SettingsScreen` | Drawer section |
| `/info` | `InfoScreen` | |
| `/onboarding` | `OnboardingScreen(replay: true)` | Replay from Info |
| `/privacy-policy` | `PrivacyPolicyScreen` | From Info |

Notification taps and Home widget buttons open editors through the handlers in [Deep links](#78-deep-links). In the Android manifest `flutter_deeplinking_enabled` is `false`: otherwise Flutter would also push the widget URI as a route and show `UnknownRouteScreen`.

---

## 10. Localization

| Code | Language |
|---|---|
| `it` | Italian (template) |
| `en` | English (fallback) |

- ARB files in `lib/l10n/` (`app_it.arb` is the template, `app_en.arb` has the same keys). `flutter gen-l10n` (`generate: true` in `pubspec.yaml`, `l10n.yaml` with `nullable-getter: false`) generates `app_localizations*.dart`, excluded from analysis.
- In widgets: `context.l10n.<key>`; without a `BuildContext` (notification channel, Home widget, ICS placeholders): `currentL10n()`, which follows `Intl.defaultLocale`. Pure functions take `AppLocalizations` as a parameter.
- Language choice: `AppLanguageNotifier` (`system`, `it`, `en`; key `app_language`, default `system`). `MaterialApp.locale` is `null` for `system`; `supportedLocales` is `[en, it]`, so an unsupported device language falls back to English. `MaterialApp.builder` keeps `Intl.defaultLocale` aligned with the resolved language, so `DateFormat` without an explicit locale follows it.
- Key prefixes: `common*` for shared strings, `nav*` for navigation sections, `changelog_v<X>_<Y>_<Z>_bullet_<N>` for changelog bullets (snake_case on purpose), `policy_section_*` for the privacy policy.
- Exported files (PDF, TXT, CSV, HTML) use the UI language; JSON keys are fixed.

---

## 11. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:          # Material/Cupertino localizations for it/en
    sdk: flutter

  flutter_riverpod: ^2.6.1        # State management
  uuid: ^4.5.1                    # Model ids
  shared_preferences: ^2.3.4      # Settings
  intl: ^0.20.2                   # Dates, plurals, gen-l10n
  pdf: ^3.11.1                    # PDF export
  printing: ^5.13.1               # PDF share/print
  path_provider: ^2.1.4           # Documents folder (audio, backups, exports)

  firebase_core: ^3.13.1          # Firebase init
  firebase_auth: ^5.5.3           # Authentication
  google_sign_in: ^6.2.2          # Google sign-in
  cloud_firestore: ^5.6.6         # Database

  archive: ^3.6.1                 # Backup ZIP files

  flutter_local_notifications: ^18.0.1   # Reminders
  flutter_timezone: ^5.1.1        # Device time zone
  timezone: ^0.9.4                # Zoned scheduling, ICS TZID

  share_plus: ^13.3.1             # Share exported files
  file_picker: ^13.2.0            # Import JSON/ICS
  flutter_markdown: ^0.7.6        # Markdown preview
  fl_chart: ^0.68.0               # Statistics charts
  home_widget: ^0.9.1             # Android Home screen widgets

  record: ^6.0.0                  # Audio recording
  just_audio: ^0.9.39             # Audio playback

  url_launcher: ^6.3.3            # External links

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0           # Lint rules
  fake_cloud_firestore: ^3.1.0    # In-memory Firestore for tests
  flutter_launcher_icons: ^0.14.2 # Launcher icon generation
```

**Integration notes**

- `flutter_local_notifications` 18 needs `coreLibraryDesugaring` and the Gson keep rules in `proguard-rules.pro` (see [Build and distribution](#13-build-and-distribution)).
- Firebase and Google Sign-In native libraries come from the plugins; they are not pinned in `android/app/build.gradle`, or they would compete with the plugins' own.
- `file_picker` 13 (`FilePicker.pickFile()` + `readAsBytes()`), `share_plus` 13 (`SharePlus.instance.share(ShareParams(...))`) and `flutter_timezone` 5 are the minimum versions that build with AGP 9.

### Tests

Run with `flutter test`. No real Firebase project is needed.

- **Pure logic**: recurrence, Markdown to plain text, ICS import/export round trip, changelog service and entries (`it`/`en` changelog keys match, each bullet used once), notification payloads, Home widget URIs, colors contrast, text theme, task sorting, login validators.
- **With fakes**: data notifiers, labels, undo/redo, backup restore, `DataActions` (including account wipe isolation between users), offline sync (`FirestoreListMutations` with a short `writeGrace`) against `fake_cloud_firestore`; `BackupService` on a real temp folder with a mocked `path_provider` channel.
- **Widget and layout**: editors, Info, boot error, router, notification and Home widget launch handlers, masonry grid, rebuild granularity, `NoteHero`, skeletons, `FadeSwitcher`, design-system components, dialogs, swipe actions, empty state; accessibility (200% text on 360×690 without overflow, card semantics and custom actions, sheets above the navigation bar).

Helpers in `test/helpers/`: `createTestContainer(db)` / `firestoreOverrides(db)` override `firestoreProvider` and `currentUidProvider`; `l10n.dart` provides `testLocale` (`it`), `testSupportedLocales`, `testLocalizationsDelegates` and `itL10n`. Widget tests mount `UncontrolledProviderScope(container: ...)` to share notifiers with the test. Settings providers take `SharedPreferences.setMockInitialValues`. Derived provider notifications are asynchronous: call `await container.pump()` before asserting. Use `container.listen` to keep `autoDispose` providers alive.

### Lint

`flutter_lints` (`package:flutter_lints/flutter.yaml`) with no extra rules. The generated `lib/l10n/app_localizations*.dart` files are excluded (changelog keys are snake_case). CI-style check: `flutter analyze --fatal-infos --fatal-warnings`.

---

## 12. System requirements

| Requirement | Value |
|---|---|
| Flutter / Dart SDK | Flutter stable, Dart `^3.7.2` |
| Android minimum | API 24 (Android 7.0), Flutter's default `minSdk` |
| Android target | `targetSdk` 36 (Flutter's default), `compileSdk` 37 |
| Architectures | Release APK built for `arm64-v8a` only |
| Web | Modern browsers; no Home screen widgets and no automatic backups (they need `dart:io`) |
| Internet | Needed for sign-in and sync; Firestore works offline and syncs later |
| Google Play services | Needed for Google sign-in |
| Firebase | `android/app/google-services.json` and `lib/firebase_options.dart` (both git-ignored) |

**Android permissions**

| Permission | API levels | Why |
|---|---|---|
| `POST_NOTIFICATIONS` | 33+ | Reminders; requested on the first reminder |
| `SCHEDULE_EXACT_ALARM` | 31–32 (`maxSdkVersion="32"`) | Exact reminders; from 33 `USE_EXACT_ALARM` covers it without asking the user |
| `USE_EXACT_ALARM` | 33+ | Exact reminders (calendar/reminder app) |
| `RECEIVE_BOOT_COMPLETED` | all | Reschedule reminders after a reboot |
| `WAKE_LOCK` | all | Deliver scheduled notifications |
| `RECORD_AUDIO` | all | Audio notes (declared by `record`, requested when recording starts) |
| `INTERNET`, `ACCESS_NETWORK_STATE` | all | Firebase (declared by the plugins) |
| `VIBRATE` | all | Notifications (declared by `flutter_local_notifications`) |
| `FOREGROUND_SERVICE` | all | Background work for the Home widget (declared by WorkManager through `home_widget`) |

**Auto Backup.** `AndroidManifest.xml` points to `res/xml/backup_rules.xml` (Android 6–11) and `res/xml/data_extraction_rules.xml` (12+), which exclude Firebase Auth's `shared_prefs/com.google.firebase.auth.api.Store.<key>.xml` and `…api.crypto.<key>.xml`. Their encryption key lives in the Android Keystore and is never backed up: restored copies could not be decrypted or overwritten, and every sign-in would be lost at process restart. `<key>` is `base64("[DEFAULT]") + base64(mobilesdk_app_id)`: if the app id in `google-services.json` changes, update the file names.

---

## 13. Build and distribution

**Commands**

```bash
flutter pub get
flutter gen-l10n
flutter run                                   # debug
flutter analyze --fatal-infos --fatal-warnings
dart format --output=none --set-exit-if-changed lib test
flutter test
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=symbols/v<version>
flutter build web                             # web
```

The local script `deploy_android.ps1` (git-ignored) runs clean, `pub get` and the release build above, and stops if `android/key.properties` is missing. Release APKs are published on GitHub as `Noteep_v<version>.apk`.

**Android toolchain**

| Tool | Version | Notes |
|---|---|---|
| Android Gradle Plugin | 9.1.1 | `android/settings.gradle` |
| Gradle | 9.3.1 | `gradle-wrapper.properties` |
| Kotlin | 2.3.20 | `kotlin { compilerOptions { jvmTarget = JVM_17 } }` |
| Java target | 17 | With `coreLibraryDesugaring` (`desugar_jdk_libs` 1.2.2) |
| NDK | 28.2.13676358 | |
| `compileSdk` / `targetSdk` | 37 / 36 | |

- `gradle.properties` keeps `android.builtInKotlin=false` and `android.newDsl=false` as set by the Flutter migrator, because several plugins (`flutter_timezone`, `home_widget`, `record_android`, `share_plus`, `shared_preferences_android`) still apply the Kotlin Gradle Plugin.
- `android/build.gradle` forces only the `home_widget` module to JVM target 11 (Kotlin via `compilerOptions`, Java via `afterEvaluate`): its Kotlin code does not compile with the default 1.8.
- Do not force WorkManager/Glance versions: with `work-runtime` 2.9.1, R8 in AGP 9 strips `WorkDatabase_Impl` and the release crashes at startup. The versions requested by `home_widget` are used.
- `proguard-rules.pro` keeps Gson generic signatures and `com.dexterous.flutterlocalnotifications.models.**`: without them, `zonedSchedule` fails only in release ("Missing type parameter") and reminders are never scheduled.

**Firebase configuration**

- `android/app/google-services.json` and `lib/firebase_options.dart` are generated locally with `flutterfire configure` and git-ignored. `DefaultFirebaseOptions.currentPlatform` throws `UnsupportedError` outside Android and Web.
- Rules: see [Security rules](#security-rules).

**APK signing**

`android/key.properties` (git-ignored, like `*.jks` and `*.keystore`):

```properties
storeFile=<path to the release keystore>
storePassword=<store password>
keyAlias=<key alias>
keyPassword=<key password>
```

- `android/app/build.gradle` signs `release` with `signingConfigs.release` when the file exists; without it (a fresh clone) it falls back to the debug key so `flutter run --release` still works. Published APKs must always use the release key.
- Keep the keystore and its passwords backed up outside the repo: a lost key means users must uninstall to update.
- Register the release key's SHA-1/SHA-256 in Firebase (Android app), in the Android API key restriction on Google Cloud, and in Play Console (`PLAY_CONSOLE_REGISTRATION.md`).

**Notes**

- Never commit: `key.properties`, keystores, `google-services.json`, `firebase_options.dart`, `symbols/`, `/tool/`, `deploy_android.ps1`, `CLAUDE.md`, `TASKS.md`.
- Version source of truth: `version: X.Y.Z+N` in `pubspec.yaml` (`N` is the Android `versionCode` and always grows), mirrored by `appVersion`/`appBuildNumber` in `lib/core/constants/app_version.dart`. Each release adds a `ChangelogEntry` at the top of `changelogEntries`, with every bullet key in both ARB files (`changelog_test.dart` fails otherwise).
- Obfuscation symbols go to `symbols/v<version>` (outside `build/`, so `flutter clean` keeps them) and are needed to read crash stack traces with `flutter symbolize`: keep them for every release.
- Privacy policy: the same text lives in `PRIVACY.md`, in the ARB files (`PrivacyPolicyScreen`) and on the portfolio page. Update them together, with `privacyPolicyUpdatedAt` in `app_info.dart` equal to the date in `PRIVACY.md`, and before the release when adding services, analytics or permissions.
- Local tools: `tool/icons/generate_icons.ps1` (see [Theme and style](#8-theme-and-style)).
- README previews: `flutter test tool/preview/generate_preview_test.dart` regenerates `images/noteep_preview.png` (tilted phones) and the screens without system bars (540 px wide) in `images/screenshots/<name>.png` from `images/screenshots/<name>_raw.png` (git-ignored and kept locally). The script lives outside `test/`, so it does not run with `flutter test`. Banner order: `editor`, `calendar`, `home`, `tasks`, `stats`; raw screenshots are 1080×2392 with gesture navigation, cropped by 108 px at the top and 70 px at the bottom. Screens are taken in English, light theme, with demo data.

---

## License

Copyright © 2026 Nicola De Nicolais. Source-available, non-commercial license: see [LICENSE](LICENSE). Commercial use, including publishing on an app store, requires written permission.

Bundled fonts (Exo 2, Montserrat, Open Sans, Dancing Script, Playfair Display, Pacifico) are Google Fonts under the SIL Open Font License 1.1. Third-party package licenses are shown in the app (Info → Open-source licenses).

Author: Nicola De Nicolais — ndn21dev@gmail.com — [github.com/ndenicolais](https://github.com/ndenicolais)
