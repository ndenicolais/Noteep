# Documentazione Tecnica — Noteep

Documentazione tecnica dell'app per chi sviluppa/manutiene il codice. Per la descrizione delle funzionalità lato utente vedi `README.md`.

---

## 1. Panoramica architetturale

Noteep è un'app Flutter (note + task + calendario) con backend **Firebase** (Auth + Firestore) e state management **Riverpod** (`flutter_riverpod`, pattern `StateNotifierProvider`).

Principi chiave:
- **Un notifier per collezione dati** (`NotesNotifier`, `TasksNotifier`, `TaskListsNotifier`, `CalendarNotifier`), ciascuno legato a `users/{uid}/{collection}` su Firestore.
- **Optimistic update con rollback**: ogni notifier ha un helper privato `_mutate(apply, persist)` che aggiorna lo stato locale subito, poi tenta la scrittura su Firestore; se questa fallisce, lo stato torna a quello precedente e l'eccezione viene rilanciata.
- **Provider derivati** (`Provider` semplici, non notifier) per viste filtrate/ordinate: `activeNotesProvider`, `archivedNotesProvider`, `trashedNotesProvider`, `filteredNotesProvider`, e i loro equivalenti per task/eventi.
- **Cestino con auto-purge**: le entità non vengono mai cancellate direttamente da un'azione "elimina" nella UI, ma marcate con `deletedAt` (soft-delete); un job dentro `_load()` di ogni notifier elimina definitivamente ciò che è in cestino da più di 7 giorni.
- **Undo/redo per-entità**: `note_editor` e `task_editor` hanno ciascuno un provider `family` (`noteChangeHistoryProvider(noteId)` / `taskChangeHistoryProvider(taskId)`) che tiene uno stack di comandi (`NoteChange`/`TaskChange`, pattern Command) applicati/annullati tramite le classi statiche `NoteUndoRedoManager`/`TaskUndoRedoManager`.
- **Errore di caricamento distinto da "vuoto"**: `_load()` di `NotesNotifier`/`TasksNotifier` è avvolto in un try/catch che scrive su `notesLoadErrorProvider`/`tasksLoadErrorProvider` (`StateProvider<Object?>`, iniettato nel notifier come callback al costruttore); le liste (Home/Tasks/Archive) leggono questo provider per mostrare un messaggio di errore di sincronizzazione invece del generico empty-state quando il primo caricamento da Firestore fallisce.
- **Loading iniziale distinto da "vuoto"**: `notesLoadingProvider`/`tasksLoadingProvider` (`StateProvider<bool>`, iniziano `true`) sono impostati a `false` in un blocco `finally` di `_load()` tramite un secondo callback (`_onLoadDone`), iniettato nel costruttore del notifier con lo stesso pattern del callback d'errore. Home/Tasks mostrano uno spinner al posto dell'empty-state quando la lista è vuota ma il primo caricamento è ancora in corso.
- **Ricarica manuale (pull-to-refresh)**: `NotesNotifier`/`TasksNotifier`/`TaskListsNotifier` espongono `reload()`, che rilegge la collezione da Firestore e **sostituisce** lo stato (`_load(replace: true)`), a differenza del caricamento iniziale che fa merge. Serve a recuperare dopo un errore di sincronizzazione o a vedere modifiche fatte da un altro dispositivo; le scritture locali ancora in volo sono comunque incluse nei risultati di Firestore.

---

## 2. Struttura del progetto (`lib/`)

```
lib/
├── main.dart                  # bootstrap app, auth gate, route table
├── firebase_options.dart      # config Firebase Android + Web (git-ignored)
├── core/constants/            # app_version.dart (versione, allineata a pubspec), changelog.dart (voci Changelog)
├── models/                    # classi dati immutabili-per-copyWith + (to/from)Json
├── providers/                 # Riverpod: un file per dominio, + providers/settings/
├── screens/                   # una sottocartella per feature-schermata complessa,
│                               # file singoli per le schermate più semplici
├── theme/                     # palette, tipografia, raggi, ThemeData
├── utils/                     # servizi stateless/singleton, non legati a Riverpod
└── widgets/                   # widget riusabili cross-schermata
```

Le schermate con più stato/logica (`calendar`, `note_editor`, `settings`, `task_editor`) sono organizzate come sottocartella: un file "orchestratore" (`*_screen.dart`) che possiede lo stato e delega la UI a widget figli nello stesso folder (vedi §5).

---

## 3. Modelli dati (`lib/models/`)

Tutti i modelli seguono lo stesso pattern: costruttore con default sensati, `copyWith`, `toJson`/`fromJson` (per Firestore/backup), id generato con `uuid` se non fornito.

| File | Classe | Campi principali |
|---|---|---|
| `note_model.dart` | `NoteModel` | `title`, `content`, `type` (`note`\|`checklist`), `style` (`NoteStyle`), `checklistItems[]`, `audioNotes[]`, `isArchived`, `isPinned`, `isLocked`, `reminder`, `linkedNoteIds[]`, `tags[]`, `createdAt`/`updatedAt`/`deletedAt` |
| `note_model.dart` | `NoteStyle` | font family/size, colori testo/sfondo, bold/italic/strikethrough, con override separati per il titolo |
| `note_model.dart` | `ChecklistItem` | `text`, `isChecked` |
| `task_model.dart` | `TaskModel` | `title`, `description`, `isCompleted`, `dueDate`, `isPinned`, `isSpecial`, `isArchived`, `listId` (FK a `TaskListModel`), `recurrence`, `reminder`, `tags[]`, `subtasks[]`, timestamp |
| `task_list_model.dart` | `TaskListModel` | `name`, timestamp — elenco custom mostrato come tab in `TasksScreen` |
| `subtask_model.dart` | `SubtaskModel` | `title`, `isCompleted`, timestamp |
| `calendar_model.dart` | `CalendarEventModel` | `title`, `description`, `startTime`/`endTime`, `isAllDay`, `isBirthday`, `isNameDay`, `isPinned`, `isArchived`, `recurrence`, `recurrenceEndDate` (da RRULE UNTIL/COUNT import ICS), `reminder`, `tags[]`, timestamp |
| `audio_note.dart` | `AudioNote` | `filename`, `filepath`, `duration`, `createdAt`, `transcription?` |
| `change_history.dart` | `NoteChange` (astratta) | Pattern Command: `NoteTitleChange`, `NoteTextChange`, `NoteStyleChange`, `ChecklistItem*Change`, `AudioNote*Change` — ciascuna con `apply`/`undo` |
| `task_change_history.dart` | `TaskChange` (astratta) | Equivalente per task: `TaskTitleChange`, `TaskDescriptionChange`, `TaskCompletedChange`, `TaskDueDateChange`, `TaskPinnedChange`, `TaskRecurrenceChange`, `Subtask*Change` |
| `note_template.dart` | `NoteTemplate` + `kNoteTemplates` | 6 template predefiniti (riunione, diario, progetto, spesa, viaggio, brainstorming) usati da `note_template_screen.dart` |

`RecurrenceType` (`none`/`daily`/`weekly`/`monthly`/`yearly`) è definito in `utils/recurrence.dart` ed è condiviso tra `TaskModel` e `CalendarEventModel`.

---

## 4. Gestione dello stato — Provider Riverpod (`lib/providers/`)

**Nessun uso di code-gen** (`@riverpod`/`riverpod_generator`): tutti i provider sono dichiarati manualmente con `StateNotifierProvider`/`Provider`/`StreamProvider`/`StateProvider`. Le dipendenze di code-gen (`riverpod_annotation`/`riverpod_generator`/`build_runner`) sono state rimosse perché inutilizzate (vedi §11).

### Grafo di dipendenza principale

```
authStateProvider (StreamProvider<User?>, da FirebaseAuth.authStateChanges)
  └── currentUserProvider (Provider<User?>)
        ├── notesProvider
        ├── tasksProvider
        ├── taskListsProvider  ──(chiama esplicitamente)──> tasksProvider.notifier.clearListReferences()
        └── calendarProvider

sharedPreferencesProvider (dichiarato in notes_provider.dart, iniettato in main.dart)
  └── usato da: themeModeProvider, homeLayoutProvider, sortOrderProvider,
      taskSortOrderProvider, customLabelsProvider, showCompletedTasksProvider,
      groupTasksByPriorityProvider, backupSettingsProvider
```

### Provider per file

| File | Provider esportati | Note |
|---|---|---|
| `notes_provider.dart` | `notesProvider` (`NotesNotifier`), `activeNotesProvider`, `archivedNotesProvider`, `trashedNotesProvider`, `sharedPreferencesProvider` | CRUD note + tag (`renameTag`/`deleteTag`) + `reorderNotes`. `sharedPreferencesProvider` è dichiarato qui per storico ma è cross-cutting (usato da tutti i provider di settings). |
| `tasks_provider.dart` | `tasksProvider` (`TasksNotifier`), `taskListsProvider` (`TaskListsNotifier`), `activeTasksProvider`, `specialTasksProvider`, `archivedTasksProvider`, `trashedTasksProvider`, `taskListTasksProvider(listId)` | `TaskListsNotifier` mantiene un `Ref` per invocare `tasksProvider.notifier.clearListReferences()` quando un elenco viene eliminato. |
| `calendar_provider.dart` | `calendarProvider` (`CalendarNotifier`), `activeEventsProvider`, `archivedEventsProvider`, `trashedEventsProvider`, `calendarSearchQueryProvider`, `filteredCalendarEventsProvider` | Stesso pattern CRUD + cestino di notes/tasks. |
| `auth_provider.dart` | `firebaseAuthProvider`, `authStateProvider`, `currentUserProvider`, `authNotifierProvider` (`AuthNotifier`, stato `AsyncValue<void>`) | Google Sign-In, email/password, reset password, sign-out. `authErrorMessage(FirebaseAuthException)` mappa i codici errore Firebase in messaggi italiani. |
| `audio_provider.dart` | `recordingStateProvider` (`RecordingStateNotifier`) | Stato registrazione audio (`isRecording`, `currentDuration`, `errorMessage`, `lastRecordedNote`), isolato dagli altri notifier. |
| `notes_undo_redo_provider.dart` | `noteChangeHistoryProvider` (family, autoDispose) | Stack undo/redo per nota; consumato tramite `NoteUndoRedoManager` (classe statica) da `note_editor_screen.dart`. |
| `tasks_undo_redo_provider.dart` | `taskChangeHistoryProvider` (family, autoDispose) | Equivalente per task, `TaskUndoRedoManager`. |
| `settings/theme_provider.dart` | `themeModeProvider` (`ThemeModeNotifier`) | Estende `PersistedEnumNotifier`, persiste su SharedPreferences by-name. |
| `settings/ui_provider.dart` | `homeLayoutProvider`, `sortOrderProvider`, `taskSortOrderProvider`, `customLabelsProvider`, `showCompletedTasksProvider`, `groupTasksByPriorityProvider`, `searchQueryProvider`, `taskSearchQueryProvider`, `filteredNotesProvider`, `filteredTasksProvider`, `allTagsProvider` | Contiene anche la classe base `PersistedEnumNotifier<T extends Enum>`, riusata da più notifier enum-based per persistere lo stato by-name (robusto a riordini futuri dell'enum). |
| `settings/backup_provider.dart` | `backupSettingsProvider` (`BackupSettingsNotifier`), `backupStatusProvider` (`BackupStatusNotifier`), `availableBackupsProvider` (`FutureProvider`) | Frequenza/abilitazione backup automatico + stato UI dell'ultima operazione di backup. |

---

## 5. Schermate (`lib/screens/`)

### Schermate complesse (una sottocartella ciascuna, orchestratore + widget figli)

- **`calendar/`** — `calendar_screen.dart` (`CalendarWorkspaceView`) possiede `_focusedDay`/`_focusedMonth`/`_currentView` e delega il rendering a: `calendar_day_view.dart`, `calendar_multi_day_view.dart` (Settimana/7 giorni), `calendar_month_view.dart`, `calendar_year_view.dart`, `calendar_schedule_view.dart` (Programma, look-ahead 90 giorni), `calendar_search_results_view.dart`. Tile evento condivisa in `calendar_event_tile.dart` (`CalendarEventListTile`), bottom sheet eventi-del-giorno in `calendar_day_events_sheet.dart`. Editor evento in `calendar_event_editor_screen.dart`.
- **`note_editor/`** — `note_editor_screen.dart` possiede i `TextEditingController`/`FocusNode`, lo stato di sola-UI (`_isApplyingUndoRedo`, `_markdownMode`, `_lastTitle`/`_lastContent`) e tutta la UI con `BuildContext` (dialog, bottom sheet, picker, snackbar); delega stato-nota e persistenza a `note_editor_controller.dart` (`NoteEditorController extends ChangeNotifier`, istanziato in `initState` e osservato via `addListener`), che possiede `NoteModel _note`/`_isNew`/`_isSaving`/`_softDeleted` ed esporta `save`, `updateNote`, `scheduleReminderNotification`/`cancelReminderNotification`, `performUndo`/`performRedo`, `addAudioNote`/`removeAudioNote`, `delete`. La UI delega il rendering a `note_editor_app_bar.dart`, `note_editor_bottom_bar.dart`, `note_linked_notes_section.dart`, `note_audio_notes_section.dart`, `note_audio_player_tile.dart`, `note_audio_recorder_sheet.dart`, `note_checklist_editor.dart`, `note_link_sheet.dart`. Il banner promemoria (`ReminderBanner`) è condiviso con `task_editor/` tramite `lib/widgets/reminder_banner.dart`.
- **`task_editor/`** — `task_editor_screen.dart`, stesso schema: `task_editor_app_bar.dart`, `task_editor_bottom_bar.dart`, `task_info_section.dart` (data scadenza/ricorrenza/elenco), `task_subtasks_section.dart`.
- **`settings/`** — `settings_screen.dart` possiede solo la logica di export/import/clear (JSON, ICS, backup completo) che opera su più provider contemporaneamente; ogni sezione della UI è un widget dedicato (`settings_appearance_section.dart`, `settings_notes_prefs_section.dart`, `settings_tasks_prefs_section.dart`, `settings_backup_section.dart`, `settings_notes_data_section.dart`, `settings_tasks_data_section.dart`, `settings_calendar_data_section.dart`, `settings_global_backup_section.dart`, `settings_misc_sections.dart`), più `settings_backup_sheets.dart` per le bottom sheet di frequenza/storico backup.
- **`statistics/`** — `statistics_screen.dart` con provider locale `statisticsSummaryProvider` che aggrega note/task/eventi; componenti grafici in `statistics_widgets.dart` (`fl_chart`).
- **`home/`** — non una sottocartella di editor ma di helper per `home_screen.dart`: `home_layout_utils.dart` (breakpoint colonne griglia), `reorderable_grid_view.dart`/`reorderable_list_view.dart` (drag&drop `NoteCard`), `speed_dial_fab.dart` (FAB espandibile crea nota/checklist/task/audio/da-template; da aperto, i bottoni e lo scrim vivono in un `OverlayEntry` ancorato alla posizione del FAB via `GlobalKey`/`RenderBox`, per intercettare il tap fuori senza bloccare i bottoni stessi).
- **`web/`** — `favicon.png` e `icons/Icon-{192,512}.png`/`Icon-maskable-{192,512}.png` sono generati da `assets/images/app_logo_icon.png` (prima erano i placeholder di default generati da `flutter create`); rigenerarli con lo stesso script se il logo cambia, non c'è un tool di build dedicato (niente `flutter_launcher_icons` in `pubspec.yaml`).
- **`auth/`** — `login_screen.dart`: tab Accedi/Registrati, email+password, reset password, Google Sign-In (`authNotifierProvider`).

### Schermate singolo-file

| File | Scopo | Provider principali |
|---|---|---|
| `home_screen.dart` | Home/root, lista o griglia note, auto-backup silenzioso su `initState` | `homeLayoutProvider`, `filteredNotesProvider`, `sortOrderProvider`, `backupSettingsProvider` |
| `tasks_screen.dart` | Tab dinamici (Tutte, Speciali, +1 per `TaskListModel`), quick-add, gestione elenchi | `tasksProvider`, `taskListsProvider`, `filteredTasksProvider`, `specialTasksProvider`, `taskListTasksProvider` |
| `trash_screen.dart` | Cestino unificato (3 tab Note/Task/Eventi), svuota cestino | `trashedNotesProvider`/`trashedTasksProvider`/`trashedEventsProvider` |
| `archive_screen.dart` | Archivio (3 tab) | `archivedNotesProvider`/`archivedTasksProvider`/`archivedEventsProvider` |
| `labels_screen.dart` | Gestione etichette globali (crea/rinomina/elimina) | `allTagsProvider`, `customLabelsProvider` |
| `reminders_screen.dart` | Elenco unificato promemoria note+task, sezioni "In arrivo"/"Scaduti" | legge `reminder` da note/task attivi; rimozione cancella anche la notifica via `NotificationService` |
| `export_screen.dart` | Esporta note attive in PDF/TXT/JSON/CSV/HTML | `activeNotesProvider`, `downloadFile` (utils/downloader.dart) |
| `info_screen.dart` | Info app statica (versione da `appVersion`, changelog completo, licenze OSS) | nessuno |
| `boot_error_screen.dart` | `BootErrorApp`: `MaterialApp` autonoma mostrata se l'avvio fallisce, con pulsante Riprova (vedi §9) | nessuno |
| `note_template_screen.dart` | Bottom sheet scelta template nota | nessuno (usa `kNoteTemplates`) |

---

## 6. Widget condivisi (`lib/widgets/`)

- `nav_scaffold.dart` — Scaffold comune con drawer/AppBar per le schermate principali (`DrawerSection` enum).
- `app_drawer.dart` — `AppDrawer`, `AppRoutes` (costanti named routes), `navigateToSection` (Home fa `popUntil` root, le altre sezioni push/pushReplacement).
- `note_card.dart` — Card nota (home + archivio): rendering stile custom, preview checklist, menu rapido long-press (pin/archivia/blocca/cestina) con sblocco biometrico via `NoteLockService`.
- `reminder_banner.dart` — `ReminderBanner`, condiviso tra `note_editor` e `task_editor`.
- `changelog_dialog.dart` — `ChangelogDialog` + `showChangelogDialog(context, {entries})`: dialog "Changelog" con titolo `vX.Y.Z` e bullet per versione. Aperto in automatico da `home_screen.dart` dopo un aggiornamento (solo le voci da `ChangelogService.pendingEntries`) e manualmente da `info_screen.dart` (storico completo).
- `sort_sheet.dart` — Bottom sheet di ordinamento condiviso note/task (`SortOrder`).
- `shared/search_field.dart` — Campo ricerca generico legato a uno `StateProvider<String>` passato come parametro.
- `shared/empty_state.dart` — `EmptyState`, placeholder icona+messaggio condiviso dalle liste vuote/errore di Home, Tasks e Archivio, con pulsante opzionale (`actionLabel`/`actionIcon`/`onAction`). Home: "Riprova" (`notesProvider.reload`) su errore di sincronizzazione, "Crea la prima nota" solo se non esistono note attive (se la lista è vuota per la ricerca non compare); Tasks: solo "Riprova", perché il campo di aggiunta rapida è già visibile.
- `shared/pull_to_refresh.dart` — `PullToRefresh`, `RefreshIndicator` che funziona anche con figli non scrollabili (empty/error state, avvolti in uno scroll sempre attivo a tutta altezza); con `childIsScrollable: true` il figlio deve usare `AlwaysScrollableScrollPhysics` (già impostata in `ReorderableGridView`/`ReorderableListViewWidget` e nella lista task), altrimenti una lista più corta dello schermo non si può tirare. Usato da Home (`notesProvider.reload`) e Tasks (`tasksProvider.reload` + `taskListsProvider.reload`).
- `shared/swipe_actions.dart` — `SwipeActions` (`Dismissible` con `SwipeAction` a destra/sinistra) + `DismissBackground` (riusato anche da `trash_screen.dart`). Con `removesItem: false` la riga torna al suo posto invece di essere rimossa (un `Dismissible` "dismissed" deve uscire dall'albero): serve per azioni dopo cui l'elemento resta in lista, come completare un task. Usato da `tasks_screen.dart` (destra completa/riapre, sinistra cestino) e da `screens/home/note_swipe_actions.dart` sulla Home in vista **lista** (destra archivia, sinistra cestino; non in griglia, dove il trascinamento riordina). Tutte le azioni passano da `notifyWithUndo`.
- `shared/error_feedback.dart` — `notifyOnError(future, context)`, wrapper per le chiamate fire-and-forget ai metodi di mutazione dei notifier (`NotesNotifier`/`TasksNotifier`/`CalendarNotifier`, che fanno rollback e `rethrow` su fallimento Firestore): mostra una snackbar d'errore se il `Future` fallisce, con guardia `context.mounted`.
  Contiene anche `notifyWithUndo(future, context, message:, onUndo:)`: SnackBar con azione **Annulla** per le mutazioni reversibili (sposta nel cestino → `restoreFromTrash`, archivia → `toggleArchive`), usata da `note_card.dart`, dagli editor di nota/task/evento e da `tasks_screen.dart`. Cattura lo `ScaffoldMessenger` subito, così funziona anche quando l'editor fa `pop` dopo l'eliminazione (lo SnackBar compare sulla schermata sotto); se la scrittura fallisce sostituisce lo SnackBar di annullamento con quello di errore. Gli editor non cancellano mai definitivamente: `deleteNote`/`deleteTask`/`deleteEvent` dei notifier (hard delete) non sono usati dalla UI, che passa sempre da `softDelete`; un elemento mai salvato (`_isNew`) non viene toccato.
- `style_editor/` — `color_picker_widget.dart` (`ColorPickerWidget`, palette da `AppColors.noteSwatchesLight/Dark`), `style_editor_sheet.dart` (editor font/dimensione/stile testo di una nota).

---

## 7. Servizi e utility (`lib/utils/`)

Servizi stateless o singleton, non legati a Riverpod (istanziati direttamente dove servono):

| File | Responsabilità |
|---|---|
| `audio_service.dart` | `AudioRecordingService` — registrazione (`record`), riproduzione (`just_audio`), gestione file audio. |
| `backup_service.dart` | `BackupService` — crea/estrae zip di backup (note+task+calendario in JSON), lista/elimina backup, retention 30 backup, traccia `last_backup_time`. |
| `ics_export_service.dart` | Genera stringa ICS (VCALENDAR/VEVENT) da `CalendarEventModel`, incluse ricorrenze. |
| `ics_import_service.dart` | Parser ICS manuale: unfolding righe, DTSTART/DTEND/RRULE/TZID, risoluzione UNTIL/COUNT, rilevamento compleanni da CATEGORIES. |
| `notification_service.dart` | Wrapper `flutter_local_notifications` + `timezone`: init, permessi Android, `scheduleNotification`/`cancelNotification`, ID deterministici (`idForNote`/`idForTask`/`idForEvent`). |
| `note_lock_service.dart` | Wrapper `local_auth` per lock biometrico delle note (no-op su web). |
| `recurrence.dart` | Enum `RecurrenceType` + helper di parsing/etichette, condiviso da task e calendario. |
| `widget_service.dart` | `WidgetService` — integrazione `home_widget` Android (aggiorna il widget home screen con conteggio note/task e ultima nota; no-op su web). `scheduleSync(notes, tasks)` — chiamato dai `ref.listen` in `main.dart` — fa debounce di 500 ms, trova l'ultima nota con una scansione singola e salta la scrittura se i valori non sono cambiati. |
| `downloader.dart` (+ `_io.dart`/`_web.dart`/`_stub.dart`) | Export condizionale per salvare/scaricare file cross-piattaforma (`path_provider` su mobile/desktop, Blob+AnchorElement su web). |
| `dialogs/move_to_list_dialog.dart` | `showMoveToListDialog` — dialog per spostare un task in un altro elenco. |
| `data_export_service.dart` | `DataExportService` — encoding/scrittura JSON (`exportJson`) e file-picking+decoding JSON (`pickAndDecodeJson`), scrittura ICS (`exportIcs`) e file-picking ICS (`pickIcsContent`); usato da `settings_screen.dart` per tenere fuori dal widget l'I/O e il parsing generico (il parsing modello-specifico e l'aggiornamento dei provider restano nella schermata). |
| `changelog_service.dart` | `ChangelogService.pendingEntries(prefs, currentVersion)` — confronta `appVersion` con `last_seen_changelog_version` su SharedPreferences: prima installazione → salva e non mostra nulla; stessa versione → nulla; altrimenti restituisce le voci più nuove di quella vista (tutto lo storico se la versione vista non è in elenco). |
| `app_bootstrap.dart` | `AppBootstrap` — handler globali degli errori (`installErrorHandlers`) e inizializzazione dei servizi all'avvio (`init`), distinguendo servizi obbligatori e opzionali (vedi §9). |

---

## 8. Tema e stile (`lib/theme/`)

- `app_colors.dart` — palette centrale (`white`, `dark`, `warmYellow`, `warmBrown`) + `noteSwatchesLight`/`noteSwatchesDark` (preset colore sfondo nota, 8 colori ciascuno) + `contrastRatio`/`contrastingTextColor` (calcolo del rapporto di contrasto WCAG per scegliere il colore testo nero/bianco più leggibile su uno sfondo arbitrario, usato da `note_card.dart` e `note_editor_screen.dart`).
- `app_font_sizes.dart` — scala dimensioni (xs 10 → display 28).
- `app_radius.dart` — scala raggi angoli (sm 8 → xl 20).
- `app_theme.dart` — `AppTheme.light`/`AppTheme.dark`: Material 3 via `ColorScheme.fromSeed(seedColor: warmBrown)` con override manuale dei colori principali; tipografia basata sul font "Exo 2"; styling comune per AppBar (flat), Drawer, NavigationRail, Card, FAB, Chip, Slider.

---

## 9. Inizializzazione app (`lib/main.dart`) e Firebase

Sequenza di avvio (logica in `utils/app_bootstrap.dart`, `main.dart` fa solo da orchestratore):
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AppBootstrap.installErrorHandlers()`: `PlatformDispatcher.onError` logga (solo debug) gli errori async non gestiti invece di far crashare l'app; in release `ErrorWidget.builder` sostituisce il riquadro grigio con un'icona neutra.
3. `AppBootstrap.init()`:
   - **obbligatori** (se falliscono l'avvio fallisce): `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` (saltato se già inizializzato, per il retry; `firebase_options.dart` è git-ignored come `google-services.json`: va generato in locale con `flutterfire configure`) e `SharedPreferences.getInstance()`;
   - **opzionali** (errore solo loggato, l'app parte comunque): `NotificationService.init()` + permessi, `WidgetService.init()`, `initializeDateFormatting('it')` + `Intl.defaultLocale = 'it'` (i `DateFormat` senza locale esplicito escono in italiano).
4. Successo → `runApp(ProviderScope(...))` con `sharedPreferencesProvider.overrideWithValue(prefs)`. Errore → `runApp(BootErrorApp(...))` (`screens/boot_error_screen.dart`): schermata "Impossibile avviare Noteep" con pulsante **Riprova** che rilancia l'intera sequenza (in debug mostra anche l'eccezione).

**Lingua**: `MaterialApp` ha `locale: Locale('it')` fisso, `supportedLocales` it/en e `GlobalMaterialLocalizations.delegates` (`flutter_localizations`), così i widget di sistema (date/time picker, menu di selezione testo, tooltip) sono in italiano come il resto dell'UI, che ha stringhe italiane hardcoded. Quando verrà introdotta la localizzazione completa (`.arb` + `gen-l10n`) il `locale` fisso andrà rimosso.

`NotesApp` (`ConsumerWidget`) legge `themeModeProvider` per il tema e `authStateProvider` per l'auth gate: `.when(loading: splash, error: LoginScreen, data: user != null ? HomeScreen : LoginScreen)`. Un `ref.listen` su note/task attivi tiene sincronizzato l'home widget Android. Le schermate principali (Tasks/Reminders/Calendar/Labels/Archive/Trash/Settings) hanno named route (vedi `AppRoutes` in `app_drawer.dart`); `NoteEditorScreen`/`TaskEditorScreen` si aprono invece con `Navigator.push` diretto (non hanno una route con nome, perché richiedono sempre un parametro `note`/`task`).

---

## 10. Testing (`test/`)

```bash
flutter test
```

- **`test/providers/notes_provider_test.dart`**, **`tasks_provider_test.dart`** — unit test dei notifier contro [`fake_cloud_firestore`](https://pub.dev/packages/fake_cloud_firestore) (dev dependency), istanziando `NotesNotifier`/`TasksNotifier`/`TaskListsNotifier` direttamente (bypassando `currentUserProvider`/Firebase Auth reale). Copertura: CRUD, ciclo cestino, tag, `reorderNotes`, dipendenza incrociata `taskListsProvider → tasksProvider.clearListReferences`, provider derivati/filtrati.
- **`test/screens/note_editor_screen_test.dart`**, **`task_editor_screen_test.dart`** — widget test che montano le due schermate editor dentro un `ProviderScope` con `notesProvider`/`tasksProvider` sovrascritti allo stesso pattern fake-Firestore. Nessun progetto Firebase reale necessario per eseguire la suite.
- **`test/utils/changelog_service_test.dart`** — unit test di `ChangelogService` con `SharedPreferences.setMockInitialValues` e una lista di voci fittizia (prima installazione, stessa versione, aggiornamento, versione sconosciuta).
- **`test/screens/boot_error_screen_test.dart`** — widget test di `BootErrorApp` (messaggio visibile, Riprova invoca il callback).
- **`test/widgets/empty_state_test.dart`** — widget test di `EmptyState` (pulsante mostrato solo con `actionLabel`, tap invoca `onAction`).
- **`test/widgets/swipe_actions_test.dart`** — widget test di `SwipeActions` (swipe a destra con `removesItem: false` lascia la riga, swipe a sinistra la rimuove).

Pattern riusabile per estendere la copertura ad altri provider/schermate: creare il notifier con `FakeFirebaseFirestore()`, oppure — per provider che dipendono da `sharedPreferencesProvider` (tutto `providers/settings/`) — usare `SharedPreferences.setMockInitialValues({})` e passare l'istanza via override nel `ProviderContainer`/`ProviderScope`.

---

## 11. Note di manutenzione

- **Migrazione provider non ancora fatta**: tutti i provider usano `StateNotifierProvider` (pattern Riverpod "legacy" ma pienamente supportato), non `Notifier`/`AsyncNotifier` con `@riverpod` code-gen. Se si deciderà di migrare (`Notifier` funziona anche con provider dichiarati a mano; per usare `@riverpod` vanno riaggiunte `riverpod_annotation`, `riverpod_generator` e `build_runner`), l'ordine a rischio crescente consigliato è: `audio_provider` → provider enum di `settings/ui_provider.dart` → `backupStatusProvider` → `calendarProvider` → `notesProvider` → `tasksProvider`+`taskListsProvider` (in coppia, per la dipendenza incrociata) → `authNotifierProvider` → i due provider undo/redo (`family`+`autoDispose`, i più delicati).
- **Piattaforme**: solo Android e Web. Le cartelle `ios/`, `macos/`, `linux/`, `windows/` sono state rimosse e `DefaultFirebaseOptions.currentPlatform` lancia `UnsupportedError` sulle altre piattaforme.
- **`sharedPreferencesProvider`** è dichiarato in `notes_provider.dart` per motivi storici, ma è cross-cutting (usato da ~7 provider di settings). Andrebbe idealmente spostato in un file dedicato tipo `core_providers.dart` in un futuro refactor.
- **Versione e changelog**: a ogni release aggiornare insieme `version:` in `pubspec.yaml` (`X.Y.Z+N`, con `N` sempre crescente: è il `versionCode` Android) e `appVersion`/`appBuildNumber` in `lib/core/constants/app_version.dart`, e aggiungere in testa a `changelogEntries` la voce della nuova versione.
- **Firma release Android**: `android/app/build.gradle` legge `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`; git-ignored insieme a `*.jks`) e firma la build release con `signingConfigs.release`. Se il file manca ricade sulla chiave di debug, così un clone pulito builda comunque; lo script locale `deploy_android.ps1` invece si ferma se `key.properties` non esiste. Lo SHA-1 del keystore release va registrato su Firebase (app Android) e nella restrizione della API key Android su Google Cloud.
- **Regole Firestore**: versionate in `firestore.rules` (con `firebase.json` + `.firebaserc`, progetto `noteep`). Ogni utente autenticato accede solo a `users/{uid}/**`, tutto il resto è negato. Deploy con `firebase deploy --only firestore:rules` (Firebase CLI) oppure copiando il file in Console → Firestore → Regole; se si aggiunge una collezione fuori da `users/{uid}/` va aggiunta anche una regola, altrimenti le letture/scritture vengono rifiutate.
