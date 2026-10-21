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

/// App bar for [CalendarEventEditorScreen]: pin and archive toggles.
class CalendarEventEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CalendarEventEditorAppBar({
    super.key,
    required this.isPinned,
    required this.isArchived,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  final bool isPinned;
  final bool isArchived;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Evento'),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: onTogglePin,
          tooltip: isPinned ? 'Sposta in alto' : 'Fissa in alto',
        ),
        IconButton(
          icon: Icon(isArchived ? Icons.unarchive : Icons.archive_outlined),
          tooltip: isArchived ? 'Ripristina' : 'Archivia',
          onPressed: onToggleArchive,
        ),
      ],
    );
  }
}

/// Bottom action bar for [CalendarEventEditorScreen]: delete, reminder and
/// close.
class CalendarEventEditorBottomBar extends StatelessWidget {
  const CalendarEventEditorBottomBar({
    super.key,
    required this.hasReminder,
    required this.onDelete,
    required this.onReminder,
    required this.onClose,
  });

  final bool hasReminder;
  final VoidCallback onDelete;
  final VoidCallback onReminder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: colorScheme.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: 'Elimina evento',
          ),
          IconButton(
            icon: Icon(
              hasReminder ? Icons.alarm : Icons.alarm_add_outlined,
              color: hasReminder ? colorScheme.primary : null,
            ),
            onPressed: onReminder,
            tooltip: 'Promemoria',
          ),
          const Spacer(),
          TextButton(onPressed: onClose, child: const Text('Chiudi')),
        ],
      ),
    );
  }
}
