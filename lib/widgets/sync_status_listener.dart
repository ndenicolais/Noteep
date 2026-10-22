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
import '../providers/sync_provider.dart';

/// Shows a [MaterialBanner] while Firestore writes are queued offline and a
/// SnackBar when the server later rejects one. Meant for
/// `MaterialApp.builder`, below the app's root [ScaffoldMessenger].
class SyncStatusListener extends ConsumerWidget {
  const SyncStatusListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SyncStatus>(syncStatusProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      if (next.failures > (previous?.failures ?? 0)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Una modifica non è stata sincronizzata ed è stata annullata.',
            ),
          ),
        );
      }
      // Only on the empty ↔ non-empty transitions, so a dismissed banner
      // doesn't come back on every further offline edit.
      final wasQueued = previous?.hasQueued ?? false;
      if (next.hasQueued == wasQueued) return;
      messenger.clearMaterialBanners();
      if (!next.hasQueued) return;
      messenger.showMaterialBanner(
        MaterialBanner(
          leading: const Icon(Icons.cloud_off),
          content: const Text(
            'Modifiche non ancora sincronizzate: verranno inviate appena torni online.',
          ),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Nascondi'),
            ),
          ],
        ),
      );
    });
    return child;
  }
}
