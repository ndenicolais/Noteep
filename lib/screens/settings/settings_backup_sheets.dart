// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings/backup_provider.dart';
import '../../providers/settings/backup_restore.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/backup_service.dart' show BackupFrequency, BackupService;
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/error_feedback.dart';

/// Bottom sheet to pick the automatic backup frequency.
void showBackupFrequencySheet(
  BuildContext context,
  WidgetRef ref,
  BackupFrequency current,
) {
  showAppSheet(
    context,
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              context.l10n.settingsBackupFrequency,
              style: TextStyle(
                fontSize: AppFontSizes.xl,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(context.l10n.recurrenceDaily),
            trailing:
                current == BackupFrequency.daily
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              ref
                  .read(backupSettingsProvider.notifier)
                  .setFrequency(BackupFrequency.daily);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(context.l10n.recurrenceWeekly),
            trailing:
                current == BackupFrequency.weekly
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              ref
                  .read(backupSettingsProvider.notifier)
                  .setFrequency(BackupFrequency.weekly);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(context.l10n.recurrenceMonthly),
            trailing:
                current == BackupFrequency.monthly
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              ref
                  .read(backupSettingsProvider.notifier)
                  .setFrequency(BackupFrequency.monthly);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      );
    },
  );
}

/// Asks for confirmation, then replaces all data with the zip backup at
/// [path]. [context] must outlive the backups sheet (the settings screen).
Future<void> _restoreBackup(
  BuildContext context,
  WidgetRef ref,
  String path,
) async {
  final confirmed = await showAppConfirmDialog(
    context,
    title: context.l10n.settingsRestoreBackup,
    message: context.l10n.settingsReplaceAllConfirm,
    confirmLabel: context.l10n.commonRestore,
  );
  if (!confirmed || !context.mounted) return;

  final restorer = ref.read(backupRestorerProvider);
  final data = await restorer.readZip(path);
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (data == null) {
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.settingsBackupReadFailed)),
    );
    return;
  }
  notifyOnError(restorer.apply(data), context);
  messenger.showSnackBar(
    SnackBar(content: Text(context.l10n.settingsBackupRestored)),
  );
}

/// Bottom sheet listing saved local backups, with restore and delete.
void showBackupsSheet(BuildContext context, WidgetRef ref) {
  final screenContext = context;
  showAppSheet(
    context,
    isScrollControlled: true,
    builder: (_) {
      return FutureBuilder(
        future: BackupService.listBackups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                context.l10n.settingsBackupsLoadError('${snapshot.error}'),
              ),
            );
          }

          final backups = snapshot.data!;
          if (backups.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(context.l10n.settingsNoBackups),
            );
          }

          return DraggableScrollableSheet(
            expand: false,
            builder: (_, scrollController) {
              return ListView.builder(
                controller: scrollController,
                itemCount: backups.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        context.l10n.settingsBackupsAvailable,
                        style: TextStyle(
                          fontSize: AppFontSizes.xl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final backup = backups[index - 1];
                  final info = BackupService.getBackupInfo(backup);
                  final size =
                      (info['size'] as int) / (1024 * 1024); // Convert to MB

                  void restore() {
                    Navigator.pop(context);
                    _restoreBackup(screenContext, ref, info['path'] as String);
                  }

                  return ListTile(
                    title: Text(info['name'] as String),
                    subtitle: Text(
                      '${info['date']} - ${size.toStringAsFixed(2)} MB',
                    ),
                    onTap: restore,
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              onTap: restore,
                              child: Text(context.l10n.commonRestore),
                            ),
                            PopupMenuItem(
                              child: Text(context.l10n.commonDelete),
                              onTap: () async {
                                await BackupService.deleteBackup(
                                  info['path'] as String,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  // Refresh
                                  showBackupsSheet(context, ref);
                                }
                              },
                            ),
                          ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}
