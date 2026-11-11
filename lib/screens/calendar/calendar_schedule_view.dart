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
import 'calendar_event_tile.dart';
import 'calendar_utils.dart';

/// Chronological agenda ("Programma") view, laid out like Google Calendar:
/// a month banner when the month changes, then each day with entries as a
/// row with the date (weekday and number) on the left and the entry cards,
/// with their time, on the right. Opens on today and scrolls freely both
/// into the past and into the future: each direction is a lazy list of
/// months, built only when it comes into view.
class CalendarScheduleView extends StatelessWidget {
  const CalendarScheduleView({super.key, required this.allEvents});

  final List<CalendarEventModel> allEvents;

  /// Months reachable in each direction from the current one.
  static const _monthRange = 1200;
  static const _forwardKey = ValueKey('schedule-forward');

  /// The days in [from, toExclusive) with at least one entry.
  List<(DateTime, List<CalendarEventModel>)> _daysWithItems(
    DateTime from,
    DateTime toExclusive,
  ) {
    final days = <(DateTime, List<CalendarEventModel>)>[];
    for (
      var day = from;
      day.isBefore(toExclusive);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      final items = calendarItemsOn(allEvents, day);
      if (items.isNotEmpty) days.add((day, items));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonth = DateTime(today.year, today.month);
    final nextMonth = DateTime(today.year, today.month + 1);
    // Entries of the current month before today sit above the starting
    // point, together with the month banner; without them the banner goes
    // on top of today so it is visible on open.
    final pastThisMonth = _daysWithItems(currentMonth, today);

    if (allEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.calendarNoEventsScheduled,
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: AppFontSizes.lg,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      center: _forwardKey,
      slivers: [
        // Past: index 0 is closest to today, growing upward.
        SliverList(
          delegate: SliverChildBuilderDelegate((_, i) {
            if (i == 0) {
              if (pastThisMonth.isEmpty) return const SizedBox.shrink();
              return _ScheduleMonth(
                month: currentMonth,
                days: pastThisMonth,
                today: today,
              );
            }
            final month = DateTime(currentMonth.year, currentMonth.month - i);
            return _ScheduleMonth(
              month: month,
              days: _daysWithItems(
                month,
                DateTime(month.year, month.month + 1),
              ),
              today: today,
            );
          }, childCount: _monthRange + 1),
        ),
        // Future: from today onward.
        SliverPadding(
          key: _forwardKey,
          padding: const EdgeInsets.only(bottom: 88),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              if (i == 0) {
                return _ScheduleMonth(
                  month: currentMonth,
                  days: _daysWithItems(today, nextMonth),
                  today: today,
                  showBanner: pastThisMonth.isEmpty,
                );
              }
              final month = DateTime(currentMonth.year, currentMonth.month + i);
              return _ScheduleMonth(
                month: month,
                days: _daysWithItems(
                  month,
                  DateTime(month.year, month.month + 1),
                ),
                today: today,
              );
            }, childCount: _monthRange + 1),
          ),
        ),
      ],
    );
  }
}

/// A month block: the banner followed by its days with entries.
class _ScheduleMonth extends StatelessWidget {
  const _ScheduleMonth({
    required this.month,
    required this.days,
    required this.today,
    this.showBanner = true,
  });

  final DateTime month;
  final List<(DateTime, List<CalendarEventModel>)> days;
  final DateTime today;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBanner) _MonthBanner(month: month),
        for (final (day, items) in days)
          _ScheduleDayRow(
            day: day,
            items: items,
            isToday: day.isAtSameMomentAs(today),
          ),
      ],
    );
  }
}

class _MonthBanner extends StatelessWidget {
  const _MonthBanner({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy').format(month);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          fontSize: AppFontSizes.lg,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// One day: weekday (3 letters) and day number on the left, today
/// highlighted, and the day's entry cards on the right.
class _ScheduleDayRow extends StatelessWidget {
  const _ScheduleDayRow({
    required this.day,
    required this.items,
    required this.isToday,
  });

  final DateTime day;
  final List<CalendarEventModel> items;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekday = DateFormat('EEE').format(day).replaceAll('.', '');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                children: [
                  Text(
                    weekday[0].toUpperCase() + weekday.substring(1),
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      fontWeight: FontWeight.w600,
                      color:
                          isToday
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(top: AppSpacing.xxs),
                    decoration:
                        isToday
                            ? BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            )
                            : null,
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: AppFontSizes.lg,
                        fontWeight: FontWeight.w600,
                        color:
                            isToday
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (final item in items)
                  CalendarEventListTile(
                    event: item,
                    dense: true,
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      AppSpacing.xxs,
                      AppSpacing.md,
                      AppSpacing.xxs,
                    ),
                    onTap: () => AppNav.openCalendarItem(context, item),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
