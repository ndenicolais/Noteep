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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings/locale_provider.dart';
import '../../providers/settings/theme_provider.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/reminders_actions.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/nav_scaffold.dart';
import '../../widgets/shared/app_dialogs.dart';
import 'settings_appearance_section.dart';
import 'settings_language_section.dart';
import 'settings_misc_sections.dart';
import 'settings_notes_prefs_section.dart';
import 'settings_notifications_section.dart';
import 'settings_start_screen_section.dart';
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

    final sections = <Widget>[
      SettingsAppearanceSection(
        themeMode: themeMode,
        onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v),
      ),
      SettingsLanguageSection(
        language: ref.watch(appLanguageProvider),
        onChanged: (v) => ref.read(appLanguageProvider.notifier).set(v),
      ),
      SettingsStartScreenSection(
        section: ref.watch(startSectionProvider),
        onChanged: (v) => ref.read(startSectionProvider.notifier).set(v),
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
      SettingsNotificationsSection(
        defaultAlertMinutes: ref.watch(defaultAlertTimeProvider),
        onChanged:
            (v) => ref.read(remindersActionsProvider).setDefaultAlertTime(v),
      ),
      const SettingsBackupDataSection(),
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
}
