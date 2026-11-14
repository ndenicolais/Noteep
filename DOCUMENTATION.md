# Noteep — Full documentation

> Copyright © 2026 Nicola De Nicolais — source-available, non-commercial license (see [LICENSE](LICENSE)).

---

## Table of contents

1. [App overview](#1-app-overview)
2. [Architecture and tech stack](#2-architecture-and-tech-stack)
3. [Project structure](#3-project-structure)
4. [Data models](#4-data-models)
   - [Data inventory](#data-inventory)
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

Noteep is a digital notebook for Android (the web build is used only for development and is not published): notes, tasks and calendar events in one place, synced to the user's account through Firebase.

- Sign in with email/password or Google; first launch shows an onboarding.
- Write text notes (Markdown preview, web links) and checklists, styled per note (font, size, colors), with audio recordings, labels, links to other notes and reminders.
- Organize notes in a reorderable masonry grid or a list, sort and search them, start from a template.
- Manage tasks in custom lists, with subtasks, a date with an optional time (the time notifies), recurrence and a "special" flag.
- Plan events in a calendar (day, multi-day, month, year and schedule views), with recurrence, birthdays and name days, ICS import/export.
- Browse notes by label, archive and restore items, recover deleted ones from the trash for 7 days.
- Export notes (PDF, TXT, JSON, CSV, HTML), back up and restore data (manual JSON and automatic local backups), read statistics.
- Use seven Android Home screen widgets (notes, tasks and calendar lists, quick actions).

Languages: Italian and English (see [Localization](#10-localization)). Themes: light, dark or system (see [Theme and style](#8-theme-and-style)).

---

## 2. Architecture and tech stack

| Component | Technology |
|---|---|
| Framework | Flutter (Android; Web for development only) |
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
| `isCompleted`, `isPinned`, `isSpecial`, `isArchived` | `bool` | `isPinned` = on top of its section; `isSpecial` = starred, shown in the "Starred" tab |
| `dueDate` | `DateTime?` | Date, optionally with a time (`hasDueTime`: not midnight). A due time is when the task notifies (see §5.4 alerts). Tasks have no separate reminder: `fromJson` turns a legacy `reminder` into the due date when there is none, or when the due date is date-only on the reminder's day; otherwise it is ignored (and dropped at the next save, which overwrites the document) |
| `listId` | `String?` | `TaskListModel.id`; null = no list |
| `recurrence` | `RecurrenceType` | `none`, `daily`, `weekly`, `monthly`, `yearly`. A task is a single document: `isRecurring` needs a `dueDate`, and `nextOccurrence()` steps the due date forward with `nextRecurrence` (`utils/recurrence.dart`; month-end days clamp to the month's last day) and reopens the task |
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
| `location` | `String` | Free-text place; written only when not empty. ICS `LOCATION` on import/export; the event view opens it as a Google Maps search, list cards show it in the subtitle |
| `color` | `Color?` | Card fill picked in the editor (stored as ARGB int, written only when set); null = color of the event kind. See `_customSwatch` in `calendar_event_style.dart` |
| `startTime`, `endTime` | `DateTime` | Required. `endTime == startTime` means "no end time" (`hasEndTime` getter); new events start without one |
| `isAllDay`, `isBirthday`, `isNameDay`, `isArchived` | `bool` | |
| `isPinned` | `bool` | Not used by the UI; kept so existing documents and backups round-trip |
| `recurrence` | `RecurrenceType` | Shared with tasks |
| `recurrenceEndDate` | `DateTime?` | Inclusive; filled from `UNTIL`/`COUNT` on ICS import |
| `alertSameDay` | `bool` | All-day events only: alert on the day of each occurrence, at the default alert time from Settings (09:00 unless changed). Timed events ignore it and always alert at their start (`notifiesSameDay`). Default `false` |
| `alertDayBefore` | `bool` | All-day events only: alert the day before each occurrence, same time (`notifiesDayBefore`). Default `false`. Events have no separate reminder: a legacy `reminder` field is ignored |
| `tags` | `List<String>` | |
| `createdAt`, `updatedAt` | `DateTime` | |
| `deletedAt` | `DateTime?` | Trash timestamp |

### Non-persisted models

- `NoteChange` / `TaskChange` (`change_history.dart`, `task_change_history.dart`): Command pattern for undo/redo in the editors (note title/text, task title/description).
- `NoteTemplate` (`note_template.dart`): the six built-in templates (meeting, journal, project, shopping, travel, brainstorming), built in the UI language by `noteTemplates(AppLocalizations)`.

### Local data

| Data | Where |
|---|---|
| Settings (theme, language, start section, default alert time, layout, sort orders, task options, onboarding, backup settings, last seen changelog) | `SharedPreferences` |
| Audio recordings | `<documents>/audio_notes/` |
| Automatic backups | `<documents>/noteep_backups/`, ZIP files, last 30 kept |

Audio files and automatic backups stay on the device: they are not uploaded to Firestore.

### Data inventory

Record of processing (GDPR art. 30) and the source for the data section of `PRIVACY.md`. Every new field, collection, preference or network destination goes here, in the [security rules](#security-rules), in account deletion (`DataActions.wipeRemoteData` / `wipeLocalData`) and in the policy in the same task.

| Data | Where | Purpose | Retention |
|---|---|---|---|
| Email, account creation and last sign-in dates; Google name, email, photo URL and account id (Google sign-in) | Firebase Auth (the app writes no profile document) | Account; name and photo shown in the drawer | Until the account is deleted (Settings → Account → Delete account) |
| Password | Firebase Auth only | Email sign-in | Never read or stored by the app |
| Notes, tasks, task lists, calendar events, labels (all fields in [Data models](#4-data-models)) | Firestore `users/{uid}/<collection>`, plus the Firestore offline cache on the device | Core features and sync between devices | Until deleted by the user (trash emptied after 7 days) or with the account |
| Audio recordings (name, duration and file path synced with the note) | `<documents>/audio_notes/` on the device | Audio notes | Until deleted or the app is uninstalled; never uploaded |
| Settings, onboarding and changelog seen, backup settings | `SharedPreferences` (browser storage on the web) | App behavior | Until uninstall |
| Automatic backups | `<documents>/noteep_backups/` | Local restore | Last 30 kept; removed on account deletion |
| Scheduled reminders, Home widget data | `flutter_local_notifications`, `home_widget` storage on the device | Reminders and widgets | Until the item changes; reminders are cancelled on sign-out and account deletion and rebuilt from the account at sign-in; the list widgets fall back to their empty state on sign-out, because the data providers reset with the user |
| Exported files (PDF, TXT, JSON, CSV, HTML, ICS, backups) | Wherever the user saves or shares them | Export on request | Under the user's control |
| Device IP address | Google servers hosting the profile photo (`photoURL`) | Showing the Google avatar | Not stored by the app |
| Text typed in the event location field, device IP address | OpenStreetMap Nominatim (`PlaceSearchService`, only while typing ≥ 3 characters, 500 ms debounce, max 1 request/s) | Address suggestions | Not stored by the app; Nominatim usage policy applies |

Not collected: analytics, crash reports, advertising identifiers, device location (GPS), contacts. Firestore lives in the multi-region **`nam5` (United States)**, chosen at project creation and not changeable; Firebase Auth may also process data outside the EU. Both rely on Google's Firebase terms, as stated in `PRIVACY.md` §4.

**Incident log** (GDPR art. 33(5)): record here every personal data breach (open rules, leaked key with data access, exposed data), with date, cause, fix and whether the Garante and users were notified. None so far.

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
- `LoginScreen`: tabs for sign-in and sign-up (`LoginForm`, `RegisterForm`), Google button, password reset dialog. Under the buttons `LoginPrivacyNotice` states the minimum age (14) and links to the privacy policy, so it can be read before an account is created (GDPR art. 13); no checkbox, since the legal basis is the contract. Validators (`login_validators.dart`) are pure functions taking `AppLocalizations`. Firebase error codes become localized messages through `authErrorMessage`.
- `OnboardingScreen({replay})`: five pages with Skip/Next/Start. On first launch it replaces the login until `onboarding_seen` is set; with `replay: true` it is the `/onboarding` route opened from Info and only pops.
- `BootErrorApp`: standalone `MaterialApp` shown when a required startup step fails, with **Retry** that reruns the whole bootstrap (the exception is shown in debug only). It follows the device language because preferences may not be loaded.

### 5.2 Home and notes

**Path:** `lib/screens/home_screen.dart`, `lib/screens/home/`, `lib/screens/note_editor/`, `lib/screens/note_template_screen.dart`

The list of active notes and the note editor.

**Features:**
- Grid (masonry: one lazy column per `SliverList`, natural card height, note *i* in column *i % columns*) or list layout, chosen in Settings. Drag and drop reorders notes in the grid (`LongPressDraggable`, so a swipe over a card scrolls; the card's own long-press menu is turned off with `quickActionsOnLongPress: false` and opens instead when the drag is released in place, via `NoteCard.showQuickActions`); in the list, swipe right archives and swipe left trashes.
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
- Tabs: All, Starred and one per task list. A new task is created in the current tab's list (or starred). The "+" opens `showNewTaskSheet` (`new_task_sheet.dart`, Google Tasks-like quick add): title, optional details, due date then optional time (first offered at the default alert time from Settings) and star. A due time notifies (scheduled on save) and gives the task a timed slot in Calendar; a date alone shows it as all-day, without a notification.
- Active and completed sections (`sortTasksForDisplay`, pure function), each with pinned tasks on top (pin icon before the title) and then the chosen sort order; optional "group by priority" and "show completed" settings. Pin (editor) sets the position, the star sets the "Starred" tab.
- Active tasks are split by due day (`groupTasksByDay`, pure function in `task_sorting.dart`): one `SectionHeader` per day in date order (Today / Tomorrow / Yesterday, otherwise `EEEE d MMMM`, plus the year when not the current one), then "No date" (muted). Within a day: pinned first, then timed tasks by time, then day-only ones in the chosen sort order. `TaskListView` selects only the ids per group (`_DayGroups`, value equality), so editing a task without moving it rebuilds that row alone.
- Each row (`TaskItem`): title, up to 3 lines of description and, when `hasDueTime`, an alarm icon with the notification time (`HH:mm`; the day is the group header).
- Swipe right completes/reopens (the row stays), swipe left trashes; menu to edit, move to another list or delete; star toggles "special".
- Tap opens the read-only `TaskDetailsScreen` (`task_details_screen.dart`, route `AppRoutes.taskDetails`, `AppNav.viewTask`), like Google Calendar/Tasks: title, completion, due date (alarm icon when it has a time), recurrence, list, description, subtasks (checkable) and a Complete/Reopen button; the pencil opens the editor (`AppNav.openTask`), the bin uses the task delete flow. It watches `tasksProvider` by id, so it shows edits on return and closes itself once the task is trashed. New tasks and the menu's "Edit" go straight to the editor.
- Skeleton on first load, error state with Retry, pull to refresh.
- Task editor: title and description with undo/redo, date and optional time, recurrence, list, subtasks.
- Deleting (menu, swipe left, editor) goes through `askTaskDeleteScope` + `deleteTaskWithUndo` (`task_delete.dart`). A recurring task (`isRecurring`) asks "This task" / "This and all following tasks": the first calls `TasksNotifier.skipOccurrence` (moves to the next occurrence, reschedules the notification; undo restores the previous version), the second trashes the task. Swipe left on a recurring task opens this dialog and the row snaps back; other tasks are trashed directly with undo.

### 5.4 Calendar

**Path:** `lib/screens/calendar/`

**Features:**
- Views: day, multi-day (week / 7 days), month, year, schedule (opens on today, scrolls without limit into past and future months), search results. Month days open a bottom sheet with the day's events.
- Day and multi-day views share `CalendarTimeGrid` (`calendar_time_grid.dart`): weekday header (multi-day only), an all-day row (all-day events and tasks; at most 3 rows in the day view, 2 in the week views, the last becoming `+N` that opens the day sheet), then 24 slots of 56 px with an hour gutter on the left. Timed events are placed by time of day and duration (no end or shorter: 30 min; past midnight: cut at 24:00); overlapping events form clusters split into the fewest columns. Today shows a line at the current time (refreshed every minute); the grid opens scrolled to the hour before now. Tapping an empty slot opens the editor for a new one-hour event at that hour. The mouse wheel scrolls the grid there instead of changing period.
- Schedule view (`CalendarScheduleView`): a `CustomScrollView` centered on today (`center` key on the future sliver) with two lazy `SliverList`s of months, past growing upward and future downward (`_monthRange` = 1200 months each way); scroll offset 0 is today, so the "Today" button animates the `ScrollController` owned by `CalendarWorkspaceView` (`_scheduleController`) back to 0; each month (`_ScheduleMonth`) is a banner, then one row per day with entries: weekday (3 letters) and day number on the left (today highlighted), entry cards on the right. Card subtitle (`calendarItemSubtitle`): the time range (none for all-day entries) and "Compleanno"/"Onomastico" for those kinds, joined by ` · `; no subtitle when neither (color and icon tell tasks and all-day entries apart).
- Editor: Birthday and Name day exclude each other; turning one on (`_withKind`) also sets all-day, yearly recurrence (if none) and both alerts, and shows a banner with the kind's card color (`calendarItemStyle`); the checkbox uses the accent (`birthdayColor` / `nameDayColor` in `calendar_event_style.dart`).
- Entries of a day are ordered by `compareCalendarItems` (all-day first, then time of day — not the full start date, which for a recurring event is its first occurrence — then title) via `calendarItemsOn`.
- The selected view is `calendarViewModeProvider` (`PersistedEnumNotifier<CalendarViewMode>`, `SharedPreferences` key `calendar_view_mode`, default month), so it survives section changes and restarts; the focused day/month is not persisted and restarts from today.
- Date + time picker: `showDateTimePickerDialog` (`widgets/shared/date_time_picker_dialog.dart`) shows the month grid (`CalendarDatePicker`) and below it a time chip (tap → `showTimePicker`, ✕ removes it) with Annulla/Fine, like Google Tasks, so changing only the day or only the time takes one dialog. Returns `({DateTime date, TimeOfDay? time})` (`.combined` → `DateTime`) or `null` on cancel. `timeRequired` hides the ✕ (note reminder, timed event start), `showTime: false` shows the calendar only (all-day events); `defaultTime(date)` is the time offered when one is added. Used by the task editor, the new-task sheet, the note reminder and the event start.
- Time picker defaults: `initialPickerTime(date, preferred)` (`utils/picker_defaults.dart`) offers `preferred` unless `date` is today and it has already passed, then the current time. Used by the task editor and the new-task sheet (preferred = due time or the default alert time from Settings), the note reminder (preferred = current reminder or now) and the event editor for new events only (preferred = start time). `newEntryStart(day)` gives "now" for today: the day sheet "Aggiungi" creates today's event at the current time instead of midnight.
- Calendar FAB "+": `showNewCalendarEntrySheet` (`calendar_new_entry.dart`) asks Evento / Task (`CalendarEntryType`) and opens the event editor (start now) or the task editor (day-only due date today, so the task shows in the calendar). Both editors show `CalendarEntryTypeSelector` (SegmentedButton under the title) while the entry is new (`_isNew`): switching calls `switchEventToTask` / `switchTaskToEvent`, which `pushReplacementNamed` the other editor carrying over title, description and date (all-day event ↔ day-only due date, timed event ↔ due time, no due date → event starting now); the left editor sets `_softDeleted` so it does not save. The task editor schedules the reminder on the first save, so a due time carried over from an event notifies.
- Event editor: title, date, start time, optional end time (an end before the start moves to the next day, an end equal to the start removes it), location (passed to `CalendarEventDetailsSection` as `locationField`, right below date and time; `CalendarLocationField` in `calendar_location_field.dart`: free text with an overlay of suggestions, up to 3 locations of other events — `_locationHistory`, computed once in `initState` — then up to 5 addresses from `PlaceSearchService` in `utils/place_search_service.dart`, Nominatim with `accept-language` = app locale, silent on errors; a new event with only a location is saved), all day (clears the end), birthday, name day, recurrence, color (sheet with the note swatches + custom Material color + "Predefinito" to clear it), alerts (all-day events only), archive/delete. Events cannot be pinned: calendar views are ordered by time.
- Recurring events are expanded by `calendarEventOccursOn` (monthly on the 31st skips short months, yearly on 29 February only in leap years).
- Tasks with a due date are shown (`TaskCalendarEvent.isShown`): at the due time when the due date has one (`TaskModel.hasDueTime`: not midnight; the editor shows it as `d MMM yyyy, HH:mm` and its date picker keeps it), otherwise as all-day entries on the due date. `calendarItemsProvider` merges `activeEventsProvider` with `calendarTaskItemsProvider` (each task wrapped in a read-only `TaskCalendarEvent`, never persisted, recurrence kept) while `calendarShowTasksProvider` is on (`BoolSettingNotifier`, `SharedPreferences` key `calendar_show_tasks`, default on, toggled from the app bar). Search covers them too. Taps go through `AppNav.openCalendarItem`, which opens the task view (`viewTask`) for a task and the event view (`viewEvent`) otherwise.
- Event view: `CalendarEventDetailsScreen` (`calendar_event_details_screen.dart`, route `AppRoutes.eventDetails`): color square + title, birthday/name day, date and time range, location (tap → `https://www.google.com/maps/search/?api=1&query=…` via `openExternalLink`, snackbar if it fails), recurrence, alerts with their time (`notifiesDayBefore` / `notifiesSameDay`: a timed event always shows its same-day alert), description; pencil → editor, bin → confirm and trash (alerts cancelled). Like the task view it follows `calendarProvider` and closes once trashed. New events (long press, day sheet) open the editor directly; the FAB first asks event or task. Both views use the shared `DetailRow` (`widgets/shared/detail_row.dart`). Export, backup and statistics still read `activeEventsProvider` only.
- Entry colors come from `calendarItemStyle` (`calendar_event_style.dart`), shared by list cards (`CalendarEventListTile`), month/week chips and search results: each kind has a `_Swatch` taken from the note palette (`AppColors.noteSwatchesLight/Dark`), pastel fill in light theme and deep tone in dark theme: timed event yellow / slate, all-day lilac / deep purple, birthday cyan / indigo + cake, name day peach / burnt orange + sparkle, task light green / dark green + `Icons.task_alt` (the task icon, not a checkbox, since tapping opens the task; completed: faded, struck through). Text is black or white via `AppColors.contrastingTextColor`. `CalendarItemStyle.accent` keeps a saturated tone of the same kind (`primary`, deep purple, `birthdayColor`, `nameDayColor`, green) for markers drawn on the plain surface (color square and birthday/name day icon in the event view). Birthdays and name days also set `CalendarItemStyle.festiveEnd` (light: pink / yellow, dark: deep purple / deep pink): `CalendarEventListTile` then draws them larger (more vertical padding, icon in a circle, 16 pt bold title) on a diagonal gradient from `background` to `festiveEnd`, with confetti from `_ConfettiPainter` (dots and strips seeded by the title, so the pattern stays stable); month/week chips are unchanged. A user-picked `CalendarEventModel.color` overrides the kind's swatch (tasks excepted; birthdays and name days keep icon, gradient end and confetti): a note swatch maps to the one at the same index in the other theme, any other color is used as is, and the accent is the color at 50% lightness (blue-grey for near-greys).
- Search queries (`searchQueryProvider`, `taskSearchQueryProvider`, `calendarSearchQueryProvider`) are global and outlive their screen, so Home, Tasks and Calendar create their search `TextEditingController` with the current query: the field never looks empty while the list is filtered. `test/screens/calendar_refresh_test.dart` checks that entries edited from every calendar view show up on return.
- **Alerts — a day plus a time notifies, nothing else to set.** Tasks and events have no separate reminder. A timed event always alerts at its start (`CalendarEventModel.notifiesSameDay`); an all-day event alerts only on the days chosen with `alertSameDay` / `alertDayBefore` ("Avvisi" in the editor, below the recurrence, shown only while "Tutto il giorno" is on; birthdays and name days turn both on). `utils/event_alerts.dart` computes `upcomingEventAlerts`: occurrences (`CalendarEventModel.occursOn`, which also backs `calendarEventOccursOn`) within `alertHorizon` (30 days), at most `maxAlertOccurrences` (8) per event, at the start time or, for all-day events, at `allDayMinutes` (minutes after midnight: the Settings value `defaultAlertTimeProvider`, default `defaultAllDayAlertMinutes` = 09:00); archived/trashed events have none. `NotificationService.scheduleEventAlerts(event, allDayMinutes:)` replaces them (ids `idForEventAlert`, from 1 000 000, `maxEventAlerts` per event; no-op on web); the editor reschedules on save and cancels on delete; `resync()` reschedules them at every start, which moves the window forward (an app not opened for 30 days misses the later occurrences).
- Tasks: the due-date picker is followed by a time picker (cancel = day-only due date). `NotificationService.scheduleTaskReminder` schedules at the due time when `hasDueTime` (id `idForTask`); `_applyDueDate` cancels and reschedules it whenever the due date changes. `BackupRestorer.apply` turns on both alerts of birthdays and name days that have none, then calls `resync()` after any import/restore; `DataActions.importIcs` also calls it, so the imported events get their alerts right away. Tests: `test/providers/backup_restore_test.dart` (special alerts), `test/utils/event_alerts_test.dart`, `test/providers/reminders_resync_test.dart` (resync, including after a sign-in with notifiers already built signed out, and legacy task reminders).
- The search bar uses `NavScaffold(alignTitleEnd: true)`: it sits next to the app bar actions, up to 360 px wide.

### 5.5 Labels, archive and trash

**Path:** `lib/screens/labels_screen.dart`, `label_notes_screen.dart`, `archive_screen.dart`, `trash_screen.dart`

**Features:**
- Labels: create, rename (merges into an existing label with the same name), delete; note count per label; tapping a label opens its notes (active, then archived).
- Archive: three tabs (notes, tasks, events).
- Trash: three tabs, restore, delete for good, empty trash; each item shows the days left before the automatic purge.

### 5.6 Statistics and export

**Path:** `lib/screens/statistics/`, `lib/screens/export_screen.dart`

**Features:**
- Statistics: drawer section (below Archive), summary of notes, tasks and events computed by a screen-local provider, charts with `fl_chart`.
- Export: active notes as PDF, TXT, JSON, CSV or HTML. File text (labels, headers, date format) is in the UI language; JSON keys are fixed. Mobile saves/shares the file, web downloads it.

### 5.7 Settings

**Path:** `lib/screens/settings/`

The screens (`SettingsScreen`, `BackupDataScreen`) handle dialogs, file pickers and snackbars; data work is in `DataActions` and `BackupRestorer` (see [State management](#6-state-management)).

**Features:**
- Appearance (System/Light/Dark) and language (System/Italiano/English) as `SegmentedChoice`.
- Start screen (Calendar/Tasks/Notes, in drawer order) as `SegmentedChoice`: `startSectionProvider` (`PersistedEnumNotifier<StartSection>`, key `start_section`, default `notes`). See [Navigation](#9-navigation).
- Notes and tasks preferences (layout, FAB menu, completed tasks, grouping).
- Notifications: default alert time (`SettingsNotificationsSection`, `showTimePicker`): `defaultAlertTimeProvider` (`DefaultAlertTimeNotifier`, minutes after midnight, key `default_alert_minutes`, default 09:00, out-of-range values fall back to it). It is the time of all-day event alerts (birthdays and name days included) and the time first offered for a task's due time. Changing it goes through `RemindersActions.setDefaultAlertTime`, which saves it and reschedules the alerts of all-day events.
- Backup and data: a single entry (`SettingsBackupDataSection`) opens `BackupDataScreen` (`backup_data_screen.dart`, route `AppRoutes.backupData`, `AppNav.openBackupData`), which owns the export/import/clear flows and shows, in order:
  - Automatic backup: enable, frequency (daily, weekly, monthly), history with restore and delete.
  - Full backup: JSON export/import of everything, clear all.
  - Full backup content: notes, tasks, task lists, events, label names (`labels`) and the user's preferences (`settings`, see `PreferencesBackup`). The JSON file has them as top-level keys; the ZIP has `notes.json`, `tasks.json`, `calendar.json`, `metadata.json` plus `labels.json` and `settings.json` (both optional, missing from older backups). Both restore flows (JSON import and automatic backup history) read and parse the backup first, then confirm with `showRestoreBackupDialog` (`restore_backup_dialog.dart`): when the backup has preferences, a checkbox "Also restore settings" (off by default) decides `restoreSettings`. Labels are always merged into the existing ones (`LabelsNotifier.addAll`), never deleted.
  - Data per section (calendar, tasks, notes — with the Export screen —): JSON export/import, ICS export/import for the calendar, clear. Imports and clears ask for confirmation; persistence errors show a snackbar.
- Account: delete account (destructive confirmation → password for email accounts → non-dismissible progress dialog → `AuthNotifier.deleteAccount`; on success the app returns to the login).
- Info tile with the app version.

### 5.8 Info and privacy

**Path:** `lib/screens/info_screen.dart`, `lib/screens/privacy_policy_screen.dart`, `lib/widgets/changelog_dialog.dart`

**Features:**
- Info: logo, name, tagline, version (without build number), "What is Noteep", feature grid, links (source code, GitHub profile, email — external; onboarding, full changelog, privacy policy, open-source licenses — internal), credits. Max width 600. External links that fail to open show a snackbar.
- Privacy policy: native localized copy of `PRIVACY.md`, with the last-updated date from `privacyPolicyUpdatedAt` and a link to the online version (`uriPrivacyPolicy`: the portfolio page `https://ndenicolais.github.io/noteep/privacy/`).
- Changelog dialog: one block per version with sections Added / Improved / Fixed / Security (empty ones hidden).

### 5.9 Home screen widgets (Android)

**Path:** `android/app/src/main/kotlin/com/ndn21/noteep/`, `lib/utils/widget_service.dart`, `lib/core/routing/home_widget_*.dart`

**Features:**
- **Quick actions** (`QuickActionsWidget`, 3×1 resizable): New note / New task / New event.
- **New note / New task / New event** (1×1): a single round button each (fixed 56dp `widget_circle_background` oval centered in the cell, since cells are rarely square), icon over the short name (`widget_note` / `widget_task` / `widget_event`: Note, Task, Event); the picker keeps the "New …" labels.
- **Notes / Tasks / Calendar** (`NotesSummaryWidget`, `TasksSummaryWidget`, `CalendarSummaryWidget` in `SummaryWidgets.kt`, 3×3 resizable): a header (icon, title, "+") over a scrolling `ListView` fed by `SummaryListService` (`RemoteViewsService`, `BIND_REMOTEVIEWS`). Rows are built in Dart by `lib/utils/home_widget_rows.dart` and stored as JSON under `<kind>_rows`: latest notes (pinned first, note color bar, plain-text or checklist preview, max 30); tasks to do grouped by due day like the Tasks page (overdue first, undated last, max 60); calendar entries of the next 14 days (events, birthdays/name days, tasks with a due date; all-day first; kind accent bar; max 60). Day headers carry their `yyyy-MM-dd`: the factory swaps the label for Today/Tomorrow/Yesterday by the current date and the calendar drops past days, so the list stays right after midnight without a sync (`updatePeriodMillis` 30 min re-reads it).
- List widget taps: header → `noteep://section/{notes,tasks,calendar}`, "+" → `noteep://new/...`, row → `noteep://open/{note,task,event}/<id>` (a mutable `PendingIntent` template with `HOME_WIDGET_LAUNCH_ACTION`; each row fills in its data URI).
- Buttons open `MainActivity` with a `noteep://new/{note,task,event}` URI; `HomeWidgetLaunchHandler` opens an empty editor (see [Navigation](#9-navigation)).
- All widgets are `AppWidgetProvider`s with `RemoteViews`. Layouts may only use RemoteViews-supported classes (`FrameLayout`, `LinearLayout`, `TextView`, `ImageView`, …): a plain `<View>` (e.g. as a divider) makes the launcher show "Can't load widget" — use a `FrameLayout` with a background instead. Picker names and descriptions are Android string resources (`res/values`, `res/values-it`).

### 5.10 Shared behavior

- **Drawer** (`AppDrawer`, `NavScaffold`): Calendar, Tasks, Notes, Labels, Archive, Statistics, Trash, Settings and sign out. Export opens from Settings → Backup and data → Notes, Info from Settings → Info.
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
| UI settings and filters | `providers/settings/ui_provider.dart` | Layout, start section, default alert time, sort orders, FAB menu, task options, onboarding flag, search queries, `filteredNotesProvider`, `filteredNoteIdsProvider`, `filteredTasksProvider`, `allTagsProvider`, `tagNoteCountsProvider`, `notesWithTagProvider(tag)`; base class `PersistedEnumNotifier` |
| `BackupSettingsNotifier`, `BackupStatusNotifier`, `availableBackupsProvider` | `providers/settings/backup_provider.dart` | Automatic backup settings and status, list of local backups |
| `BackupRestorer` (`backupRestorerProvider`) | `providers/settings/backup_restore.dart` | `FullBackupData` parsing (flat JSON and ZIP layouts), `apply(data, restoreSettings:)` (preferences first when asked, then replaces each data section present and merges the labels; birthdays and name days with no alert get both through `withSpecialAlerts`, as older data predates the alerts), `readZip` |
| `PreferencesBackup` (`preferencesBackupProvider`) | `providers/settings/preferences_backup.dart` | `export()`/`restore(json)` of the backed-up preferences under stable names independent of the `SharedPreferences` keys: `themeMode`, `language`, `startSection`, `notesLayout`, `notesSortOrder`, `notesFabMenu`, `tasksSortOrder`, `showCompletedTasks`, `groupTasksByPriority`, `calendarView`, `calendarShowTasks`, `defaultAlertMinutes`, `autoBackupEnabled`, `autoBackupFrequency`. Applied through each notifier's setter (state and storage update together); unknown keys and invalid values are skipped. Device bookkeeping (onboarding seen, last backup time, last changelog seen, migration flags) is not backed up. A new user preference must be added here |
| `DataActions` (`dataActionsProvider`) | `providers/settings/data_actions.dart` | Export payloads (`fullBackupExport`, `zipBackupSections` for the automatic backup), per-section import, `parseFullBackup`/`importFullBackup`, ICS export/import, clear, `wipeRemoteData`/`wipeLocalData` for account deletion |
| `RemindersActions` (`remindersActionsProvider`) | `providers/reminders_actions.dart` | `resync()` after sign-in and `cancelAll()` after sign-out (see below), `setDefaultAlertTime`. `notificationServiceProvider` wraps `NotificationService.instance` so tests can fake it |

**Non-obvious behavior**

- **User switch**: data notifiers watch `currentUidProvider` and `firestoreProvider` in `build()`, start `_load()` and return `[]`. A fetch still running for the previous user is discarded by comparing the uid after the `await`.
- **Optimistic writes** (`FirestoreListMutations.mutate(apply, persist)`): the state changes first. With Firestore persistence a write future completes only when the server acknowledges it, so `mutate` waits at most `writeGrace` (3 s): an error within the window rolls back and rethrows; after it, the write is tracked as queued and the caller continues (no stuck spinners offline). A late server rejection increments `failures` and triggers `reload()`.
- **Batches**: `commitInChunks` splits into batches of 500 and commits them together, so offline they are all queued at once.
- **Load vs reload**: the first load merges Firestore results with the current state; `reload()` replaces it.
- **Loading and errors**: `notesLoadingProvider`/`tasksLoadingProvider` start `true` and turn `false` in a `finally`; load errors go to `notesLoadErrorProvider`/`tasksLoadErrorProvider`, so screens tell "loading", "empty" and "sync error" apart.
- **Trash purge**: on load, items trashed more than 7 days ago are deleted through `mutate`, without blocking the loading flag.
- **Rebuild granularity**: lists watch only ids (`IdList`, equal by content) and each row watches its item (`noteByIdProvider`, `taskByIdProvider`), so editing one note rebuilds only its card. Notifiers keep untouched item instances unchanged for this to work. Archive, Trash, Statistics and Calendar watch whole lists.
- **Account deletion order**: re-authenticate first (password or Google; cancelling aborts), then `wipeRemoteData` (reads every subcollection from the **server**, so it fails offline instead of deleting halfway), `User.delete()`, `wipeLocalData` (best-effort: cancels notifications, deletes local backups), Google sign-out.
- **Reminders follow the account**: notifications are scheduled on the device when an item is edited, so `main.dart` listens to `currentUidProvider`. On a sign-in (including the session restored at a cold start) it calls `RemindersActions.resync()`: it first yields once and reads the three providers, so notifiers built while signed out (the home-widget listeners read them at startup) rebuild for the new uid instead of handing back the signed-out `initialLoad` already completed with `false` (which made the cold-start resync schedule nothing); then it awaits `initialLoad` of the notes, tasks and calendar notifiers (a per-user `Completer<bool>` recreated in `build()`, `false` when the fetch fails or nobody is signed in), then cancels every notification and schedules the future reminders of notes, the due times of open tasks and the alerts of events not in the trash, without the permission dialog. If any load failed it touches nothing, so an offline start keeps the reminders already scheduled. When the uid becomes empty (sign-out, account deletion) it calls `cancelAll()`.
- **Restore**: `FullBackupData` parses every section before any provider is touched; `replaceAll` also deletes Firestore documents not in the backup, otherwise they would come back on the next load.

---

## 7. Services

Plain classes in `lib/utils/`, not tied to Riverpod.

### 7.1 AppBootstrap

**Path:** `lib/utils/app_bootstrap.dart`

- `installErrorHandlers()`: `PlatformDispatcher.onError` logs (debug only) unhandled async errors instead of crashing; in release `ErrorWidget.builder` shows a neutral icon.
- `registerFontLicenses()`: registers the OFL text of each bundled font with `LicenseRegistry` (read lazily when the licenses page opens; only once, also on Retry). Test: `test/utils/font_licenses_test.dart`.
- `init()`: registers the font licenses, then runs the **required** steps (failure shows `BootErrorApp`): `Firebase.initializeApp` (skipped if already done, for Retry), Firestore `Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)` (persistence is not the default on the web), `SharedPreferences`, then `Intl.defaultLocale = startupLanguageCode(prefs)` so text built before the first frame is already localized. **Optional** steps (failure only logged): `initializeDateFormatting` for `it`/`en`, `NotificationService.init()`, `WidgetService.init()`.

### 7.2 NotificationService

**Path:** `lib/utils/notification_service.dart`

- `init()`, `scheduleNotification(...)`, `cancelNotification(id)`, `cancelAllNotifications()`, `scheduleNoteReminder(note)`, `scheduleTaskReminder(task)` (at the due time), `scheduleEventAlerts(event, allDayMinutes:)`, `cancelEventAlerts(id)`. The schedule methods take `askPermission` (default `true`; `false` for the resync after sign-in).
- Deterministic ids: `idForNote`, `idForTask`, `idForEvent`. Schedules with `AndroidScheduleMode.exactAllowWhileIdle`.
- Permissions are requested on the first notification the user schedules (a note reminder, a task time, an event), not at startup.
- Every notification carries a `NotificationTarget` payload (`note:<id>`, `task:<id>`, `event:<id>`); a tap (app open or cold start) publishes it in `pendingTarget`.
- Channel name and description are passed on every schedule with `currentL10n()`, so Android updates them to the current language. Already scheduled notifications keep the language they were created in.
- Tests: `test/core/notification_target_test.dart`, `notification_launch_handler_test.dart`; the resync is covered by `test/providers/reminders_resync_test.dart` with a fake service.

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

- `init()`, `scheduleSync(notes, tasks, events)`: no-op on the web; `main.dart` calls it when active notes, tasks or events change.
- Debounces 500 ms, builds every value (list titles/empty texts, rows JSON, Today/Tomorrow/Yesterday labels), writes only the keys that changed and refreshes only the widgets that read them (`_widgetKeys`).
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
- `NotificationLaunchHandler` wraps the signed-in `HomeScreen` (so it is under the `MaterialApp` navigator): it listens to `pendingTarget`, waits for the item to load and opens it with `AppNav` (tasks and events in their read-only view). If the item is still missing when loading ends (notes/tasks) or after 10 s (events), it shows "Reminder item not found". A tap before sign-in waits for the user to sign in.
- `HomeWidgetAction.parse` reads `noteep://new/...` URIs, `HomeWidgetOpenItem.parse` `noteep://open/<kind>/<id>` (opens the note editor, or the task/event read-only view; on a cold start it waits up to 20 s for the item to load via `notesByIdProvider` / `tasksByIdProvider` / `eventsByIdProvider`), `HomeWidgetSection.parse` `noteep://section/<section>` (pops to home, then pushes Tasks or Calendar). `HomeWidgetLaunchHandler` (Android only) handles the cold start once per process (`initialLaunchHandled`, otherwise the intent left on the activity would reopen the editor at every sign-in) and taps while the app runs (`singleTop` → `onNewIntent`).
- `StartSectionLauncher` (`start_section_launcher.dart`) wraps both handlers: when the signed-in home mounts (cold start or sign-in) and the start section is not Notes, its post-frame callback pushes that section with `AppRouter.noTransition`, so it appears without a transition. Being outermost, its callback runs first and anything a notification or widget opens lands above it. Back returns to Notes, as from any section.

---

## 8. Theme and style

**Fonts.** The UI uses **Exo 2**, bundled in `assets/fonts/`. Notes can also use Montserrat, Open Sans, Dancing Script, Playfair Display and Pacifico (`kNoteFonts` in `font_family_picker.dart`). All fonts are bundled variable fonts, so they work offline. Each one ships its SIL Open Font License text next to it (`assets/fonts/<Family>-OFL.txt`, from the google/fonts repository), and `AppBootstrap.registerFontLicenses()` adds them to the licenses page, as the OFL requires; a new font needs its OFL file and an entry in `AppBootstrap.fontLicenses`.

**App icon.** Source logo `assets/images/app_logo.png` (1024×1024, transparent, rendered from `design/app-icon/foreground.svg`) and `design/app-icon/app_logo_mono.png` (themed icons: the check mark is cut out, otherwise the full silhouette would disappear). The local script `tool/icons/generate_icons.ps1` (`/tool/` is git-ignored) uses background `#3D3F4D` and writes:

- in `assets/images/`: `app_icon_legacy.png` (logo at 64% on a rounded square), `app_icon_foreground.png` and `app_icon_monochrome.png` (62%, transparent);
- in `images/icons/` (not bundled): `icon_512.png` (store), `icon_192.png`, `oauth_logo_120.png` (Google Auth Platform → Branding), `favicon_32.png`.

Then `dart run flutter_launcher_icons` (config in `pubspec.yaml`) generates `@mipmap/launcher_icon` (legacy, adaptive with 16% inset, monochrome), also used by notifications. Web icons and `favicon.png` come from `design/app-icon/icon.svg` (symbol inside the central 80%, so it also works as maskable); `web/manifest.json` uses `#3D3F4D` for `theme_color`/`background_color`. In the app, `AppLogo({size})` shows the logo on an `AppColors.dark` rounded square, like the launcher icon.

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
| `ItemCard` / `ItemCardList` | Card + `ListTile` rows for archive and trash |
| `TagChip` | Non-interactive chip in `secondaryContainer`; `dense` on note cards |
| `date_time_picker_dialog.dart` | `showDateTimePickerDialog`: calendar + optional time chip in one dialog (see Calendar/Tasks pickers) |
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

Named routes with `MaterialApp.onGenerateRoute: AppRouter.onGenerateRoute` (`lib/core/routing/app_router.dart`). Screens call the typed helpers in `AppNav` (`openNote`, `openTask`, `openEvent` — editors —, `viewTask`, `viewEvent` — read-only views of saved items —, `openLabel`, `openTasks`, `openExport`, `openInfo`, `openOnboarding`, `openPrivacyPolicy`). Detail routes with a missing or wrongly typed argument, and unknown names, go to `AppRouter.onUnknownRoute` → `UnknownRouteScreen` instead of crashing.

Drawer sections (`AppRouter.sectionRoutes`) use `FadeThroughPageRoute` (an opaque scaffold-colored backdrop fades in over the first 30%, hiding Home and the previous section below it; then the page fades + scales 0.92 → 1; 300 ms, instant with reduced motion or when pushed with the `AppRouter.noTransition` argument, used for the start section; going back still fades) because they are siblings, not a drill-down; detail screens use `MaterialPageRoute`. The drawer returns to Home with `popUntil` on the root.

| Route | Screen | Description |
|---|---|---|
| *(home)* | `HomeScreen` / `LoginScreen` / `OnboardingScreen` | Chosen by the auth gate (see [5.1](#51-startup-and-authentication)) |
| `/note` | `NoteEditorScreen` | Argument `NoteRouteArgs(note, autoOpenRecorder)` |
| `/tasks` | `TasksScreen` | Drawer section |
| `/task` | `TaskEditorScreen` | Argument `TaskModel` |
| `/calendar` | `CalendarWorkspaceView` | Drawer section |
| `/event` | `CalendarEventEditorScreen` | Argument `CalendarEventModel` |
| `/labels` | `LabelsScreen` | Drawer section |
| `/label` | `LabelNotesScreen` | Argument `String` (label name) |
| `/archive` | `ArchiveScreen` | Drawer section |
| `/statistics` | `StatisticsScreen` | Drawer section |
| `/trash` | `TrashScreen` | Drawer section |
| `/export` | `ExportScreen` | |
| `/settings` | `SettingsScreen` | Drawer section |
| `/info` | `InfoScreen` | |
| `/onboarding` | `OnboardingScreen(replay: true)` | Replay from Info |
| `/privacy-policy` | `PrivacyPolicyScreen` | From Info and from the login screen (no sign-in needed) |

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

- **Pure logic**: recurrence, Markdown to plain text, ICS import/export round trip, changelog service and entries (`it`/`en` changelog keys match, each bullet used once), notification payloads, Home widget URIs and list rows, colors contrast, text theme, task sorting, login validators.
- **With fakes**: data notifiers, labels, undo/redo, backup restore, `DataActions` (including account wipe isolation between users), reminders resync and cancel (`RemindersActions` with a fake `NotificationService`), offline sync (`FirestoreListMutations` with a short `writeGrace`) against `fake_cloud_firestore`; `BackupService` on a real temp folder with a mocked `path_provider` channel.
- **Widget and layout**: editors, Info, login privacy notice, boot error, router, notification and Home widget launch handlers, masonry grid, rebuild granularity, `NoteHero`, skeletons, `FadeSwitcher`, design-system components, dialogs, swipe actions, empty state; accessibility (200% text on 360×690 without overflow, card semantics and custom actions, sheets above the navigation bar).

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
| Web | Development only, not published (no Firebase Hosting): modern browsers, run on `localhost:5000`; no Home screen widgets and no automatic backups (they need `dart:io`) |
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
flutter run -d chrome --web-port 5000         # web: port 5000 is the authorized OAuth origin and API key referrer
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
- **Android developer verification**: `android/app/src/main/assets/adi-registration.properties` holds the Play Console account snippet (only the snippet, no trailing newline) that proves ownership of the release key for the package registration. It is git-ignored (`android/.gitignore`), like in the other apps of the account, which share the same snippet: recreate it from Play Console on a new machine before building an APK to upload there.

**Notes**

- Never commit: `key.properties`, keystores, `google-services.json`, `firebase_options.dart`, `adi-registration.properties`, `symbols/`, `/tool/`, `deploy_android.ps1`, `CLAUDE.md`, `TASKS.md`.
- Version source of truth: `version: X.Y.Z+N` in `pubspec.yaml` (`N` is the Android `versionCode` and always grows), mirrored by `appVersion`/`appBuildNumber` in `lib/core/constants/app_version.dart`. Each release adds a `ChangelogEntry` at the top of `changelogEntries`, with every bullet key in both ARB files (`changelog_test.dart` fails otherwise).
- Obfuscation symbols go to `symbols/v<version>` (outside `build/`, so `flutter clean` keeps them) and are needed to read crash stack traces with `flutter symbolize`: keep them for every release.
- Privacy policy: the same text lives in `PRIVACY.md`, in the ARB files (`PrivacyPolicyScreen`) and on the portfolio page `https://ndenicolais.github.io/noteep/privacy/` (built from `NOTEEP_PORTFOLIO_PAGES.md` by the site project; it is also the privacy URL of the OAuth consent screen). Update them together, with `privacyPolicyUpdatedAt` in `app_info.dart` equal to the date in `PRIVACY.md`, and before the release when adding services, analytics or permissions.
- Local tools: `tool/icons/generate_icons.ps1` (see [Theme and style](#8-theme-and-style)).
- README previews: `flutter test tool/preview/generate_preview_test.dart` regenerates `images/noteep_preview.png` (tilted phones) and the screens without system bars (540 px wide) in `images/screenshots/<name>.png` from `images/screenshots/<name>_raw.png` (git-ignored and kept locally). The script lives outside `test/`, so it does not run with `flutter test`. Banner order: `editor`, `calendar`, `home`, `tasks`, `stats`; raw screenshots are 1080×2392 with gesture navigation, cropped by 108 px at the top and 70 px at the bottom. Screens are taken in English, light theme, with demo data.

---

## License

Copyright © 2026 Nicola De Nicolais. Source-available, non-commercial license: see [LICENSE](LICENSE). Commercial use, including publishing on an app store, requires written permission.

Bundled fonts (Exo 2, Montserrat, Open Sans, Dancing Script, Playfair Display, Pacifico) are Google Fonts under the SIL Open Font License 1.1; their license texts are in `assets/fonts/*-OFL.txt`. Font and third-party package licenses are shown in the app (Info → Open-source licenses).

Author: Nicola De Nicolais — ndn21dev@gmail.com — [github.com/ndenicolais](https://github.com/ndenicolais)
