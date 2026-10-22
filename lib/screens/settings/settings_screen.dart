// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings/locale_provider.dart';
import '../../providers/settings/theme_provider.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/settings/backup_provider.dart';
import '../../providers/settings/data_actions.dart';
import '../../theme/app_spacing.dart';
import '../../utils/backup_service.dart' show BackupFrequency;
import '../../utils/data_export_service.dart';
import '../../widgets/nav_scaffold.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/error_feedback.dart';
import 'settings_appearance_section.dart';
import 'settings_backup_section.dart';
import 'settings_backup_sheets.dart';
import 'settings_calendar_data_section.dart';
import 'settings_global_backup_section.dart';
import 'settings_language_section.dart';
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
      SettingsLanguageSection(
        language: ref.watch(appLanguageProvider),
        onChanged: (v) => ref.read(appLanguageProvider.notifier).set(v),
      ),
      SettingsNotesPrefsSection(
        homeLayout: homeLayout,
        onToggleLayout: () => ref.read(homeLayoutProvider.notifier).toggle(),
        fabMenu: ref.watch(notesFabMenuProvider),
        onToggleFabMenu: () => ref.read(notesFabMenuProvider.notifier).toggle(),
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
        onExportJson: () => _exportNotesJson(context),
        onImportJson: () => _importNotesJson(context),
        onClearNotes: () => _confirmClearNotes(context),
      ),
      SettingsTasksDataSection(
        onExportJson: () => _exportTasksJson(context),
        onImportJson: () => _importTasksJson(context),
        onClearTasks: () => _confirmClearTasks(context),
      ),
      SettingsCalendarDataSection(
        onExportJson: () => _exportCalendarJson(context),
        onImportJson: () => _importCalendarJson(context),
        onExportIcs: () => _exportIcsFile(context),
        onImportIcs: () => _importIcsFile(context),
        onClearCalendar: () => _confirmClearCalendar(context),
      ),
      SettingsGlobalBackupSection(
        onExportFullBackup: () => _exportFullBackup(context),
        onImportFullBackup: () => _importFullBackup(context),
        onClearAll: () => _confirmClearAll(context),
      ),
      SettingsGoogleDriveSection(
        onTap: () => _showGoogleDriveComingSoon(context),
      ),
      SettingsAccountSection(onDeleteAccount: () => _deleteAccount(context)),
      const SettingsInfoSection(),
    ];

    return NavScaffold(
      section: DrawerSection.settings,
      titleWidget: const Text('Impostazioni'),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, i) => sections[i],
      ),
    );
  }

  DataActions get _actions => ref.read(dataActionsProvider);

  void _showSnack(BuildContext context, String message, {int seconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: seconds)),
    );
  }

  // -- Shared export / import / clear flows ----------------------------------

  Future<void> _exportJson(
    BuildContext context, {
    required Map<String, dynamic> Function() buildData,
    required String fileNamePrefix,
    required String exportedMessage,
    required String savedMessagePrefix,
  }) async {
    final savedPath = await DataExportService.exportJson(
      buildData: buildData,
      fileNamePrefix: fileNamePrefix,
    );
    if (!context.mounted) return;
    _showSnack(
      context,
      !kIsWeb && savedPath != null
          ? '$savedMessagePrefix$savedPath'
          : exportedMessage,
    );
  }

  Future<void> _importJson(
    BuildContext context, {
    required String confirmTitle,
    required String confirmMessage,
    required Future<void> Function(Map<String, dynamic> decoded) importData,
    required String successMessage,
  }) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: confirmTitle,
      message: confirmMessage,
      confirmLabel: 'Importa',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final decoded = await DataExportService.pickAndDecodeJson();
    if (decoded == null) return;
    if (!context.mounted) return;

    try {
      // importData parses synchronously and throws on malformed data before
      // anything is replaced; the returned future is just persistence.
      notifyOnError(importData(decoded), context);
      _showSnack(context, successMessage);
    } catch (e) {
      _showSnack(context, 'Errore durante l\'importazione: $e', seconds: 4);
    }
  }

  Future<void> _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    required String successMessage,
    String deleteLabel = 'Elimina',
  }) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: deleteLabel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    notifyOnError(onConfirm(), context);
    _showSnack(context, successMessage);
  }

  // -- Full backup -----------------------------------------------------------

  Future<void> _exportFullBackup(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_backup',
    exportedMessage: 'Backup esportato',
    savedMessagePrefix: 'Backup salvato in:\n',
    buildData: _actions.fullBackupExport,
  );

  Future<void> _importFullBackup(BuildContext context) => _importJson(
    context,
    confirmTitle: 'Importa backup',
    confirmMessage:
        'I dati attuali (note, task ed eventi) verranno sostituiti con quelli del backup. Continuare?',
    successMessage: 'Backup importato con successo.',
    importData: _actions.importFullBackup,
  );

  void _confirmClearAll(BuildContext context) => _confirmClear(
    context,
    title: 'Cancella tutti i dati',
    message:
        'Tutti i dati (note, task ed eventi) verranno eliminati definitivamente. Questa operazione è irreversibile. Continuare?',
    successMessage: 'Tutti i dati sono stati eliminati.',
    deleteLabel: 'Elimina tutto',
    onConfirm: _actions.clearAll,
  );

  // -- Notes -----------------------------------------------------------------

  Future<void> _exportNotesJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_notes',
    exportedMessage: 'Note esportate',
    savedMessagePrefix: 'Note salvate in:\n',
    buildData: _actions.notesExport,
  );

  Future<void> _importNotesJson(BuildContext context) => _importJson(
    context,
    confirmTitle: 'Importa note',
    confirmMessage:
        'Le note attuali verranno sostituite con quelle del file. Continuare?',
    successMessage: 'Note importate con successo.',
    importData: _actions.importNotes,
  );

  void _confirmClearNotes(BuildContext context) => _confirmClear(
    context,
    title: 'Cancella note',
    message: 'Tutte le note verranno eliminate definitivamente. Continuare?',
    successMessage: 'Tutte le note sono state eliminate.',
    onConfirm: _actions.clearNotes,
  );

  // -- Tasks -----------------------------------------------------------------

  Future<void> _exportTasksJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_tasks',
    exportedMessage: 'Task esportati',
    savedMessagePrefix: 'Task salvati in:\n',
    buildData: _actions.tasksExport,
  );

  Future<void> _importTasksJson(BuildContext context) => _importJson(
    context,
    confirmTitle: 'Importa task',
    confirmMessage:
        'I task attuali verranno sostituiti con quelli del file. Continuare?',
    successMessage: 'Task importati con successo.',
    importData: _actions.importTasks,
  );

  void _confirmClearTasks(BuildContext context) => _confirmClear(
    context,
    title: 'Cancella task',
    message: 'Tutti i task verranno eliminati definitivamente. Continuare?',
    successMessage: 'Tutti i task sono stati eliminati.',
    onConfirm: _actions.clearTasks,
  );

  // -- Calendar --------------------------------------------------------------

  Future<void> _exportCalendarJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_calendar',
    exportedMessage: 'Calendario esportato',
    savedMessagePrefix: 'Calendario salvato in:\n',
    buildData: _actions.calendarExport,
  );

  Future<void> _importCalendarJson(BuildContext context) => _importJson(
    context,
    confirmTitle: 'Importa calendario',
    confirmMessage:
        'Gli eventi attuali verranno sostituiti con quelli del file. Continuare?',
    successMessage: 'Calendario importato con successo.',
    importData: _actions.importCalendar,
  );

  void _confirmClearCalendar(BuildContext context) => _confirmClear(
    context,
    title: 'Cancella eventi',
    message:
        'Tutti gli eventi del calendario verranno eliminati definitivamente. Continuare?',
    successMessage: 'Tutti gli eventi sono stati eliminati.',
    onConfirm: _actions.clearCalendar,
  );

  Future<void> _exportIcsFile(BuildContext context) async {
    final content = _actions.icsExport();
    if (content == null) {
      _showSnack(context, 'Nessun evento da esportare.');
      return;
    }
    final savedPath = await DataExportService.exportIcs(
      content,
      'noteep_calendario.ics',
    );
    if (!context.mounted) return;
    _showSnack(
      context,
      kIsWeb
          ? 'Calendario ICS scaricato'
          : savedPath != null
          ? 'Calendario ICS salvato in:\n$savedPath'
          : 'Calendario ICS esportato',
    );
  }

  Future<void> _importIcsFile(BuildContext context) async {
    final content = await DataExportService.pickIcsContent();
    if (content == null) return;
    if (!context.mounted) return;

    final result = _actions.importIcs(content);
    if (result.count == 0) {
      _showSnack(context, 'Nessun evento trovato nel file.');
      return;
    }
    notifyOnError(result.saved, context);
    _showSnack(context, '${result.count} eventi importati nel calendario.');
  }

  // -- Account ---------------------------------------------------------------

  Future<void> _deleteAccount(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Elimina account',
      message:
          'L\'account e tutti i suoi dati (note, task ed eventi) verranno eliminati definitivamente da tutti i dispositivi. Questa operazione è irreversibile: se vuoi conservare i dati, esporta prima un backup completo. Continuare?',
      confirmLabel: 'Elimina account',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    String? password;
    if (usesPasswordSignIn(user)) {
      password = await showAppTextInputDialog(
        context,
        title: 'Conferma la password',
        hintText: 'Password',
        confirmLabel: 'Elimina account',
        obscureText: true,
      );
      if (password == null || !context.mounted) return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const PopScope(
            canPop: false,
            child: Center(child: CircularProgressIndicator()),
          ),
    );
    String? error;
    var deleted = false;
    try {
      deleted = await ref
          .read(authNotifierProvider.notifier)
          .deleteAccount(password: password);
    } on FirebaseAuthException catch (e) {
      error = authErrorMessage(e);
    } catch (_) {
      error =
          'Impossibile eliminare l\'account. Controlla la connessione e riprova.';
    }
    navigator.pop();

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error), duration: const Duration(seconds: 4)),
      );
    } else if (deleted) {
      // Signed out: drop the pushed screens so the login screen is visible.
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account eliminato.')),
      );
    }
  }

  // -- Misc ------------------------------------------------------------------

  void _showGoogleDriveComingSoon(BuildContext context) => showAppMessageDialog(
    context,
    title: 'Google Drive',
    message:
        'La sincronizzazione con Google Drive sarà disponibile in una prossima versione.',
  );

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
