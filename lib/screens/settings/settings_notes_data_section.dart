// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

/// "Dati note" section: statistics, export screen, JSON export/import/clear.
class SettingsNotesDataSection extends StatelessWidget {
  const SettingsNotesDataSection({
    super.key,
    required this.onExportJson,
    required this.onImportJson,
    required this.onClearNotes,
  });

  final VoidCallback onExportJson;
  final VoidCallback onImportJson;
  final VoidCallback onClearNotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(context.l10n.settingsNotesDataTitle),
        ActionTile(
          icon: Icons.bar_chart_outlined,
          title: context.l10n.statsTitle,
          subtitle: context.l10n.settingsStatisticsSubtitle,
          onTap: () => AppNav.openStatistics(context),
        ),
        ActionTile(
          icon: Icons.upload,
          title: context.l10n.exportTitle,
          subtitle: context.l10n.settingsExportNotesSubtitle,
          onTap: () => AppNav.openExport(context),
        ),
        ActionTile(
          icon: Icons.download_outlined,
          title: context.l10n.settingsExportNotesJson,
          subtitle: context.l10n.settingsExportNotesJsonSubtitle,
          onTap: onExportJson,
        ),
        ActionTile(
          icon: Icons.upload_file_outlined,
          title: context.l10n.settingsImportNotesJson,
          subtitle: context.l10n.settingsImportNotesJsonSubtitle,
          onTap: onImportJson,
        ),
        ActionTile(
          icon: Icons.delete_sweep_outlined,
          title: context.l10n.settingsClearNotes,
          subtitle: context.l10n.settingsClearNotesSubtitle,
          destructive: true,
          onTap: onClearNotes,
        ),
      ],
    );
  }
}
