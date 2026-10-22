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
        const SectionHeader('Calendario'),
        ActionTile(
          icon: Icons.download_outlined,
          title: 'Esporta calendario JSON',
          subtitle: 'Scarica gli eventi come file .json',
          onTap: onExportJson,
        ),
        ActionTile(
          icon: Icons.upload_file_outlined,
          title: 'Importa calendario JSON',
          subtitle: 'Ripristina gli eventi da un file .json',
          onTap: onImportJson,
        ),
        ActionTile(
          icon: Icons.calendar_today_outlined,
          title: 'Esporta calendario ICS',
          subtitle: 'Esporta tutti gli eventi in un file .ics',
          onTap: onExportIcs,
        ),
        ActionTile(
          icon: Icons.calendar_month_outlined,
          title: 'Importa da Google Calendar',
          subtitle: 'Importa eventi da un file .ics',
          onTap: onImportIcs,
        ),
        ActionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Cancella eventi calendario',
          subtitle: 'Rimuove tutti gli eventi dal calendario',
          destructive: true,
          onTap: onClearCalendar,
        ),
      ],
    );
  }
}
