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

/// Shared "title + message + Annulla/confirm" dialog.
///
/// Resolves to `true` only when the user taps the confirm button; dismissing
/// the dialog (cancel, barrier tap, back) resolves to `false`. Shape comes
/// from `dialogTheme` in `AppTheme`. [destructive] paints the confirm button
/// with the theme's error colors.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Annulla',
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          if (destructive)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
        ],
      );
    },
  );
  return confirmed == true;
}
