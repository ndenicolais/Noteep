// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// Confirms replacing all data with a full backup. With [offerSettings]
/// (the backup carries preferences) a checkbox, off by default, also
/// restores them. Returns null if cancelled, otherwise whether to restore
/// the preferences.
Future<bool?> showRestoreBackupDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required bool offerSettings,
}) {
  var restoreSettings = false;
  return showDialog<bool>(
    context: context,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setState) => AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ctx.l10n.settingsReplaceAllConfirm),
                    if (offerSettings)
                      CheckboxListTile(
                        value: restoreSettings,
                        onChanged:
                            (v) => setState(() => restoreSettings = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(ctx.l10n.settingsRestoreSettingsToo),
                        subtitle: Text(
                          ctx.l10n.settingsRestoreSettingsTooSubtitle,
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(ctx.l10n.commonCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, restoreSettings),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
        ),
  );
}
