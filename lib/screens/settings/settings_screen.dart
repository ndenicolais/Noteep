// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
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
import '../../l10n/l10n.dart';
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
      titleWidget: Text(context.l10n.navSettings),
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
      confirmLabel: context.l10n.settingsImport,
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
      _showSnack(context, context.l10n.settingsImportError('$e'), seconds: 4);
    }
  }

  Future<void> _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    required String successMessage,
    String? deleteLabel,
  }) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: deleteLabel ?? context.l10n.commonDelete,
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
    exportedMessage: context.l10n.settingsBackupExported,
    savedMessagePrefix: context.l10n.settingsBackupSavedIn,
    buildData: _actions.fullBackupExport,
  );

  Future<void> _importFullBackup(BuildContext context) => _importJson(
    context,
    confirmTitle: context.l10n.settingsImportBackupTitle,
    confirmMessage: context.l10n.settingsReplaceAllConfirm,
    successMessage: context.l10n.settingsBackupImported,
    importData: _actions.importFullBackup,
  );

  void _confirmClearAll(BuildContext context) => _confirmClear(
    context,
    title: context.l10n.settingsClearAll,
    message: context.l10n.settingsClearAllConfirm,
    successMessage: context.l10n.settingsAllCleared,
    deleteLabel: context.l10n.settingsDeleteAll,
    onConfirm: _actions.clearAll,
  );

  // -- Notes -----------------------------------------------------------------

  Future<void> _exportNotesJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_notes',
    exportedMessage: context.l10n.settingsNotesExported,
    savedMessagePrefix: context.l10n.settingsNotesSavedIn,
    buildData: _actions.notesExport,
  );

  Future<void> _importNotesJson(BuildContext context) => _importJson(
    context,
    confirmTitle: context.l10n.settingsImportNotesTitle,
    confirmMessage: context.l10n.settingsReplaceNotesConfirm,
    successMessage: context.l10n.settingsNotesImported,
    importData: _actions.importNotes,
  );

  void _confirmClearNotes(BuildContext context) => _confirmClear(
    context,
    title: context.l10n.settingsClearNotes,
    message: context.l10n.settingsClearNotesConfirm,
    successMessage: context.l10n.settingsNotesCleared,
    onConfirm: _actions.clearNotes,
  );

  // -- Tasks -----------------------------------------------------------------

  Future<void> _exportTasksJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_tasks',
    exportedMessage: context.l10n.settingsTasksExported,
    savedMessagePrefix: context.l10n.settingsTasksSavedIn,
    buildData: _actions.tasksExport,
  );

  Future<void> _importTasksJson(BuildContext context) => _importJson(
    context,
    confirmTitle: context.l10n.settingsImportTasksTitle,
    confirmMessage: context.l10n.settingsReplaceTasksConfirm,
    successMessage: context.l10n.settingsTasksImported,
    importData: _actions.importTasks,
  );

  void _confirmClearTasks(BuildContext context) => _confirmClear(
    context,
    title: context.l10n.settingsClearTasks,
    message: context.l10n.settingsClearTasksConfirm,
    successMessage: context.l10n.settingsTasksCleared,
    onConfirm: _actions.clearTasks,
  );

  // -- Calendar --------------------------------------------------------------

  Future<void> _exportCalendarJson(BuildContext context) => _exportJson(
    context,
    fileNamePrefix: 'noteep_calendar',
    exportedMessage: context.l10n.settingsCalendarExported,
    savedMessagePrefix: context.l10n.settingsCalendarSavedIn,
    buildData: _actions.calendarExport,
  );

  Future<void> _importCalendarJson(BuildContext context) => _importJson(
    context,
    confirmTitle: context.l10n.settingsImportCalendarTitle,
    confirmMessage: context.l10n.settingsReplaceCalendarConfirm,
    successMessage: context.l10n.settingsCalendarImported,
    importData: _actions.importCalendar,
  );

  void _confirmClearCalendar(BuildContext context) => _confirmClear(
    context,
    title: context.l10n.settingsClearEventsTitle,
    message: context.l10n.settingsClearCalendarConfirm,
    successMessage: context.l10n.settingsCalendarCleared,
    onConfirm: _actions.clearCalendar,
  );

  Future<void> _exportIcsFile(BuildContext context) async {
    final content = _actions.icsExport();
    if (content == null) {
      _showSnack(context, context.l10n.settingsNoEventsToExport);
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
          ? context.l10n.settingsIcsDownloaded
          : savedPath != null
          ? context.l10n.settingsIcsSavedIn(savedPath)
          : context.l10n.settingsIcsExported,
    );
  }

  Future<void> _importIcsFile(BuildContext context) async {
    final content = await DataExportService.pickIcsContent();
    if (content == null) return;
    if (!context.mounted) return;

    final result = _actions.importIcs(content);
    if (result.count == 0) {
      _showSnack(context, context.l10n.settingsNoEventsInFile);
      return;
    }
    notifyOnError(result.saved, context);
    _showSnack(context, context.l10n.settingsIcsImported(result.count));
  }

  // -- Account ---------------------------------------------------------------

  Future<void> _deleteAccount(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.settingsDeleteAccount,
      message: context.l10n.settingsDeleteAccountConfirm,
      confirmLabel: context.l10n.settingsDeleteAccount,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    String? password;
    if (usesPasswordSignIn(user)) {
      password = await showAppTextInputDialog(
        context,
        title: context.l10n.settingsConfirmPassword,
        hintText: context.l10n.commonPassword,
        confirmLabel: context.l10n.settingsDeleteAccount,
        obscureText: true,
      );
      if (password == null || !context.mounted) return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
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
      error = authErrorMessage(l10n, e);
    } catch (_) {
      error = l10n.settingsDeleteAccountFailed;
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
        SnackBar(content: Text(l10n.settingsAccountDeleted)),
      );
    }
  }

  // -- Misc ------------------------------------------------------------------

  void _showGoogleDriveComingSoon(BuildContext context) => showAppMessageDialog(
    context,
    title: context.l10n.settingsGoogleDriveTitle,
    message: context.l10n.settingsDriveComingSoon,
  );

  String _getFrequencyLabel(BackupFrequency frequency) {
    final l10n = context.l10n;
    switch (frequency) {
      case BackupFrequency.daily:
        return l10n.recurrenceDaily;
      case BackupFrequency.weekly:
        return l10n.recurrenceWeekly;
      case BackupFrequency.monthly:
        return l10n.recurrenceMonthly;
    }
  }
}
