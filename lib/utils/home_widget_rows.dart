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
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';
import '../models/calendar_model.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../screens/calendar/calendar_event_style.dart';
import '../screens/tasks/task_sorting.dart';
import '../theme/app_colors.dart';
import 'markdown_text.dart';

/// Rows of the list home screen widgets (`SummaryWidgets.kt`), as JSON maps.
///
/// A header row is `{t: 'h', label, day?}`; an item row is
/// `{t: 'i', kind, id, title, sub?, color?, day?}`, where `kind` is `note`,
/// `task` or `event` (the `noteep://open/<kind>/<id>` URI the tap opens),
/// `day` is `yyyy-MM-dd` and `color` an ARGB int. Null fields are omitted:
/// Android's `JSONObject.optString` would read them as `"null"`.
/// The widget swaps a header label for Today/Tomorrow/Yesterday by its `day`,
/// so the labels stay right after midnight without a new sync.
typedef HomeWidgetRow = Map<String, Object>;

const maxNoteRows = 30;
const maxTaskRows = 60;
const maxCalendarRows = 60;
const calendarDays = 14;
const _previewLength = 140;

String _isoDay(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Full date ("Thursday 12 November"), the year only when not the current one.
String _dateLabel(DateTime day, DateTime now) {
  final label = DateFormat(
    day.year == now.year ? 'EEEE d MMMM' : 'EEEE d MMMM y',
  ).format(day);
  return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
}

HomeWidgetRow _header(String label, DateTime? day) => {
  't': 'h',
  'label': label,
  if (day != null) 'day': _isoDay(day),
};

HomeWidgetRow _item({
  required String kind,
  required String id,
  required String title,
  String sub = '',
  Color? color,
  DateTime? day,
}) => {
  't': 'i',
  'kind': kind,
  'id': id,
  'title': title,
  if (sub.isNotEmpty) 'sub': sub,
  if (color != null) 'color': color.toARGB32(),
  if (day != null) 'day': _isoDay(day),
};

String _oneLine(String text) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return flat.length <= _previewLength
      ? flat
      : '${flat.substring(0, _previewLength).trimRight()}…';
}

/// Latest notes, pinned first, then by last change.
List<HomeWidgetRow> noteRows(List<NoteModel> notes, AppLocalizations l10n) {
  final sorted = List<NoteModel>.from(notes)..sort((a, b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    return b.updatedAt.compareTo(a.updatedAt);
  });
  return [
    for (final n in sorted.take(maxNoteRows))
      _item(
        kind: 'note',
        id: n.id,
        title: n.title.trim().isEmpty ? l10n.commonUntitled : n.title.trim(),
        sub: _oneLine(
          n.type == NoteType.checklist
              ? n.checklistItems
                  .map((i) => '${i.isChecked ? '☑' : '☐'} ${i.text}')
                  .join(' ')
              : markdownToPlainText(n.content),
        ),
        color: n.style.backgroundColor,
      ),
  ];
}

/// Tasks to do, grouped by due day like the Tasks page: overdue days first,
/// then today and later, the undated ones last.
List<HomeWidgetRow> taskRows(
  List<TaskModel> tasks,
  AppLocalizations l10n,
  DateTime now,
) {
  final rows = <HomeWidgetRow>[];
  var items = 0;
  final groups = groupTasksByDay(tasks.where((t) => !t.isCompleted).toList());
  for (final g in groups) {
    if (items >= maxTaskRows) break;
    final day = g.day;
    rows.add(
      _header(
        day == null ? l10n.tasksNoDateSection : _dateLabel(day, now),
        day,
      ),
    );
    for (final t in g.tasks) {
      if (items >= maxTaskRows) break;
      items++;
      final title = t.title.trim().isEmpty ? l10n.commonUntitled : t.title;
      rows.add(
        _item(
          kind: 'task',
          id: t.id,
          title: t.isSpecial ? '★ $title' : title,
          sub: [
            if (t.hasDueTime) DateFormat.Hm().format(t.dueDate!),
            if (t.description.trim().isNotEmpty)
              _oneLine(markdownToPlainText(t.description)),
          ].join(' · '),
          day: day,
        ),
      );
    }
  }
  return rows;
}

/// Events (birthdays and name days included) and tasks to do with a due
/// date for the next [calendarDays] days, by day; empty days are skipped.
List<HomeWidgetRow> calendarRows(
  List<CalendarEventModel> events,
  List<TaskModel> tasks,
  AppLocalizations l10n,
  DateTime now,
) {
  final entries = [
    ...events,
    for (final t in tasks)
      if (!t.isCompleted && TaskCalendarEvent.isShown(t)) TaskCalendarEvent(t),
  ];
  // Only the accent of each kind is used: it doesn't depend on the theme,
  // except the timed events' one, which is the primary color.
  const scheme = ColorScheme.light(primary: AppColors.warmBrown);
  final rows = <HomeWidgetRow>[];
  var items = 0;
  final today = DateTime(now.year, now.month, now.day);
  for (var i = 0; i < calendarDays && items < maxCalendarRows; i++) {
    final day = DateTime(today.year, today.month, today.day + i);
    final dayItems =
        entries.where((e) => e.occursOn(day)).toList()..sort((a, b) {
          if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
          final ta = a.startTime.hour * 60 + a.startTime.minute;
          final tb = b.startTime.hour * 60 + b.startTime.minute;
          return ta.compareTo(tb);
        });
    if (dayItems.isEmpty) continue;
    rows.add(_header(_dateLabel(day, now), day));
    for (final e in dayItems) {
      if (items >= maxCalendarRows) break;
      items++;
      final hm = DateFormat.Hm();
      rows.add(
        _item(
          kind: e is TaskCalendarEvent ? 'task' : 'event',
          id: e is TaskCalendarEvent ? e.task.id : e.id,
          title: e.title.trim().isEmpty ? l10n.commonUntitled : e.title,
          sub:
              e.isAllDay
                  ? l10n.calendarAllDay
                  : e.hasEndTime
                  ? '${hm.format(e.startTime)} – ${hm.format(e.endTime)}'
                  : hm.format(e.startTime),
          color: calendarItemStyle(e, scheme).accent,
          day: day,
        ),
      );
    }
  }
  return rows;
}
