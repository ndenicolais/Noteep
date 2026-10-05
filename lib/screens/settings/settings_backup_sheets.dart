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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings/backup_provider.dart';
import '../../theme/app_radius.dart';
import '../../utils/backup_service.dart' show BackupFrequency, BackupService;

/// Bottom sheet to pick the automatic backup frequency.
void showBackupFrequencySheet(
  BuildContext context,
  WidgetRef ref,
  BackupFrequency current,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Frequenza backup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Giornaliero'),
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
            title: const Text('Settimanale'),
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
            title: const Text('Mensile'),
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
          const SizedBox(height: 16),
        ],
      );
    },
  );
}

/// Bottom sheet listing saved local backups, with delete support.
void showBackupsSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return FutureBuilder(
        future: BackupService.listBackups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Errore nel caricamento dei backup: ${snapshot.error}',
              ),
            );
          }

          final backups = snapshot.data!;
          if (backups.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nessun backup disponibile'),
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
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Backup disponibili',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final backup = backups[index - 1];
                  final info = BackupService.getBackupInfo(backup);
                  final size =
                      (info['size'] as int) / (1024 * 1024); // Convert to MB

                  return ListTile(
                    title: Text(info['name'] as String),
                    subtitle: Text(
                      '${info['date']} - ${size.toStringAsFixed(2)} MB',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              child: const Text('Elimina'),
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
