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

/// [showModalBottomSheet] whose content stays clear of the system
/// navigation bar: with edge-to-edge (enforced from Android 15) the sheet
/// is drawn down to the screen edge, so its content gets a bottom
/// [SafeArea] while the sheet background still reaches the edge. Shape
/// comes from `bottomSheetTheme` in `AppTheme`.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    builder: (ctx) => SafeArea(top: false, child: builder(ctx)),
  );
}

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
