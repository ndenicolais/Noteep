// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../utils/recurrence.dart';

bool calendarEventOccursOn(CalendarEventModel event, DateTime day) {
  final s = event.startTime;
  final startDay = DateTime(s.year, s.month, s.day);
  final targetDay = DateTime(day.year, day.month, day.day);
  if (startDay.isAfter(targetDay)) return false;

  final end = event.recurrenceEndDate;
  if (end != null) {
    final endDay = DateTime(end.year, end.month, end.day);
    if (targetDay.isAfter(endDay)) return false;
  }

  switch (event.recurrence) {
    case RecurrenceType.none:
      return s.year == day.year && s.month == day.month && s.day == day.day;
    case RecurrenceType.daily:
      return true;
    case RecurrenceType.weekly:
      return s.weekday == day.weekday;
    case RecurrenceType.monthly:
      return s.day == day.day;
    case RecurrenceType.yearly:
      return s.month == day.month && s.day == day.day;
  }
}

/// Monday-first weekday names in the UI language, formatted with [pattern]
/// (`E` short, `EEEEE` narrow) and capitalized.
List<String> weekdayLabels(String pattern) {
  final format = DateFormat(pattern);
  return [
    // 2024-01-01 is a Monday.
    for (var i = 0; i < 7; i++) format.format(DateTime(2024, 1, 1 + i)),
  ].map((d) => d[0].toUpperCase() + d.substring(1)).toList();
}
