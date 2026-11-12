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

/// App bar for [CalendarEventEditorScreen]: archive toggle. Events have no
/// pin: calendar views are ordered by time.
class CalendarEventEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CalendarEventEditorAppBar({
    super.key,
    required this.isArchived,
    required this.onToggleArchive,
  });

  final bool isArchived;
  final VoidCallback onToggleArchive;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.calendarEventTitle),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(isArchived ? Icons.unarchive : Icons.archive_outlined),
          tooltip:
              isArchived
                  ? context.l10n.commonUnarchive
                  : context.l10n.commonArchive,
          onPressed: onToggleArchive,
        ),
      ],
    );
  }
}

/// Bottom action bar for [CalendarEventEditorScreen]: delete and close.
class CalendarEventEditorBottomBar extends StatelessWidget {
  const CalendarEventEditorBottomBar({
    super.key,
    required this.onDelete,
    required this.onClose,
  });

  final VoidCallback onDelete;
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
            tooltip: context.l10n.calendarDeleteEvent,
          ),
          const Spacer(),
          TextButton(onPressed: onClose, child: Text(context.l10n.commonClose)),
        ],
      ),
    );
  }
}
