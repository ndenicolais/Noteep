# Documentazione Tecnica — Noteep

Documentazione tecnica dell'app per chi sviluppa/manutiene il codice. Per la descrizione delle funzionalità lato utente vedi `README.md`.

---

## 1. Panoramica architetturale

Noteep è un'app Flutter (note + task + calendario) con backend **Firebase** (Auth + Firestore) e state management **Riverpod** (`flutter_riverpod`, `Notifier`/`NotifierProvider` dichiarati a mano).

Principi chiave:
- **Un notifier per collezione dati** (`NotesNotifier`, `TasksNotifier`, `TaskListsNotifier`, `CalendarNotifier`), ciascuno legato a `users/{uid}/{collection}` su Firestore.
- **Optimistic update con rollback**: ogni notifier ha un helper privato `_mutate(apply, persist)` che aggiorna lo stato locale subito, poi tenta la scrittura su Firestore; se questa fallisce, lo stato torna a quello precedente e l'eccezione viene rilanciata.
- **Provider derivati** (`Provider` semplici, non notifier) per viste filtrate/ordinate: `activeNotesProvider`, `archivedNotesProvider`, `trashedNotesProvider`, `filteredNotesProvider`, e i loro equivalenti per task/eventi.
- **Cestino con auto-purge**: le entità non vengono mai cancellate direttamente da un'azione "elimina" nella UI, ma marcate con `deletedAt` (soft-delete); un job dentro `_load()` di ogni notifier elimina definitivamente ciò che è in cestino da più di 7 giorni.
- **Undo/redo per-entità**: `note_editor` e `task_editor` hanno ciascuno un provider `family` (`noteChangeHistoryProvider(noteId)` / `taskChangeHistoryProvider(taskId)`) che tiene uno stack di comandi (`NoteChange`/`TaskChange`, pattern Command) applicati/annullati tramite le classi statiche `NoteUndoRedoManager`/`TaskUndoRedoManager`.
- **Errore di caricamento distinto da "vuoto"**: `_load()` di `NotesNotifier`/`TasksNotifier` è avvolto in un try/catch che scrive su `notesLoadErrorProvider`/`tasksLoadErrorProvider` (`ValueStateProvider<Object?>`, scritto dal notifier via `ref`); le liste (Home/Tasks/Archive) leggono questo provider per mostrare un messaggio di errore di sincronizzazione invece del generico empty-state quando il primo caricamento da Firestore fallisce.
- **Loading iniziale distinto da "vuoto"**: `notesLoadingProvider`/`tasksLoadingProvider` (`ValueStateProvider<bool>`, iniziano `true`) sono impostati a `false` in un blocco `finally` di `_load()` (`_onLoadDone`). Home/Tasks mostrano uno skeleton loader (`NotesSkeleton` / `ListSkeleton`) al posto dell'empty-state quando la lista è vuota ma il primo caricamento è ancora in corso.
- **Ricarica manuale (pull-to-refresh)**: `NotesNotifier`/`TasksNotifier`/`TaskListsNotifier` espongono `reload()`, che rilegge la collezione da Firestore e **sostituisce** lo stato (`_load(replace: true)`), a differenza del caricamento iniziale che fa merge. Serve a recuperare dopo un errore di sincronizzazione o a vedere modifiche fatte da un altro dispositivo; le scritture locali ancora in volo sono comunque incluse nei risultati di Firestore.

---

## 2. Struttura del progetto (`lib/`)

```
lib/
├── main.dart                  # bootstrap app, auth gate, collega AppRouter
├── firebase_options.dart      # config Firebase Android + Web (git-ignored)
├── core/constants/            # app_version.dart (versione, allineata a pubspec), changelog.dart (voci Changelog)
├── core/routing/              # app_router.dart: AppRoutes, AppRouter (onGenerateRoute/onUnknownRoute), AppNav; notification_target.dart + notification_launch_handler.dart (deep link dalle notifiche)
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
| `change_history.dart` | `NoteChange` (astratta) | Pattern Command: `NoteTitleChange`, `NoteTextChange` — ciascuna con `apply`/`undo`. Solo titolo e testo sono annullabili; le classi per stile, checklist e audio sono state rimosse perché mai usate. |
| `task_change_history.dart` | `TaskChange` (astratta) | Equivalente per task: `TaskTitleChange`, `TaskDescriptionChange` (le altre classi, mai usate, sono state rimosse). |
| `note_template.dart` | `NoteTemplate` + `kNoteTemplates` | 6 template predefiniti (riunione, diario, progetto, spesa, viaggio, brainstorming) usati da `note_template_screen.dart` |

`RecurrenceType` (`none`/`daily`/`weekly`/`monthly`/`yearly`) è definito in `utils/recurrence.dart` ed è condiviso tra `TaskModel` e `CalendarEventModel`.

---

## 4. Gestione dello stato — Provider Riverpod (`lib/providers/`)

**Nessun uso di code-gen** (`@riverpod`/`riverpod_generator`): tutti i provider sono dichiarati manualmente con `NotifierProvider`/`Provider`/`StreamProvider`/`FutureProvider`; nessun `StateNotifierProvider`/`StateProvider` legacy. I valori semplici impostati dall'esterno (ricerca, flag di loading/errore) usano `valueStateProvider<T>(iniziale)` di `core_providers.dart` (`ValueStateNotifier<T>` con `set(value)`, perché `state` di un `Notifier` è protetto). I notifier dati (`NotesNotifier`/`TasksNotifier`/`TaskListsNotifier`/`CalendarNotifier`) in `build()` guardano `currentUidProvider` e `firestoreProvider`, avviano `_load()` e restituiscono `[]`: al cambio utente la stessa istanza viene ricostruita e un fetch ancora in volo per l'utente precedente viene scartato (confronto dell'uid dopo l'`await`). Le dipendenze di code-gen (`riverpod_annotation`/`riverpod_generator`/`build_runner`) sono state rimosse perché inutilizzate (vedi §11).

### Grafo di dipendenza principale

```
authStateProvider (StreamProvider<User?>, da FirebaseAuth.authStateChanges)
  └── currentUserProvider (Provider<User?>)
        └── currentUidProvider (Provider<String>, '' se non loggato)
        ├── notesProvider
        ├── tasksProvider
        ├── taskListsProvider  ──(chiama esplicitamente)──> tasksProvider.notifier.clearListReferences()
        └── calendarProvider

firestoreProvider (FirebaseFirestore.instance) ── usato dai notifier dati

sharedPreferencesProvider (dichiarato in core_providers.dart, iniettato in main.dart)
  └── usato da: themeModeProvider, homeLayoutProvider, sortOrderProvider,
      taskSortOrderProvider, customLabelsProvider, showCompletedTasksProvider,
      groupTasksByPriorityProvider, backupSettingsProvider
```

### Granularità dei rebuild

Le liste principali osservano solo **quali** elementi mostrare e in che ordine, mentre ogni riga osserva il proprio elemento:
- `IdList` (`core_providers.dart`): lista di id immutabile con `==` per contenuto, così un `Provider<IdList>` notifica solo su aggiunte/rimozioni/riordini (Riverpod notifica quando `previous != next`).
- Home: `HomeScreen` guarda `filteredNoteIdsProvider` (id di `filteredNotesProvider`); `ReorderableGridView`/`ReorderableListViewWidget` ricevono `noteIds` e ogni cella è un `Consumer` su `noteByIdProvider(id)`. Il riordino legge `filteredNotesProvider` solo al momento del drop.
- Tasks: `TaskListView` fa `ref.watch(source.select(...))` restituendo un record `(active: IdList, completed: IdList)` (i record confrontano i campi per valore), le righe sono `_TaskRow` su `taskByIdProvider(id)`.
- `noteByIdProvider`/`taskByIdProvider` (`autoDispose.family`) fanno `select` su `notesByIdProvider`/`tasksByIdProvider` (mappa id→elemento ricalcolata una volta per mutazione): i notifier lasciano invariate le istanze degli elementi non toccati, quindi la select non notifica per loro.

Risultato: modificare il contenuto di una nota/task senza cambiarne posizione o appartenenza ai filtri ricostruisce solo la sua card. Con ordinamento per data di modifica, o se la modifica cambia l'esito della ricerca, cambiano anche gli id e la lista si ricostruisce come prima. Archivio, Cestino, Statistiche e Calendario guardano ancora le liste intere (schermate secondarie, meno modifiche puntuali).

### Provider per file

| File | Provider esportati | Note |
|---|---|---|
| `core_providers.dart` | `sharedPreferencesProvider`, `firestoreProvider`, `ValueStateNotifier<T>` + `valueStateProvider<T>()` / typedef `ValueStateProvider<T>` | Dipendenze trasversali: SharedPreferences (override in `main.dart`), istanza Firestore (override nei test con `FakeFirebaseFirestore`), sostituto `Notifier` dello `StateProvider`. |
| `notes_provider.dart` | `notesProvider` (`NotesNotifier`), `notesByIdProvider`, `noteByIdProvider(id)`, `notesLoadingProvider`, `notesLoadErrorProvider`, `activeNotesProvider`, `archivedNotesProvider`, `trashedNotesProvider` | CRUD note + tag (`renameTag`/`deleteTag`) + `reorderNotes`. |
| `tasks_provider.dart` | `tasksProvider` (`TasksNotifier`), `tasksByIdProvider`, `taskByIdProvider(id)`, `taskListsProvider` (`TaskListsNotifier`), `activeTasksProvider`, `specialTasksProvider`, `archivedTasksProvider`, `trashedTasksProvider`, `taskListTasksProvider(listId)` | `TaskListsNotifier` mantiene un `Ref` per invocare `tasksProvider.notifier.clearListReferences()` quando un elenco viene eliminato. |
| `calendar_provider.dart` | `calendarProvider` (`CalendarNotifier`), `activeEventsProvider`, `archivedEventsProvider`, `trashedEventsProvider`, `calendarSearchQueryProvider`, `filteredCalendarEventsProvider` | Stesso pattern CRUD + cestino di notes/tasks. |
| `sync_provider.dart` | `syncStatusProvider` (`SyncStatusNotifier`, stato `SyncStatus{queued, failures}`), mixin `FirestoreListMutations<T>` | **Scritture offline.** Il mixin è usato da `NotesNotifier`/`TasksNotifier`/`TaskListsNotifier`/`CalendarNotifier` e fornisce `mutate(apply, persist)` (optimistic update) e `commitInChunks(ops)` (batch da 500, committati insieme e non in sequenza: offline vengono accodati tutti subito). Con la persistenza attiva il future di una scrittura Firestore si completa solo all'ack del server, mai mentre si è offline: `mutate` aspetta al massimo `writeGrace` (3 s); un errore entro la finestra fa rollback + `rethrow` come prima, oltre la finestra la scrittura passa a `SyncStatusNotifier.track` (contatore `queued`) e il chiamante prosegue (niente spinner di salvataggio bloccati). Se il server la rifiuta più tardi Firestore ripristina la propria cache, `failures` cresce e il notifier chiama `reload()`. Anche la pulizia del cestino (>7 giorni) passa da `mutate` e al caricamento non è più attesa, così offline non blocca il flag di loading. |
| `auth_provider.dart` | `firebaseAuthProvider`, `authStateProvider`, `currentUserProvider`, `currentUidProvider`, `authNotifierProvider` (`AuthNotifier`, stato `AsyncValue<void>`) | Google Sign-In, email/password, reset password, sign-out. `authErrorMessage(FirebaseAuthException)` mappa i codici errore Firebase in messaggi italiani. |
| `audio_provider.dart` | `recordingStateProvider` (`RecordingStateNotifier`) | Stato registrazione audio (`isRecording`, `currentDuration`, `errorMessage`, `lastRecordedNote`), isolato dagli altri notifier. |
| `notes_undo_redo_provider.dart` | `noteChangeHistoryProvider` (family, autoDispose) | Stack undo/redo per nota; consumato tramite `NoteUndoRedoManager` (classe statica) da `note_editor_screen.dart`. |
| `tasks_undo_redo_provider.dart` | `taskChangeHistoryProvider` (family, autoDispose) | Equivalente per task, `TaskUndoRedoManager`. |
| `settings/theme_provider.dart` | `themeModeProvider` (`ThemeModeNotifier`) | Estende `PersistedEnumNotifier`, persiste su SharedPreferences by-name. |
| `settings/ui_provider.dart` | `filteredNoteIdsProvider`, `homeLayoutProvider`, `sortOrderProvider`, `taskSortOrderProvider`, `customLabelsProvider`, `showCompletedTasksProvider`, `groupTasksByPriorityProvider`, `searchQueryProvider`, `taskSearchQueryProvider`, `filteredNotesProvider`, `filteredTasksProvider`, `allTagsProvider` | Contiene anche la classe base `PersistedEnumNotifier<T extends Enum>`, riusata da più notifier enum-based per persistere lo stato by-name (robusto a riordini futuri dell'enum). |
| `settings/backup_provider.dart` | `backupSettingsProvider` (`BackupSettingsNotifier`), `backupStatusProvider` (`BackupStatusNotifier`), `availableBackupsProvider` (`FutureProvider`) | Frequenza/abilitazione backup automatico + stato UI dell'ultima operazione di backup. |
| `settings/backup_restore.dart` | `backupRestorerProvider` (`BackupRestorer`), classe `FullBackupData` | `FullBackupData.fromJson` (layout piatto del backup `.json`) e `.fromZipContents` (layout annidato restituito da `BackupService.restoreBackup`) parsano tutte le sezioni prima di toccare i provider; `BackupRestorer.apply` chiama `replaceAll` su note/task/liste/calendario (sezioni assenti invariate; `replaceAll` di ogni notifier cancella anche da Firestore i documenti non presenti nella nuova lista, altrimenti ricomparirebbero al caricamento successivo), `readZip(path)` legge un backup automatico senza applicarlo. Usato dall'import `.json` completo e dal ripristino dei backup automatici. |
| `settings/data_actions.dart` | `dataActionsProvider` (`DataActions`) | Logica dati della schermata Impostazioni: payload di export JSON (note, task+liste, calendario, backup completo con `appVersion`), `hasLockedNotes`, import JSON per sezione (legge solo le chiavi della sezione, parsing sincrono via `FullBackupData` che lancia prima di toccare i provider, poi `BackupRestorer.apply`), `icsExport`/`importIcs` (restituisce `(count, saved)`), `clearNotes`/`clearTasks`/`clearCalendar`/`clearAll`. Gli import e i clear aggiornano subito lo stato e restituiscono il future di persistenza. |

---

## 5. Schermate (`lib/screens/`)

### Schermate complesse (una sottocartella ciascuna, orchestratore + widget figli)

- **`calendar/`** — `calendar_screen.dart` (`CalendarWorkspaceView`) possiede `_focusedDay`/`_focusedMonth`/`_currentView` e delega il rendering a: `calendar_day_view.dart`, `calendar_multi_day_view.dart` (Settimana/7 giorni), `calendar_month_view.dart`, `calendar_year_view.dart`, `calendar_schedule_view.dart` (Programma, look-ahead 90 giorni), `calendar_search_results_view.dart`. Tile evento condivisa in `calendar_event_tile.dart` (`CalendarEventListTile`), bottom sheet eventi-del-giorno in `calendar_day_events_sheet.dart`. Editor evento in `calendar_event_editor_screen.dart`.
- **`note_editor/`** — `note_editor_screen.dart` possiede i `TextEditingController`/`FocusNode`, lo stato di sola-UI (`_isApplyingUndoRedo`, `_markdownMode`, `_lastTitle`/`_lastContent`) e tutta la UI con `BuildContext` (dialog, bottom sheet, picker, snackbar); delega stato-nota e persistenza a `note_editor_controller.dart` (`NoteEditorController extends ChangeNotifier`, istanziato in `initState` e osservato via `addListener`), che possiede `NoteModel _note`/`_isNew`/`_isSaving`/`_softDeleted` ed esporta `save`, `updateNote`, `scheduleReminderNotification`/`cancelReminderNotification`, `performUndo`/`performRedo`, `addAudioNote`/`removeAudioNote`, `delete`. La UI delega il rendering a `note_editor_app_bar.dart`, `note_editor_bottom_bar.dart`, `note_linked_notes_section.dart`, `note_audio_notes_section.dart`, `note_audio_player_tile.dart`, `note_audio_recorder_sheet.dart`, `note_checklist_editor.dart`, `note_link_sheet.dart`. Il banner promemoria (`ReminderBanner`) è condiviso con `task_editor/` tramite `lib/widgets/reminder_banner.dart`.
- **`calendar/` — editor eventi** — `calendar_event_editor_screen.dart` (stato evento, controller, salvataggio su pop, picker data/ora e promemoria) + `calendar_event_editor_bars.dart` (`CalendarEventEditorAppBar` pin/archivia, `CalendarEventEditorBottomBar` elimina/promemoria/chiudi), `calendar_event_details_section.dart` (`CalendarEventDetailsSection`: data/ora, tutto il giorno, compleanno, onomastico, ricorrenza; le modifiche risalgono con `onChanged(evento)`); il banner promemoria è il `ReminderBanner` condiviso.
- **`task_editor/`** — `task_editor_screen.dart`, stesso schema: `task_editor_app_bar.dart`, `task_editor_bottom_bar.dart`, `task_info_section.dart` (data scadenza/ricorrenza/elenco), `task_subtasks_section.dart`.
- **`settings/`** — `settings_screen.dart` gestisce solo i flussi UI di export/import/clear (dialoghi di conferma, avviso note protette, file picker, SnackBar, errori di persistenza via `notifyOnError`) e delega i dati a `DataActions` (`providers/settings/data_actions.dart`); ogni sezione della UI è un widget dedicato (`settings_appearance_section.dart`, `settings_notes_prefs_section.dart`, `settings_tasks_prefs_section.dart`, `settings_backup_section.dart`, `settings_notes_data_section.dart`, `settings_tasks_data_section.dart`, `settings_calendar_data_section.dart`, `settings_global_backup_section.dart`, `settings_misc_sections.dart`), più `settings_backup_sheets.dart` per le bottom sheet di frequenza/storico backup (dallo storico: tocco o menu "Ripristina" → conferma → `BackupRestorer.readZip` + `apply`, errori di scrittura via `notifyOnError`; menu "Elimina").
- **`statistics/`** — `statistics_screen.dart` con provider locale `statisticsSummaryProvider` che aggrega note/task/eventi; componenti grafici in `statistics_widgets.dart` (`fl_chart`).
- **`home/`** — non una sottocartella di editor ma di helper per `home_screen.dart`: `home_layout_utils.dart` (breakpoint colonne griglia `gridColumns` + `masonryColumnLength`), `reorderable_grid_view.dart` (griglia **masonry**: `SliverCrossAxisGroup` con una `SliverList` lazy per colonna, card ad altezza naturale senza `maxHeight`; la nota i va nella colonna i % cols, così l'ordine di lettura e gli indici globali del drag&drop `Draggable`/`DragTarget` restano quelli della lista) e `reorderable_list_view.dart` (drag&drop `NoteCard` in vista lista), `notes_skeleton.dart` (`NotesSkeleton`: card grigie con stesse spaziature e numero di colonne della griglia/lista reale, mostrate al primo caricamento), `speed_dial_fab.dart` (FAB espandibile crea nota/checklist/task/audio/da-template; da aperto, i bottoni e lo scrim vivono in un `OverlayEntry` ancorato alla posizione del FAB via `GlobalKey`/`RenderBox`, per intercettare il tap fuori senza bloccare i bottoni stessi).
- **Icona app** — sorgenti vettoriali in `design/app-icon/` (`icon.svg` icona completa con sfondo `#3D3F4D`, `foreground.svg` solo lampadina su trasparente, `playstore_512.png` per la scheda Play Store; non inclusi nel bundle). Android: icona adattiva `mipmap-anydpi-v26/ic_launcher.xml` (background `@color/ic_launcher_background` in `values/colors.xml`, foreground `ic_launcher_foreground.png` 108dp, `ic_launcher_monochrome.png` per le icone a tema di Android 13+) + `ic_launcher.png` 48dp legacy in ogni `mipmap-*dpi`. Web: `favicon.png` (32px) e `icons/Icon-{192,512}.png`/`Icon-maskable-{192,512}.png` dall'icona completa (il simbolo sta nell'80% centrale, quindi va bene anche come maskable); `manifest.json` usa `#3D3F4D` come `theme_color`/`background_color`. Il logo in app `assets/images/app_logo_icon.png` (AppBar di `nav_scaffold.dart`; altrove tramite `widgets/shared/app_logo.dart` → `AppLogo({size})`, il logo su riquadro arrotondato `AppColors.dark` come l'icona del launcher, usato in `LoginHeader`, `_SplashScreen` di `main.dart` e `info_screen.dart` header + pagina licenze) è il foreground ritagliato. Non c'è un tool di build dedicato (niente `flutter_launcher_icons`): se l'icona cambia, riesportare a mano tutte le densità dai sorgenti.
- **`auth/`** — `login_screen.dart` (orchestratore: controller, form key, azioni su `authNotifierProvider`, SnackBar errori/reset) + `login_forms.dart` (`LoginForm`, `RegisterForm`; campi email/password e pulsante di invio condivisi, toggle visibilità password con tooltip), `login_widgets.dart` (`LoginHeader`, `LoginTabBar`, `OrDivider`, `GoogleSignInButton`), `reset_password_dialog.dart` (`showResetPasswordDialog` → email o `null`; l'invio lo fa lo screen), `login_validators.dart` (`validateEmail`/`validatePassword`/`validatePasswordConfirmation`, funzioni pure).
- **`tasks/`** — `tasks_screen.dart` (`TasksScreen`: `DefaultTabController` con tab Tutte/Speciali/+1 per `TaskListModel`, azioni AppBar, FAB nuovo task via `showAppTextInputDialog`; il task nasce nell'elenco/speciali del tab corrente) + `task_list_view.dart` (`TaskListView`: un tab, con skeleton, empty/error, pull-to-refresh), `task_item.dart` (`TaskItem`: riga con swipe, stella, menu modifica/sposta/elimina), `task_sorting.dart` (`sortTasksForDisplay(tasks, sort)` → `(active:, completed:)`, funzione pura). Provider: `tasksProvider`, `taskListsProvider`, `filteredTasksProvider`, `specialTasksProvider`, `taskListTasksProvider`, `taskSortOrderProvider`.

### Schermate singolo-file

| File | Scopo | Provider principali |
|---|---|---|
| `home_screen.dart` | Home/root, lista o griglia note, auto-backup silenzioso su `initState` | `homeLayoutProvider`, `filteredNotesProvider`, `sortOrderProvider`, `backupSettingsProvider` |
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
- `app_drawer.dart` — `AppDrawer`, `navigateToSection` (Home fa `popUntil` root, le altre sezioni push/pushReplacement).
- `note_card.dart` — Card nota (home + archivio): rendering stile custom, preview checklist, menu rapido long-press (pin/archivia/blocca/cestina) con sblocco biometrico via `NoteLockService`. **Accessibilità**: `MergeSemantics` → un solo nodo per card (testo completo + tap "Apri nota"), le voci del menu rapido sono anche `customSemanticsActions` (menu "Azioni" di TalkBack, eseguite da `_runAction`, lo stesso codice del menu); `extraSemanticsActions` permette al contenitore di aggiungerne altre (la griglia Home aggiunge "Sposta prima/dopo" come alternativa al drag&drop, con gli stessi indici di `onReorder`).
- `sync_status_listener.dart` — `SyncStatusListener`, banner "modifiche non sincronizzate" + SnackBar di rifiuto, montato in `MaterialApp.builder` (vedi §9).
- `reminder_banner.dart` — `ReminderBanner`, condiviso tra `note_editor` e `task_editor`.
- `changelog_dialog.dart` — `ChangelogDialog` + `showChangelogDialog(context, {entries})`: dialog "Changelog" con titolo `vX.Y.Z` e bullet per versione. Aperto in automatico da `home_screen.dart` dopo un aggiornamento (solo le voci da `ChangelogService.pendingEntries`) e manualmente da `info_screen.dart` (storico completo).
- `sort_sheet.dart` — Bottom sheet di ordinamento condiviso note/task (`SortOrder`).
- `shared/app_dialogs.dart` — `showAppTextInputDialog(context, title:, hintText:, confirmLabel:)` → testo trimmato o `null` (annulla/vuoto), usato per nuovo task e nuovo elenco. `showAppSheet(context, builder:, isScrollControlled:, backgroundColor:)`: wrapper di `showModalBottomSheet` usato da tutti gli sheet dell'app; avvolge il contenuto in `SafeArea(top: false)` perché con l'edge-to-edge (obbligatorio da Android 15) lo sheet arriva fino al bordo e il contenuto finirebbe sotto la barra di navigazione. `showAppConfirmDialog(context, title:, message:, confirmLabel:, destructive:)`: dialogo di conferma condiviso (Annulla + conferma), risolve `true` solo sul tasto di conferma; con `destructive: true` il tasto è un `FilledButton` con i colori `error`/`onError` del tema. Usato per eliminazioni (nota/task/evento dall'editor, etichetta, elenco, cestino) e per conferme di import/export/ripristino in Impostazioni.
- `shared/skeleton.dart` — primitive per gli skeleton loader: `SkeletonPulse` (pulsazione di opacità condivisa da tutto il sottoalbero, un solo nodo semantico "Caricamento…", ferma con `MediaQuery.disableAnimations`), `SkeletonBox` (blocco arrotondato in `surfaceContainerHighest`) e `ListSkeleton` (righe cerchio + barra, usato dalla lista Tasks al primo caricamento).
- `shared/note_hero.dart` — `NoteHero` + `NoteHeroTag`: "container transform" leggero tra `NoteCard` (`isPage: false`) e `NoteEditorScreen` (`isPage: true`, avvolge lo `Scaffold`). Lo shuttle è un rettangolo che sfuma dal colore della card a quello dell'editor e perde gli angoli arrotondati, con il contenuto dell'editor in dissolvenza (impaginato alla dimensione finale in un `OverflowBox` e ritagliato, così l'editor non viene ri-layoutato a dimensioni intermedie). Il tag confronta solo l'id della nota; il colore di ciascun lato viaggia nel tag. Disattivato con animazioni ridotte (`HeroMode`). Note nuove (senza card) e note che spariscono dalla Home (es. archiviate dall'editor) semplicemente non volano.
- `shared/fade_switcher.dart` — `FadeSwitcher`: `AnimatedSwitcher` (250 ms, istantaneo con animazioni ridotte) con figli a riempimento pieno; anima solo quando cambia la `Key` del figlio. Ogni figlio è avvolto in un `HeroMode` con la sua chiave (disattivato per quelli uscenti, così le card griglia/lista con lo stesso tag Hero non si scontrano) e la struttura uniforme fa sì che il figlio che diventa uscente mantenga il suo stato, ad esempio la posizione di scroll. Home e Tasks lo usano per il passaggio caricamento → lista → vuoto/errore (le chiavi identificano lo stato, non i dati, così le modifiche alla lista non ri-animano).
- `shared/search_field.dart` — Campo ricerca generico legato a un `ValueStateProvider<String>` passato come parametro. Alto 40 dentro la AppBar: la scala del testo è limitata a 1.5× (`MediaQuery.withClampedTextScaling`) per non tagliare il testo; stesso trattamento per `CalendarSearchBar`.
- **Design system** (`shared/`, componenti da usare invece di riscrivere lo stesso widget in ogni screen):
  - `shared/section_header.dart` — `SectionHeader(title, {icon, muted, padding})`: titolo di un gruppo di righe in `labelLarge` w600 colore primary (`muted`: outline), icona opzionale, annunciato come header da TalkBack. `SectionHeader.listPadding` (default, sopra tile a tutta larghezza: sezioni di Impostazioni) e `SectionHeader.inlinePadding` (dentro colonne già paddate: Promemoria, Modelli, "Completati" in Tasks); Info usa `EdgeInsets.zero`. Sostituisce `SettingsSectionHeader` e i `_SectionHeader` privati di Info/Promemoria. Le intestazioni grandi di Statistiche (`titleLarge`) restano un ruolo a parte.
  - `shared/action_tile.dart` — `ActionTile(icon, title, subtitle, onTap, {destructive, trailing})`: riga che apre una schermata o esegue un'azione (icona primary + chevron); `destructive` colora icona e titolo con `error`. Usata da tutte le sezioni di Impostazioni.
  - `shared/item_card.dart` — `ItemCard` (Card del tema + `ListTile`, margine zero) e `ItemCardList` (lista con padding `md` e separatore `sm`): righe di task/eventi in Archivio e Cestino (`_TrashRow` con "Ripristina"), note nel Cestino, card di Promemoria.
  - `shared/tag_chip.dart` — `TagChip(label, {dense})`: chip non interattivo in `secondaryContainer` senza bordo; `dense` per le etichette sulle `NoteCard`, normale per le tecnologie in Info.
  - `shared/app_dialogs.dart` — vedi sotto; aggiunti `initialValue`/`textCapitalization` a `showAppTextInputDialog` (rinomina etichetta) e `showAppMessageDialog` (titolo + messaggio + OK, es. Google Drive). I dialog di conferma di Impostazioni ("Cancella …") e quelli di Etichette ora passano da qui: conferme distruttive sempre come `FilledButton` error.
- `shared/app_logo.dart` — `AppLogo({size = 84})`, logo dell'app (`assets/images/app_logo_icon.png`) su riquadro arrotondato `AppColors.dark`, coerente con l'icona del launcher; usato da login, splash e Info.
- `shared/empty_state.dart` — `EmptyState`, placeholder icona+messaggio condiviso dalle liste vuote/errore di Home, Tasks e Archivio, con pulsante opzionale (`actionLabel`/`actionIcon`/`onAction`). Home: "Riprova" (`notesProvider.reload`) su errore di sincronizzazione, "Crea la prima nota" solo se non esistono note attive (se la lista è vuota per la ricerca non compare); Tasks: solo "Riprova", perché il campo di aggiunta rapida è già visibile.
- `shared/pull_to_refresh.dart` — `PullToRefresh`, `RefreshIndicator` che funziona anche con figli non scrollabili (empty/error state, avvolti in uno scroll sempre attivo a tutta altezza); con `childIsScrollable: true` il figlio deve usare `AlwaysScrollableScrollPhysics` (già impostata in `ReorderableGridView`/`ReorderableListViewWidget` e nella lista task), altrimenti una lista più corta dello schermo non si può tirare. Usato da Home (`notesProvider.reload`) e Tasks (`tasksProvider.reload` + `taskListsProvider.reload`).
- `shared/swipe_actions.dart` — `SwipeActions` (`Dismissible` con `SwipeAction` a destra/sinistra) + `DismissBackground` (riusato anche da `trash_screen.dart`). Con `removesItem: false` la riga torna al suo posto invece di essere rimossa (un `Dismissible` "dismissed" deve uscire dall'albero): serve per azioni dopo cui l'elemento resta in lista, come completare un task. Usato da `tasks_screen.dart` (destra completa/riapre, sinistra cestino) e da `screens/home/note_swipe_actions.dart` sulla Home in vista **lista** (destra archivia, sinistra cestino; non in griglia, dove il trascinamento riordina). Tutte le azioni passano da `notifyWithUndo`.
- `shared/error_feedback.dart` — `notifyOnError(future, context)`, wrapper per le chiamate fire-and-forget ai metodi di mutazione dei notifier (`NotesNotifier`/`TasksNotifier`/`CalendarNotifier`, che fanno rollback e `rethrow` su fallimento Firestore): mostra una snackbar d'errore se il `Future` fallisce, con guardia `context.mounted`.
  Contiene anche `notifyWithUndo(future, context, message:, onUndo:)`: SnackBar con azione **Annulla** per le mutazioni reversibili (sposta nel cestino → `restoreFromTrash`, archivia → `toggleArchive`), usata da `note_card.dart`, dagli editor di nota/task/evento e da `tasks_screen.dart`. Cattura lo `ScaffoldMessenger` subito, così funziona anche quando l'editor fa `pop` dopo l'eliminazione (lo SnackBar compare sulla schermata sotto); se la scrittura fallisce sostituisce lo SnackBar di annullamento con quello di errore. Gli editor non cancellano mai definitivamente: `deleteNote`/`deleteTask`/`deleteEvent` dei notifier (hard delete) non sono usati dalla UI, che passa sempre da `softDelete`; un elemento mai salvato (`_isNew`) non viene toccato.
- `style_editor/` — `color_picker_widget.dart` (`ColorPickerWidget`, palette da `AppColors.noteSwatchesLight/Dark`), `style_editor_sheet.dart` (editor font/dimensione/stile testo di una nota), `font_family_picker.dart` (`FontFamilyPicker` + `kNoteFonts`, striscia orizzontale di chip condivisa da titolo e contenuto: `ScrollController` proprio per lo `Scrollbar` sempre visibile — senza, lo `Scrollbar` usava il `PrimaryScrollController` di un'altra lista — e altezza che cresce con la dimensione del testo di sistema).

---

## 7. Servizi e utility (`lib/utils/`)

Servizi stateless o singleton, non legati a Riverpod (istanziati direttamente dove servono):

| File | Responsabilità |
|---|---|
| `audio_service.dart` | `AudioRecordingService` — registrazione (`record`), riproduzione (`just_audio`), gestione file audio. |
| `backup_service.dart` | `BackupService` — crea/estrae zip di backup (note+task+calendario in JSON), lista/elimina backup, retention 30 backup, traccia `last_backup_time`; `metadata.json` riporta `appVersion`. `restoreBackup` attende `extractArchiveToDisk` (asincrona) prima di leggere i JSON. Il ripristino dall'app passa da `BackupRestorer.readZip` (vedi `settings/backup_restore.dart`). |
| `ics_export_service.dart` | Genera stringa ICS (VCALENDAR/VEVENT) da `CalendarEventModel`, incluse ricorrenze; una data di fine ricorrenza diventa `UNTIL=` (data per gli eventi tutto il giorno, fine della giornata locale in UTC per quelli con orario). |
| `ics_import_service.dart` | Parser ICS manuale: unfolding righe, DTSTART/DTEND/RRULE/TZID, risoluzione UNTIL/COUNT, rilevamento compleanni da CATEGORIES. `COUNT=` giornaliero/settimanale è calcolato in giorni di calendario (non `Duration`, che sbaglierebbe di un giorno a cavallo del cambio d'ora); gli orari con `TZID` diventano `DateTime` locali normali (non `TZDateTime`); l'unescape è a passata singola, così `\\n` resta una barra seguita da n. |
| `notification_service.dart` | Wrapper `flutter_local_notifications` + `timezone`: init, permessi Android, `scheduleNotification`/`cancelNotification`, ID deterministici (`idForNote`/`idForTask`/`idForEvent`). Ogni notifica porta un payload `NotificationTarget` (`"note:<id>"`, `"task:<id>"`, `"event:<id>"`, obbligatorio in `scheduleNotification`); il tap (`onDidReceiveNotificationResponse` ad app aperta, `getNotificationAppLaunchDetails` ad app chiusa) lo pubblica in `pendingTarget` (`ValueNotifier`). |
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
- `app_font_sizes.dart` — scala dimensioni (xs 10, sm 12, md 14, lg 16, xl 18, xxl 22, headline 24, display 28).
- `app_radius.dart` — scala raggi angoli (sm 8 → xl 20).
- `app_spacing.dart` — scala spaziature per `EdgeInsets`/`SizedBox` (xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32). I valori fuori scala (6, 10, 14, 20, 28…) restano letterali finché non vengono riallineati.
- `app_theme.dart` — `AppTheme.light`/`AppTheme.dark`: Material 3 via `ColorScheme.fromSeed(seedColor: warmBrown)` con override manuale dei colori principali; tipografia: `TextTheme` completo in `_textTheme` (font "Exo 2", ruoli headline/title/body/label agganciati ad `AppFontSizes`, title in `w600`; display e headlineLarge restano ai default M3) — negli screen preferire `Theme.of(context).textTheme.*` ai `fontSize` letterali, e dove serve una dimensione esplicita usare `AppFontSizes`; styling comune per AppBar (flat), Drawer, NavigationRail, Card, FAB, Chip, Slider; `dialogTheme` e `bottomSheetTheme` con raggio `AppRadius.xl`, così i singoli `showDialog`/`showModalBottomSheet` non ridichiarano la `shape`.

---

## 9. Inizializzazione app (`lib/main.dart`) e Firebase

Sequenza di avvio (logica in `utils/app_bootstrap.dart`, `main.dart` fa solo da orchestratore):
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AppBootstrap.installErrorHandlers()`: `PlatformDispatcher.onError` logga (solo debug) gli errori async non gestiti invece di far crashare l'app; in release `ErrorWidget.builder` sostituisce il riquadro grigio con un'icona neutra.
3. `AppBootstrap.init()`:
   - **obbligatori** (se falliscono l'avvio fallisce): `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` (saltato se già inizializzato, per il retry; `firebase_options.dart` è git-ignored come `google-services.json`: va generato in locale con `flutterfire configure`) e `SharedPreferences.getInstance()`;
   - subito dopo `initializeApp`, `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)`: su Android la persistenza è già il default, sul web no; con l'impostazione esplicita su entrambe le piattaforme le scritture offline restano in cache e le letture (`get()`, sorgente server-poi-cache) ricadono sulla cache;
   - **opzionali** (errore solo loggato, l'app parte comunque): `NotificationService.init()` + permessi, `WidgetService.init()`, `initializeDateFormatting('it')` + `Intl.defaultLocale = 'it'` (i `DateFormat` senza locale esplicito escono in italiano).
4. Successo → `runApp(ProviderScope(...))` con `sharedPreferencesProvider.overrideWithValue(prefs)`. Errore → `runApp(BootErrorApp(...))` (`screens/boot_error_screen.dart`): schermata "Impossibile avviare Noteep" con pulsante **Riprova** che rilancia l'intera sequenza (in debug mostra anche l'eccezione).

**Lingua**: `MaterialApp` ha `locale: Locale('it')` fisso, `supportedLocales` it/en e `GlobalMaterialLocalizations.delegates` (`flutter_localizations`), così i widget di sistema (date/time picker, menu di selezione testo, tooltip) sono in italiano come il resto dell'UI, che ha stringhe italiane hardcoded. Quando verrà introdotta la localizzazione completa (`.arb` + `gen-l10n`) il `locale` fisso andrà rimosso.

**Transizioni tra schermate**: le sezioni del drawer (`AppRouter.sectionRoutes`: tasks, promemoria, calendario, etichette, archivio, cestino, impostazioni) usano `FadeThroughPageRoute` (dissolvenza + leggero zoom 0.92→1, 300 ms; nessuna animazione con `MediaQuery.disableAnimations`), perché sono sezioni sorelle e non un drill-down; le schermate di dettaglio restano `MaterialPageRoute`. Da una card all'editor della nota c'è un `NoteHero` (`lib/widgets/shared/note_hero.dart`, vedi §6).

**Deep link dalle notifiche** (`lib/core/routing/`): `NotificationTarget` codifica/decodifica il payload (payload assenti o malformati, es. notifiche programmate prima di questa versione, → `null`: si apre solo l'app) e `resolve` trova l'elemento non cestinato nelle liste. `NotificationLaunchHandler` avvolge la `HomeScreen` dell'utente loggato (quindi sta sotto il `Navigator` di `MaterialApp`, nessun `navigatorKey` globale): ascolta `pendingTarget` e, con `ref.listenManual`, le liste e i flag di loading; quando l'elemento compare lo apre con `AppNav` (note protette solo dopo `NoteLockService.authenticate`) e azzera il target. Se l'elemento non c'è a caricamento finito (note/task: `notesLoadingProvider`/`tasksLoadingProvider`; eventi, senza flag: dopo 10 s) mostra lo snackbar "Elemento del promemoria non trovato". Un tap prima del login resta in attesa finché l'utente entra.

**Stato di sincronizzazione**: `MaterialApp.builder` avvolge l'app in `SyncStatusListener` (`lib/widgets/sync_status_listener.dart`), sotto lo `ScaffoldMessenger` radice: mostra un `MaterialBanner` "Modifiche non ancora sincronizzate…" (con "Nascondi") quando `syncStatusProvider.queued` passa da 0 a >0 e lo toglie quando torna a 0 (solo sulle transizioni, così un banner nascosto non ricompare a ogni modifica offline), e uno SnackBar quando una scrittura accodata viene poi rifiutata dal server.

`NotesApp` (`ConsumerWidget`) legge `themeModeProvider` per il tema e `authStateProvider` per l'auth gate: `.when(loading: splash, error: LoginScreen, data: user != null ? HomeScreen : LoginScreen)`. Un `ref.listen` su note/task attivi tiene sincronizzato l'home widget Android. Tutta la navigazione passa da `core/routing/app_router.dart`: `MaterialApp` usa `AppRouter.onGenerateRoute` (un `switch` su `AppRoutes`: sezioni del drawer, Statistiche, Esporta, Info, e gli editor nota/task/evento che richiedono un argomento tipizzato — `NoteRouteArgs`, `TaskModel`, `CalendarEventModel`) e `AppRouter.onUnknownRoute`, che mostra `UnknownRouteScreen` ("Pagina non trovata" + "Torna alla home") per nomi sconosciuti o argomenti mancanti/del tipo sbagliato invece di andare in crash. Gli screen non usano `Navigator.push(MaterialPageRoute(...))`: chiamano gli helper tipizzati `AppNav.openNote/openTask/openEvent/openTasks/openStatistics/openExport/openInfo`. `AppRoutes` è riesportato da `nav_scaffold.dart`. Le notifiche non hanno ancora un payload: il deep link dal tocco su un promemoria è il passo successivo.

---

## 10. Testing (`test/`)

```bash
flutter test
```

- **`test/providers/notes_provider_test.dart`**, **`tasks_provider_test.dart`** — unit test dei notifier contro [`fake_cloud_firestore`](https://pub.dev/packages/fake_cloud_firestore) (dev dependency), leggendo `NotesNotifier`/`TasksNotifier`/`TaskListsNotifier` da un `ProviderContainer` creato con `createTestContainer(db)` (`test/helpers/test_container.dart`: override di `firestoreProvider` e `currentUidProvider`, bypassando Firebase Auth reale). Copertura: CRUD, ciclo cestino, tag, `reorderNotes`, dipendenza incrociata `taskListsProvider → tasksProvider.clearListReferences`, provider derivati/filtrati.
- **`test/screens/note_editor_screen_test.dart`**, **`task_editor_screen_test.dart`** — widget test che montano le due schermate editor dentro un `ProviderScope` con `notesProvider`/`tasksProvider` sovrascritti allo stesso pattern fake-Firestore. Nessun progetto Firebase reale necessario per eseguire la suite.
- **`test/utils/changelog_service_test.dart`** — unit test di `ChangelogService` con `SharedPreferences.setMockInitialValues` e una lista di voci fittizia (prima installazione, stessa versione, aggiornamento, versione sconosciuta).
- **`test/screens/boot_error_screen_test.dart`** — widget test di `BootErrorApp` (messaggio visibile, Riprova invoca il callback).
- **`test/theme/app_theme_test.dart`** — verifica che i ruoli del `TextTheme` (light e dark) seguano `AppFontSizes`, usino "Exo 2" e che i title siano `w600`.
- **`test/screens/rebuild_granularity_test.dart`** — `IdList` (uguaglianza per contenuto), `filteredNoteIdsProvider` che non notifica su modifiche di solo contenuto, `noteByIdProvider` che notifica solo per la propria nota (e `null` dopo l'eliminazione); widget test: modificando una nota la card di un'altra nota nella griglia resta la stessa istanza di widget (non ricostruita), idem per le righe di `TaskListView`, e completare un task lo sposta tra le sezioni. Le notifiche dei provider derivati sono asincrone: nei test unitari serve `await container.pump()` prima delle asserzioni.
- **`test/screens/reorderable_grid_view_test.dart`** — `masonryColumnLength` e griglia Home: distribuzione round-robin sulle colonne, altezza naturale delle card (una nota corta sotto un'altra corta non aspetta la fine della nota lunga accanto), drag&drop che riporta gli indici globali.
- **`test/widgets/note_hero_test.dart`** — `NoteHero`: volo card→editor e ritorno senza eccezioni, nessun volo con animazioni ridotte, `NoteHeroTag` uguale per id indipendentemente dal colore.
- **`test/widgets/skeleton_test.dart`** — `SkeletonPulse` (nodo semantico unico, pulsazione ferma con animazioni ridotte), `NotesSkeleton` griglia/lista senza overflow, `FadeSwitcher` (dissolvenza al cambio chiave, il figlio uscente conserva lo scroll, istantaneo con animazioni ridotte).
- **`test/a11y/text_scale_test.dart`** — widget chiave (campi di ricerca in AppBar, empty state + banner promemoria, griglia Home con note lunghe/etichettate/protette, style editor, vista mese calendario, editor nota e task) su un telefono 360×690 con testo di sistema al 200%: nessun overflow.
- **`test/a11y/semantics_test.dart`** — `NoteCard` espone un nodo unico con testo, tap e azioni rapide (eseguirle modifica davvero la nota); la griglia Home espone "Sposta prima/dopo" con gli indici corretti; `showAppSheet` tiene il contenuto sopra la barra di navigazione.
- **`test/screens/split_screens_test.dart`** — parti estratte dagli screen monolitici: validatori login, `sortTasksForDisplay` (gruppi attivi/completati, ordinamenti, input non modificato), `showAppTextInputDialog` (trim, invio da tastiera, vuoto/annulla → `null`), `CalendarEventDetailsSection` (toggle e ricorrenza aggiornano l'evento).
- **`test/widgets/design_system_test.dart`** — `SectionHeader` (header semantico, colore primary/outline), `ActionTile` (icona/sottotitolo/chevron, tap, `destructive` in `error`, `trailing` personalizzato), `ItemCardList`/`ItemCard` (card separate e tappabili), `TagChip` dense più piccolo, `showAppTextInputDialog` con `initialValue` (testo trimmato), `showAppMessageDialog`.
- **`test/widgets/app_dialogs_test.dart`** — widget test di `showAppConfirmDialog` (conferma → `true`, Annulla/tap fuori → `false`, `destructive` usa `FilledButton`).
- **`test/widgets/empty_state_test.dart`** — widget test di `EmptyState` (pulsante mostrato solo con `actionLabel`, tap invoca `onAction`).
- **`test/widgets/swipe_actions_test.dart`** — widget test di `SwipeActions` (swipe a destra con `removesItem: false` lascia la riga, swipe a sinistra la rimuove).
- **`test/utils/recurrence_test.dart`** — unit test puri (senza widget né Firestore) di `recurrenceTypeFromString` (round-trip, fallback a `none`) e di `calendarEventOccursOn`: ogni tipo di ricorrenza, orario ignorato, nessuna occorrenza prima dell'inizio, fine ricorrenza inclusiva, mensile del 31 che salta i mesi corti, annuale del 29 febbraio solo negli anni bisestili.
- **`test/utils/ics_service_test.dart`** — unit test di `IcsImportService`/`IcsExportService` e del round trip export→import: date tutto il giorno e UTC, `TZID` (inizializza i fusi con `timezone/data/latest.dart`), fine predefinita, eventi scartati, unfolding, unescape, HTML, compleanni, tutte le `FREQ`, `UNTIL`/`COUNT` (anche a cavallo del cambio d'ora), conservazione di `recurrenceEndDate` nel round trip.
- **`test/utils/backup_service_test.dart`** — test di `BackupService` su una cartella temporanea reale (mock del canale `plugins.flutter.io/path_provider` + `SharedPreferences.setMockInitialValues`): round trip crea→ripristina, `metadata.json` con `appVersion`, nessuna cartella temporanea residua, zip corrotto/mancante/incompleto → `null`, retention dei 30 più recenti, ordinamento e filtro della lista, `getBackupInfo`, `deleteBackup`, soglie di `isBackupDue` per ogni frequenza.
- **`test/providers/backup_restore_test.dart`** — `FullBackupData` (layout piatto e zip, sezioni assenti, dati malformati) e `BackupRestorer` contro `fake_cloud_firestore` con i quattro provider sovrascritti: `apply` aggiorna stato e Firestore (stato aggiornato prima della persistenza), cancella i documenti non presenti nel backup, lascia invariate le sezioni assenti; `readZip` rilegge un backup creato da `BackupService` e restituisce `null` per file mancanti o malformati.
- **`test/providers/undo_redo_test.dart`** — stack di `NoteChangeHistoryNotifier`/`TaskChangeHistoryNotifier` (undo/redo, una nuova modifica svuota il redo, limite di 50 con scarto della più vecchia, `clear`), le quattro `*Change` usate dagli editor (titolo/testo nota, titolo/descrizione task) e `NoteUndoRedoManager`/`TaskUndoRedoManager` tramite un `Consumer` che espone il `WidgetRef` (persistenza su `fake_cloud_firestore`, nessun salvataggio di una nota non ancora memorizzata).
- **`test/theme/app_colors_test.dart`** — `AppColors.contrastRatio` (21 nero/bianco, 1 su colori uguali, simmetria) e `contrastingTextColor`: sceglie sempre l'opzione a contrasto maggiore (anche su toni saturi medi), testo scuro sugli swatch chiari e bianco su quelli scuri, contrasto ≥ 4.5 (WCAG AA) su tutti gli swatch delle note.
- **`test/providers/data_actions_test.dart`** — `DataActions` contro `fake_cloud_firestore`: chiavi dei payload di export e `appVersion` nel backup completo, `hasLockedNotes`, round trip export completo → clear → import, import per sezione da un backup completo (solo la sezione richiesta), file senza la sezione, dati malformati che lanciano in modo sincrono senza modificare nulla, `icsExport`/`importIcs` (con e senza eventi), clear per sezione e `clearAll` anche su Firestore.
- **`test/core/notification_target_test.dart`** — payload `encode`/`parse` (round-trip, payload malformati → `null`) e `resolve` (tipo giusto, esclusi cestinati/mancanti).
- **`test/core/notification_launch_handler_test.dart`** — `NotificationLaunchHandler` con Firestore finto e route segnaposto: target pendente all'avvio, tap ad app aperta (task/evento), attesa del caricamento, snackbar per elemento mancante (note subito a loading finito, eventi dopo il timeout), nota protetta aperta solo dopo lo sblocco.
- **`test/providers/sync_test.dart`** — `FirestoreListMutations` con `writeGrace` ridotto: scrittura confermata (nessuna coda), errore entro la finestra (rollback + rethrow), scrittura lenta (il chiamante prosegue, `queued` sale e poi torna a 0), rifiuto tardivo (`failures` + `reload`), `commitInChunks` oltre i 500 op; `SyncStatusListener`: banner visibile solo con scritture in coda, SnackBar sul rifiuto.
- **`test/core/app_router_test.dart`** — `AppRouter`: ogni route di sezione costruisce il proprio screen (sezioni del drawer con `FadeThroughPageRoute`, dettagli con `MaterialPageRoute`), gli editor ricevono gli argomenti tipizzati, route di dettaglio senza argomenti o con argomenti del tipo sbagliato e nomi sconosciuti vengono rifiutati, `onUnknownRoute` mostra "Pagina non trovata" e "Torna alla home" riporta alla root.

Pattern riusabile per estendere la copertura ad altri provider/schermate: `createTestContainer(FakeFirebaseFirestore())` (o `firestoreOverrides(db)` dentro un `ProviderContainer` proprio), leggere i notifier con `container.read(xProvider.notifier)` e, nei widget test, montare `UncontrolledProviderScope(container: container, ...)` così test e widget condividono gli stessi notifier; `notifier.state` è leggibile dai test (`@visibleForTesting`). Per tenere vivo un provider `autoDispose` (storia undo/redo) usare `container.listen`. Oppure — per provider che dipendono da `sharedPreferencesProvider` (tutto `providers/settings/`) — usare `SharedPreferences.setMockInitialValues({})` e passare l'istanza via override nel `ProviderContainer`/`ProviderScope`.

---

## 11. Note di manutenzione

- **Migrazione a `Notifier` completata**: nessun `StateNotifier`/`StateProvider` resta in `lib/`, senza code-gen. Per passare a `@riverpod` andrebbero riaggiunte `riverpod_annotation`, `riverpod_generator` e `build_runner`; per Riverpod 3 il passo successivo è sostituire `AutoDisposeFamilyNotifier` (undo/redo) con la sintassi unificata della nuova versione.
- **Piattaforme**: solo Android e Web. Le cartelle `ios/`, `macos/`, `linux/`, `windows/` sono state rimosse e `DefaultFirebaseOptions.currentPlatform` lancia `UnsupportedError` sulle altre piattaforme.
- **Versione e changelog**: a ogni release aggiornare insieme `version:` in `pubspec.yaml` (`X.Y.Z+N`, con `N` sempre crescente: è il `versionCode` Android) e `appVersion`/`appBuildNumber` in `lib/core/constants/app_version.dart`, e aggiungere in testa a `changelogEntries` la voce della nuova versione.
- **Firma release Android**: `android/app/build.gradle` legge `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`; git-ignored insieme a `*.jks`) e firma la build release con `signingConfigs.release`. Se il file manca ricade sulla chiave di debug, così un clone pulito builda comunque; lo script locale `deploy_android.ps1` invece si ferma se `key.properties` non esiste. Lo SHA-1 del keystore release va registrato su Firebase (app Android) e nella restrizione della API key Android su Google Cloud.
- **Regole Firestore**: versionate in `firestore.rules` (con `firebase.json` + `.firebaserc`, progetto `noteep`). Ogni utente autenticato accede solo a `users/{uid}/**`, tutto il resto è negato. Deploy con `firebase deploy --only firestore:rules` (Firebase CLI) oppure copiando il file in Console → Firestore → Regole; se si aggiunge una collezione fuori da `users/{uid}/` va aggiunta anche una regola, altrimenti le letture/scritture vengono rifiutate.
