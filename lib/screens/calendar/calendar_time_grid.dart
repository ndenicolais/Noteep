// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/routing/app_router.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import 'calendar_day_events_sheet.dart';
import 'calendar_event_style.dart';
import 'calendar_event_tile.dart';
import 'calendar_utils.dart';

const double _hourHeight = 56;
const double _gutterWidth = 52;
const double _allDayChipHeight = 20;
const double _allDayChipGap = 2;

/// Hour grid shared by the day, week and 7-day views: optional weekday
/// header, a row with the all-day entries (tasks included), then 24 hour
/// slots with the hours in a gutter on the left. Timed events are placed by
/// start and duration (overlapping ones side by side), today shows a line at
/// the current time, and tapping an empty slot creates an event at that hour.
class CalendarTimeGrid extends StatefulWidget {
  const CalendarTimeGrid({
    super.key,
    required this.days,
    required this.allEvents,
    this.showDayHeader = true,
  });

  final List<DateTime> days;
  final List<CalendarEventModel> allEvents;
  final bool showDayHeader;

  @override
  State<CalendarTimeGrid> createState() => _CalendarTimeGridState();
}

class _CalendarTimeGridState extends State<CalendarTimeGrid> {
  late final ScrollController _scroll;
  late final Timer _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Open on the hour before now, like Google Calendar.
    _scroll = ScrollController(
      initialScrollOffset: math.max(0, _now.hour - 1) * _hourHeight,
    );
    _clock = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clock.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.outlineVariant.withValues(alpha: 0.4);
    final dayItems = [
      for (final day in widget.days) calendarItemsOn(widget.allEvents, day),
    ];
    final maxRows = widget.days.length == 1 ? 3 : 2;
    final allDayRows = dayItems
        .map(
          (items) => math.min(items.where((e) => e.isAllDay).length, maxRows),
        )
        .fold(0, math.max);

    return Column(
      children: [
        if (widget.showDayHeader)
          Row(
            children: [
              const SizedBox(width: _gutterWidth),
              for (final day in widget.days)
                Expanded(child: _DayHeader(day: day, now: _now)),
            ],
          ),
        if (allDayRows > 0)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: _gutterWidth),
              for (var i = 0; i < widget.days.length; i++)
                Expanded(
                  child: _AllDayCell(
                    day: widget.days[i],
                    dayItems: dayItems[i],
                    rows: allDayRows,
                    maxRows: maxRows,
                    lineColor: lineColor,
                  ),
                ),
            ],
          ),
        Divider(height: 1, color: lineColor),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: SizedBox(
              height: 24 * _hourHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HourGutter(color: colorScheme.outline),
                  for (var i = 0; i < widget.days.length; i++)
                    Expanded(
                      child: _DayColumn(
                        day: widget.days[i],
                        events: dayItems[i].where((e) => !e.isAllDay).toList(),
                        now: _now,
                        lineColor: lineColor,
                        compact: widget.days.length > 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.now});

  final DateTime day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = _isSameDay(day, now);
    return Column(
      children: [
        Text(
          DateFormat('E').format(day),
          style: TextStyle(
            fontSize: AppFontSizes.xs,
            fontWeight: FontWeight.w600,
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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
              fontSize: 13,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// The all-day entries of one day; beyond [maxRows] the last row becomes
/// "+N", which opens the day's sheet.
class _AllDayCell extends StatelessWidget {
  const _AllDayCell({
    required this.day,
    required this.dayItems,
    required this.rows,
    required this.maxRows,
    required this.lineColor,
  });

  final DateTime day;
  final List<CalendarEventModel> dayItems;
  final int rows;
  final int maxRows;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allDay = dayItems.where((e) => e.isAllDay).toList();
    final overflow = allDay.length > maxRows;
    final visible = allDay.take(overflow ? maxRows - 1 : maxRows).toList();
    return Container(
      height: rows * (_allDayChipHeight + _allDayChipGap) + _allDayChipGap,
      padding: const EdgeInsets.only(top: _allDayChipGap),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: lineColor, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in visible) _AllDayChip(item: item),
          if (overflow)
            GestureDetector(
              onTap: () => showDayEventsBottomSheet(context, day, dayItems),
              child: SizedBox(
                height: _allDayChipHeight,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+${allDay.length - visible.length}',
                      style: TextStyle(
                        fontSize: AppFontSizes.xs,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AllDayChip extends StatelessWidget {
  const _AllDayChip({required this.item});

  final CalendarEventModel item;

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(item, Theme.of(context).colorScheme);
    return GestureDetector(
      onTap: () => AppNav.openCalendarItem(context, item),
      child: Container(
        height: _allDayChipHeight,
        margin: const EdgeInsets.fromLTRB(1, 0, 1, _allDayChipGap),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (style.icon != null) ...[
              Icon(style.icon, size: 10, color: style.foreground),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Expanded(
              child: Text(
                item.title.isEmpty
                    ? context.l10n.commonUntitledParens
                    : item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: style.foreground,
                  decoration: style.decoration,
                  decorationColor: style.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourGutter extends StatelessWidget {
  const _HourGutter({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.Hm();
    return SizedBox(
      width: _gutterWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var h = 1; h < 24; h++)
            Positioned(
              top: h * _hourHeight - 7,
              right: AppSpacing.sm,
              child: Text(
                format.format(DateTime(2000, 1, 1, h)),
                style: TextStyle(fontSize: 10, color: color),
              ),
            ),
        ],
      ),
    );
  }
}

/// A timed event placed in the grid: minutes from midnight, and its column
/// among the events it overlaps with.
class _Placed {
  _Placed(this.event, this.start, this.end);

  final CalendarEventModel event;
  final int start;
  final int end;
  int column = 0;
  int columns = 1;
}

/// Events without an end (or shorter) take 30 minutes; events running past
/// midnight are cut at the end of the day. Overlapping events form a cluster
/// whose events share its width in as few columns as possible.
List<_Placed> _layoutDay(List<CalendarEventModel> events) {
  const dayEnd = 24 * 60;
  final items = [
    for (final e in events)
      _Placed(
        e,
        minuteOfDay(e.startTime),
        math.min(
          dayEnd,
          minuteOfDay(e.startTime) +
              math.max(
                30,
                e.hasEndTime ? e.endTime.difference(e.startTime).inMinutes : 0,
              ),
        ),
      ),
  ]..sort(
    (a, b) =>
        a.start != b.start
            ? a.start.compareTo(b.start)
            : b.end.compareTo(a.end),
  );

  final result = <_Placed>[];
  var cluster = <_Placed>[];
  var clusterEnd = -1;
  void flush() {
    final columnEnds = <int>[];
    for (final p in cluster) {
      var c = columnEnds.indexWhere((end) => end <= p.start);
      if (c == -1) {
        c = columnEnds.length;
        columnEnds.add(p.end);
      } else {
        columnEnds[c] = p.end;
      }
      p.column = c;
    }
    for (final p in cluster) {
      p.columns = columnEnds.length;
    }
    result.addAll(cluster);
    cluster = [];
  }

  for (final p in items) {
    if (cluster.isNotEmpty && p.start >= clusterEnd) flush();
    cluster.add(p);
    clusterEnd = math.max(clusterEnd, p.end);
  }
  flush();
  return result;
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.events,
    required this.now,
    required this.lineColor,
    required this.compact,
  });

  final DateTime day;
  final List<CalendarEventModel> events;
  final DateTime now;
  final Color lineColor;

  /// Narrow columns (week views): smaller text.
  final bool compact;

  void _createAt(BuildContext context, double dy) {
    final hour = (dy / _hourHeight).floor().clamp(0, 23);
    final start = DateTime(day.year, day.month, day.day, hour);
    AppNav.openEvent(
      context,
      CalendarEventModel(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placed = _layoutDay(events);
    final isToday = _isSameDay(day, now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _createAt(context, d.localPosition.dy),
                child: CustomPaint(painter: _GridPainter(lineColor)),
              ),
            ),
            for (final p in placed)
              Positioned(
                top: p.start / 60 * _hourHeight + 1,
                height: math.max((p.end - p.start) / 60 * _hourHeight - 2, 18),
                left: p.column * width / p.columns + 1,
                width: width / p.columns - 2,
                child: _EventBlock(event: p.event, compact: compact),
              ),
            if (isToday)
              Positioned(
                top: minuteOfDay(now) / 60 * _hourHeight - 5,
                left: 0,
                right: 0,
                height: 10,
                child: IgnorePointer(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(height: 2, color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({required this.event, required this.compact});

  final CalendarEventModel event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(event, Theme.of(context).colorScheme);
    final radius = BorderRadius.circular(4);
    final fontSize = compact ? 10.0 : 12.0;
    // Fixed-height block: cap the system text size and fit the lines to it.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    return Material(
      color: style.background,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => AppNav.openCalendarItem(context, event),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // As many lines as fit: title first, then the time range.
            final lines = math.max(
              1,
              ((constraints.maxHeight - 4) / (scaler.scale(fontSize) * 1.2))
                  .floor(),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          event.title.isEmpty
                              ? context.l10n.commonUntitledParens
                              : event.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '\n${formatEventTimeRange(context.l10n, event)}',
                    ),
                  ],
                ),
                maxLines: lines,
                overflow: TextOverflow.ellipsis,
                textScaler: scaler,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.2,
                  color: style.foreground,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hour lines and the column's left border.
class _GridPainter extends CustomPainter {
  _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 0.5;
    for (var h = 0; h <= 24; h++) {
      final y = h * _hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
