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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';

/// Formats the time range of an event (a single time when it has no end),
/// or "Tutto il giorno" for all-day events.
String formatEventTimeRange(AppLocalizations l, CalendarEventModel event) {
  if (event.isAllDay) return l.calendarAllDay;
  final start = DateFormat('HH:mm').format(event.startTime);
  if (!event.hasEndTime) return start;
  return '$start – ${DateFormat('HH:mm').format(event.endTime)}';
}

/// A single-line list tile shared by the day, schedule and day-events-sheet
/// calendar views: shows the event leading icon/dot, title and time range.
class CalendarEventListTile extends StatelessWidget {
  const CalendarEventListTile({
    super.key,
    required this.event,
    required this.onTap,
    this.dense = false,
  });

  final CalendarEventModel event;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: dense,
      leading: _buildLeading(colorScheme),
      title: Text(
        event.title.isEmpty ? context.l10n.commonUntitledParens : event.title,
      ),
      subtitle: Text(formatEventTimeRange(context.l10n, event)),
      onTap: onTap,
    );
  }

  Widget _buildLeading(ColorScheme colorScheme) {
    if (event.isBirthday) return const Icon(Icons.cake, color: Colors.pink);
    if (event.isNameDay) {
      return const Icon(Icons.auto_awesome, color: Colors.amber);
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
