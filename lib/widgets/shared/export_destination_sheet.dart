// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/data_export_service.dart';
import 'app_dialogs.dart';

/// Asks where an export goes: "Save to device" or "Share". Returns null if
/// dismissed. On web there is nothing to ask: the browser downloads it.
Future<ExportDestination?> pickExportDestination(BuildContext context) async {
  if (kIsWeb) return ExportDestination.device;
  return showAppSheet<ExportDestination>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                ctx.l10n.exportDestinationTitle,
                style: const TextStyle(
                  fontSize: AppFontSizes.xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(ctx.l10n.exportSaveToDevice),
              subtitle: Text(ctx.l10n.exportSaveToDeviceSubtitle),
              onTap: () => Navigator.pop(ctx, ExportDestination.device),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(ctx.l10n.commonShare),
              subtitle: Text(ctx.l10n.exportShareSubtitle),
              onTap: () => Navigator.pop(ctx, ExportDestination.share),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
  );
}
