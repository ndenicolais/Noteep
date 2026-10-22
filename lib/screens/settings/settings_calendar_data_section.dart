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
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

/// "Calendario" section: JSON/ICS export-import and clear-events actions.
class SettingsCalendarDataSection extends StatelessWidget {
  const SettingsCalendarDataSection({
    super.key,
    required this.onExportJson,
    required this.onImportJson,
    required this.onExportIcs,
    required this.onImportIcs,
    required this.onClearCalendar,
  });

  final VoidCallback onExportJson;
  final VoidCallback onImportJson;
  final VoidCallback onExportIcs;
  final VoidCallback onImportIcs;
  final VoidCallback onClearCalendar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(context.l10n.navCalendar),
        ActionTile(
          icon: Icons.download_outlined,
          title: context.l10n.settingsExportCalendarJson,
          subtitle: context.l10n.settingsExportCalendarJsonSubtitle,
          onTap: onExportJson,
        ),
        ActionTile(
          icon: Icons.upload_file_outlined,
          title: context.l10n.settingsImportCalendarJson,
          subtitle: context.l10n.settingsImportCalendarJsonSubtitle,
          onTap: onImportJson,
        ),
        ActionTile(
          icon: Icons.calendar_today_outlined,
          title: context.l10n.settingsExportIcs,
          subtitle: context.l10n.settingsExportIcsSubtitle,
          onTap: onExportIcs,
        ),
        ActionTile(
          icon: Icons.calendar_month_outlined,
          title: context.l10n.settingsImportIcs,
          subtitle: context.l10n.settingsImportIcsSubtitle,
          onTap: onImportIcs,
        ),
        ActionTile(
          icon: Icons.delete_sweep_outlined,
          title: context.l10n.settingsClearCalendar,
          subtitle: context.l10n.settingsClearCalendarSubtitle,
          destructive: true,
          onTap: onClearCalendar,
        ),
      ],
    );
  }
}
