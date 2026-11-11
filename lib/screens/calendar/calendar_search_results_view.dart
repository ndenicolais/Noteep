// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import 'calendar_event_style.dart';
import 'calendar_event_tile.dart';

/// List of events matching the current search query, sorted most-recent first.
class CalendarSearchResultsView extends StatelessWidget {
  const CalendarSearchResultsView({super.key, required this.events});

  final List<CalendarEventModel> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.calendarNoEventsFound,
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: AppFontSizes.lg,
              ),
            ),
          ],
        ),
      );
    }

    final sorted = [...events]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final event = sorted[i];
        final dayOfWeek = DateFormat('EEEE').format(event.startTime);
        final dateStr = DateFormat('d MMMM yyyy').format(event.startTime);
        final timeStr = formatEventTimeRange(context.l10n, event);

        return ListTile(
          leading: _buildLeading(context, event, colorScheme),
          title: Text(
            event.title.isEmpty
                ? context.l10n.commonUntitledParens
                : event.title,
          ),
          subtitle: Text('$dayOfWeek, $dateStr • $timeStr'),
          onTap: () => AppNav.openCalendarItem(context, event),
        );
      },
    );
  }

  /// A box in the entry's color: its icon (task, birthday, name day) or the
  /// day and month.
  Widget _buildLeading(
    BuildContext context,
    CalendarEventModel event,
    ColorScheme colorScheme,
  ) {
    final style = calendarItemStyle(event, colorScheme);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          style.icon != null
              ? Icon(style.icon, color: style.foreground, size: 22)
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(event.startTime),
                    style: TextStyle(
                      fontSize: AppFontSizes.lg,
                      fontWeight: FontWeight.bold,
                      color: style.foreground,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(event.startTime),
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: style.foreground,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
    );
  }
}
