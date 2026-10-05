// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/settings/theme_provider.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/settings/backup_provider.dart';
import '../../utils/backup_service.dart' show BackupFrequency;
import '../../utils/data_export_service.dart';
import '../../utils/ics_export_service.dart';
import '../../utils/ics_import_service.dart';
import '../../widgets/nav_scaffold.dart';
import 'settings_appearance_section.dart';
import 'settings_backup_section.dart';
import 'settings_backup_sheets.dart';
import 'settings_calendar_data_section.dart';
import 'settings_global_backup_section.dart';
import 'settings_misc_sections.dart';
import 'settings_notes_data_section.dart';
import 'settings_notes_prefs_section.dart';
import 'settings_tasks_data_section.dart';
import 'settings_tasks_prefs_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final themeMode = ref.watch(themeModeProvider);
    final showCompletedTasks = ref.watch(showCompletedTasksProvider);
    final groupTasksByPriority = ref.watch(groupTasksByPriorityProvider);
    final homeLayout = ref.watch(homeLayoutProvider);
    final backupSettings = ref.watch(backupSettingsProvider);

    final sections = <Widget>[
      SettingsAppearanceSection(
        themeMode: themeMode,
        onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v),
      ),
      SettingsNotesPrefsSection(
        homeLayout: homeLayout,
        onToggleLayout: () => ref.read(homeLayoutProvider.notifier).toggle(),
      ),
      SettingsTasksPrefsSection(
        showCompletedTasks: showCompletedTasks,
        groupTasksByPriority: groupTasksByPriority,
        onToggleShowCompleted:
            () => ref.read(showCompletedTasksProvider.notifier).toggle(),
        onToggleGroupByPriority:
            () => ref.read(groupTasksByPriorityProvider.notifier).toggle(),
      ),
      SettingsBackupSection(
        backupSettings: backupSettings,
        frequencyLabel: _getFrequencyLabel(backupSettings.frequency),
        onToggleEnabled:
            (v) => ref.read(backupSettingsProvider.notifier).setEnabled(v),
        onShowFrequencySheet:
            () => showBackupFrequencySheet(
              context,
              ref,
              backupSettings.frequency,
            ),
        onShowBackupsSheet: () => showBackupsSheet(context, ref),
      ),
      SettingsNotesDataSection(
        onExportJson: () => _exportNotesJson(context, ref),
        onImportJson: () => _importNotesJson(context, ref),
        onClearNotes: () => _confirmClearNotes(context, ref),
      ),
      SettingsTasksDataSection(
        onExportJson: () => _exportTasksJson(context, ref),
        onImportJson: () => _importTasksJson(context, ref),
        onClearTasks: () => _confirmClearTasks(context, ref),
      ),
      SettingsCalendarDataSection(
        onExportJson: () => _exportCalendarJson(context, ref),
        onImportJson: () => _importCalendarJson(context, ref),
        onExportIcs: () => _exportIcsFile(context, ref),
        onImportIcs: () => _importIcsFile(context, ref),
        onClearCalendar: () => _confirmClearCalendar(context, ref),
      ),
      SettingsGlobalBackupSection(
        onExportFullBackup: () => _exportFullBackup(context, ref),
        onImportFullBackup: () => _importFullBackup(context, ref),
        onClearAll: () => _confirmClearAll(context, ref),
      ),
      SettingsGoogleDriveSection(
        onTap: () => _showGoogleDriveComingSoon(context),
      ),
      const SettingsInfoSection(),
    ];

    return NavScaffold(
      section: DrawerSection.settings,
      titleWidget: const Text('Impostazioni'),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => sections[i],
      ),
    );
  }

  // -- Shared export / import / clear helpers ---------------------------------

  /// If any note is locked, ask the user to confirm before including its
  /// plaintext content in an exported file (locked notes are only gated in
  /// the UI — export is not encrypted).
  Future<bool> _confirmLockedNotesExport(BuildContext context) async {
    final hasLocked = ref.read(notesProvider).any((n) => n.isLocked);
    if (!hasLocked) return true;
    final proceed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Note protette incluse'),
            content: const Text(
              'Il file esportato conterrà anche il testo delle note protette, in chiaro e non cifrato. Vuoi continuare?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Esporta comunque'),
              ),
            ],
          ),
    );
    return proceed == true;
  }

  Future<void> _exportJson(
    BuildContext context, {
    required Map<String, dynamic> Function() buildData,
    required String fileNamePrefix,
    required String exportedMessage,
    required String savedMessagePrefix,
    bool warnIfLockedNotes = false,
  }) async {
    if (warnIfLockedNotes) {
      final proceed = await _confirmLockedNotesExport(context);
      if (!proceed) return;
      if (!context.mounted) return;
    }
    final savedPath = await DataExportService.exportJson(
      buildData: buildData,
      fileNamePrefix: fileNamePrefix,
    );
    if (!context.mounted) return;
    final msg =
        kIsWeb
            ? exportedMessage
            : savedPath != null
            ? '$savedMessagePrefix$savedPath'
            : exportedMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _importJson(
    BuildContext context, {
    required String confirmTitle,
    required String confirmMessage,
    required void Function(Map<String, dynamic> decoded) applyDecoded,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(confirmTitle),
            content: Text(confirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Importa'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final decoded = await DataExportService.pickAndDecodeJson();
    if (decoded == null) return;
    if (!context.mounted) return;

    try {
      // applyDecoded must parse every entity it needs before writing any of
      // them to a provider, so a malformed section aborts before anything
      // is replaced (no partial old/new state on a bad file).
      applyDecoded(decoded);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'importazione: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required String successMessage,
    String deleteLabel = 'Elimina',
  }) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  onConfirm();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(successMessage)));
                },
                child: Text(
                  deleteLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  // -- Full backup export ----------------------------------------------------

  Future<void> _exportFullBackup(BuildContext context, WidgetRef ref) async {
    await _exportJson(
      context,
      warnIfLockedNotes: true,
      fileNamePrefix: 'noteep_backup',
      exportedMessage: 'Backup esportato',
      savedMessagePrefix: 'Backup salvato in:\n',
      buildData:
          () => {
            'version': '2.0.0',
            'exportedAt': DateTime.now().toIso8601String(),
            'notes': ref.read(notesProvider).map((n) => n.toJson()).toList(),
            'tasks': ref.read(tasksProvider).map((t) => t.toJson()).toList(),
            'taskLists':
                ref.read(taskListsProvider).map((l) => l.toJson()).toList(),
            'calendar':
                ref.read(calendarProvider).map((e) => e.toJson()).toList(),
          },
    );
  }

  // -- Full backup import ----------------------------------------------------

  Future<void> _importFullBackup(BuildContext context, WidgetRef ref) async {
    await _importJson(
      context,
      confirmTitle: 'Importa backup',
      confirmMessage:
          'I dati attuali (note, task ed eventi) verranno sostituiti con quelli del backup. Continuare?',
      successMessage: 'Backup importato con successo.',
      applyDecoded: (decoded) {
        // Parse every section first so a malformed one throws before any
        // provider is touched.
        final notes =
            decoded['notes'] != null
                ? (decoded['notes'] as List<dynamic>)
                    .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
                    .toList()
                : null;
        final tasks =
            decoded['tasks'] != null
                ? (decoded['tasks'] as List<dynamic>)
                    .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
                    .toList()
                : null;
        final taskLists =
            decoded['taskLists'] != null
                ? (decoded['taskLists'] as List<dynamic>)
                    .map(
                      (e) =>
                          TaskListModel.fromJson(e as Map<String, dynamic>),
                    )
                    .toList()
                : null;
        final events =
            decoded['calendar'] != null
                ? (decoded['calendar'] as List<dynamic>)
                    .map(
                      (e) => CalendarEventModel.fromJson(
                        e as Map<String, dynamic>,
                      ),
                    )
                    .toList()
                : null;

        if (notes != null) ref.read(notesProvider.notifier).replaceAll(notes);
        if (tasks != null) ref.read(tasksProvider.notifier).replaceAll(tasks);
        if (taskLists != null) {
          ref.read(taskListsProvider.notifier).replaceAll(taskLists);
        }
        if (events != null) {
          ref.read(calendarProvider.notifier).replaceAll(events);
        }
      },
    );
  }

  void _confirmClearCalendar(BuildContext context, WidgetRef ref) {
    _confirmClear(
      context,
      title: 'Cancella eventi',
      message:
          'Tutti gli eventi del calendario verranno eliminati definitivamente. Continuare?',
      successMessage: 'Tutti gli eventi sono stati eliminati.',
      onConfirm: () => ref.read(calendarProvider.notifier).clearAllEvents(),
    );
  }

  // -- Notes JSON export -----------------------------------------------------

  Future<void> _exportNotesJson(BuildContext context, WidgetRef ref) async {
    await _exportJson(
      context,
      warnIfLockedNotes: true,
      fileNamePrefix: 'noteep_notes',
      exportedMessage: 'Note esportate',
      savedMessagePrefix: 'Note salvate in:\n',
      buildData:
          () => {
            'version': '1.0.0',
            'exportedAt': DateTime.now().toIso8601String(),
            'notes': ref.read(notesProvider).map((n) => n.toJson()).toList(),
          },
    );
  }

  // -- Notes JSON import -----------------------------------------------------

  Future<void> _importNotesJson(BuildContext context, WidgetRef ref) async {
    await _importJson(
      context,
      confirmTitle: 'Importa note',
      confirmMessage:
          'Le note attuali verranno sostituite con quelle del file. Continuare?',
      successMessage: 'Note importate con successo.',
      applyDecoded: (decoded) {
        if (decoded['notes'] == null) return;
        final notes =
            (decoded['notes'] as List<dynamic>)
                .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
                .toList();
        ref.read(notesProvider.notifier).replaceAll(notes);
      },
    );
  }

  // -- Tasks JSON export -----------------------------------------------------

  Future<void> _exportTasksJson(BuildContext context, WidgetRef ref) async {
    await _exportJson(
      context,
      fileNamePrefix: 'noteep_tasks',
      exportedMessage: 'Task esportati',
      savedMessagePrefix: 'Task salvati in:\n',
      buildData:
          () => {
            'version': '1.0.0',
            'exportedAt': DateTime.now().toIso8601String(),
            'tasks': ref.read(tasksProvider).map((t) => t.toJson()).toList(),
            'taskLists':
                ref.read(taskListsProvider).map((l) => l.toJson()).toList(),
          },
    );
  }

  // -- Tasks JSON import -----------------------------------------------------

  Future<void> _importTasksJson(BuildContext context, WidgetRef ref) async {
    await _importJson(
      context,
      confirmTitle: 'Importa task',
      confirmMessage:
          'I task attuali verranno sostituiti con quelli del file. Continuare?',
      successMessage: 'Task importati con successo.',
      applyDecoded: (decoded) {
        // Parse both sections before writing either, so a malformed
        // taskLists block doesn't leave tasks replaced with no lists.
        final tasks =
            decoded['tasks'] != null
                ? (decoded['tasks'] as List<dynamic>)
                    .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
                    .toList()
                : null;
        final lists =
            decoded['taskLists'] != null
                ? (decoded['taskLists'] as List<dynamic>)
                    .map(
                      (e) =>
                          TaskListModel.fromJson(e as Map<String, dynamic>),
                    )
                    .toList()
                : null;
        if (tasks != null) ref.read(tasksProvider.notifier).replaceAll(tasks);
        if (lists != null) {
          ref.read(taskListsProvider.notifier).replaceAll(lists);
        }
      },
    );
  }

  // -- Calendar JSON export --------------------------------------------------

  Future<void> _exportCalendarJson(BuildContext context, WidgetRef ref) async {
    await _exportJson(
      context,
      fileNamePrefix: 'noteep_calendar',
      exportedMessage: 'Calendario esportato',
      savedMessagePrefix: 'Calendario salvato in:\n',
      buildData:
          () => {
            'version': '1.0.0',
            'exportedAt': DateTime.now().toIso8601String(),
            'calendar':
                ref.read(calendarProvider).map((e) => e.toJson()).toList(),
          },
    );
  }

  // -- Calendar JSON import --------------------------------------------------

  Future<void> _importCalendarJson(BuildContext context, WidgetRef ref) async {
    await _importJson(
      context,
      confirmTitle: 'Importa calendario',
      confirmMessage:
          'Gli eventi attuali verranno sostituiti con quelli del file. Continuare?',
      successMessage: 'Calendario importato con successo.',
      applyDecoded: (decoded) {
        if (decoded['calendar'] == null) return;
        final events =
            (decoded['calendar'] as List<dynamic>)
                .map(
                  (e) => CalendarEventModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        ref.read(calendarProvider.notifier).replaceAll(events);
      },
    );
  }

  // -- Clear notes -----------------------------------------------------------

  void _confirmClearNotes(BuildContext context, WidgetRef ref) {
    _confirmClear(
      context,
      title: 'Cancella note',
      message: 'Tutte le note verranno eliminate definitivamente. Continuare?',
      successMessage: 'Tutte le note sono state eliminate.',
      onConfirm: () => ref.read(notesProvider.notifier).clearAll(),
    );
  }

  // -- Clear tasks -----------------------------------------------------------

  void _confirmClearTasks(BuildContext context, WidgetRef ref) {
    _confirmClear(
      context,
      title: 'Cancella task',
      message: 'Tutti i task verranno eliminati definitivamente. Continuare?',
      successMessage: 'Tutti i task sono stati eliminati.',
      onConfirm: () {
        ref.read(tasksProvider.notifier).clearAll();
        ref.read(taskListsProvider.notifier).clearAll();
      },
    );
  }

  // -- Clear all data --------------------------------------------------------

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    _confirmClear(
      context,
      title: 'Cancella tutti i dati',
      message:
          'Tutti i dati (note, task ed eventi) verranno eliminati definitivamente. Questa operazione è irreversibile. Continuare?',
      successMessage: 'Tutti i dati sono stati eliminati.',
      deleteLabel: 'Elimina tutto',
      onConfirm: () {
        ref.read(notesProvider.notifier).clearAll();
        ref.read(tasksProvider.notifier).clearAll();
        ref.read(taskListsProvider.notifier).clearAll();
        ref.read(calendarProvider.notifier).clearAllEvents();
      },
    );
  }

  Future<void> _exportIcsFile(BuildContext context, WidgetRef ref) async {
    final events = ref.read(activeEventsProvider);
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun evento da esportare.')),
      );
      return;
    }

    final content = IcsExportService.generateIcs(events);
    final savedPath = await DataExportService.exportIcs(
      content,
      'noteep_calendario.ics',
    );
    if (!context.mounted) return;
    final msg =
        kIsWeb
            ? 'Calendario ICS scaricato'
            : savedPath != null
            ? 'Calendario ICS salvato in:\n$savedPath'
            : 'Calendario ICS esportato';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _importIcsFile(BuildContext context, WidgetRef ref) async {
    final content = await DataExportService.pickIcsContent();
    if (content == null) return;
    if (!context.mounted) return;

    final events = IcsImportService.parseIcs(content);

    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun evento trovato nel file.')),
      );
      return;
    }

    ref.read(calendarProvider.notifier).importEvents(events);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${events.length} eventi importati nel calendario.'),
      ),
    );
  }

  void _showGoogleDriveComingSoon(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Google Drive'),
            content: const Text(
              'La sincronizzazione con Google Drive sarà disponibile in una prossima versione.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _getFrequencyLabel(BackupFrequency frequency) {
    switch (frequency) {
      case BackupFrequency.daily:
        return 'Giornaliero';
      case BackupFrequency.weekly:
        return 'Settimanale';
      case BackupFrequency.monthly:
        return 'Mensile';
    }
  }
}
