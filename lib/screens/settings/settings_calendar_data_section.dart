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
import 'settings_section_header.dart';

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
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Calendario'),
        ListTile(
          leading: Icon(Icons.download_outlined, color: primary),
          title: const Text('Esporta calendario JSON'),
          subtitle: const Text('Scarica gli eventi come file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportJson,
        ),
        ListTile(
          leading: Icon(Icons.upload_file_outlined, color: primary),
          title: const Text('Importa calendario JSON'),
          subtitle: const Text('Ripristina gli eventi da un file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportJson,
        ),
        ListTile(
          leading: Icon(Icons.calendar_today_outlined, color: primary),
          title: const Text('Esporta calendario ICS'),
          subtitle: const Text('Esporta tutti gli eventi in un file .ics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportIcs,
        ),
        ListTile(
          leading: Icon(Icons.calendar_month_outlined, color: primary),
          title: const Text('Importa da Google Calendar'),
          subtitle: const Text('Importa eventi da un file .ics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportIcs,
        ),
        ListTile(
          leading: Icon(Icons.delete_sweep_outlined, color: error),
          title: Text(
            'Cancella eventi calendario',
            style: TextStyle(color: error),
          ),
          subtitle: const Text('Rimuove tutti gli eventi dal calendario'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onClearCalendar,
        ),
      ],
    );
  }
}
