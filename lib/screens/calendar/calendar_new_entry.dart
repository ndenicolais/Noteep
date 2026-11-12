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
import '../../core/routing/app_router.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_model.dart';
import '../../models/task_model.dart';
import '../../widgets/shared/app_dialogs.dart';

/// What the calendar "+" creates, switchable in the new entry's editor
/// like in Google Calendar.
enum CalendarEntryType { event, task }

/// Asks whether to create an event or a task, then opens its editor.
Future<void> showNewCalendarEntrySheet(BuildContext context) async {
  final type = await showAppSheet<CalendarEntryType>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final type in CalendarEntryType.values)
              ListTile(
                leading: Icon(_icon(type)),
                title: Text(_label(ctx, type)),
                onTap: () => Navigator.pop(ctx, type),
              ),
          ],
        ),
  );
  if (type == null || !context.mounted) return;
  final now = DateTime.now();
  switch (type) {
    case CalendarEntryType.event:
      AppNav.openEvent(
        context,
        CalendarEventModel(startTime: now, endTime: now),
      );
    case CalendarEntryType.task:
      // Day-only due date: the task shows up in the calendar today.
      AppNav.openTask(
        context,
        TaskModel(dueDate: DateTime(now.year, now.month, now.day)),
      );
  }
}

/// Replaces the open new-event editor with a task editor carrying over
/// the title, description and date.
void switchEventToTask(
  BuildContext context,
  CalendarEventModel event, {
  required String title,
  required String description,
}) {
  final start = event.startTime;
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.task,
    arguments: TaskModel(
      title: title,
      description: description,
      dueDate:
          event.isAllDay
              ? DateTime(start.year, start.month, start.day)
              : DateTime(
                start.year,
                start.month,
                start.day,
                start.hour,
                start.minute,
              ),
    ),
  );
}

/// Replaces the open new-task editor with an event editor carrying over
/// the title, description and due date (a day-only one gives an all-day
/// event, no due date gives an event starting now).
void switchTaskToEvent(
  BuildContext context,
  TaskModel task, {
  required String title,
  required String description,
}) {
  final due = task.dueDate;
  final allDay = due != null && !task.hasDueTime;
  final start = due ?? DateTime.now();
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.event,
    arguments: CalendarEventModel(
      title: title,
      description: description,
      startTime: start,
      endTime: allDay ? start.add(const Duration(days: 1)) : start,
      isAllDay: allDay,
    ),
  );
}

IconData _icon(CalendarEntryType type) => switch (type) {
  CalendarEntryType.event => Icons.event_outlined,
  CalendarEntryType.task => Icons.task_alt,
};

String _label(BuildContext context, CalendarEntryType type) => switch (type) {
  CalendarEntryType.event => context.l10n.calendarEntryTypeEvent,
  CalendarEntryType.task => context.l10n.calendarEntryTypeTask,
};

/// Event / Task switch shown under the title of a new entry's editor.
class CalendarEntryTypeSelector extends StatelessWidget {
  const CalendarEntryTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CalendarEntryType selected;
  final ValueChanged<CalendarEntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SegmentedButton<CalendarEntryType>(
        segments: [
          for (final type in CalendarEntryType.values)
            ButtonSegment(
              value: type,
              icon: Icon(_icon(type)),
              label: Text(_label(context, type)),
            ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (s) {
          if (s.first != selected) onChanged(s.first);
        },
      ),
    );
  }
}
