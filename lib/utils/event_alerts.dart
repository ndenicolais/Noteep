// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../models/calendar_model.dart';
import 'recurrence.dart';

/// Hour of the alerts of all-day events (they have no time of their own).
const allDayAlertHour = 9;

/// How far ahead the alerts of an event are scheduled. Notifications are
/// one-shot, so recurring events get the occurrences in this window and the
/// window moves forward at every app start (`RemindersActions.resync`).
const alertHorizon = Duration(days: 30);

/// Most occurrences scheduled per event (a daily event would otherwise take
/// 60 of the ~500 alarms Android allows an app).
const maxAlertOccurrences = 8;

/// One alert of an event: when it fires, for which occurrence, and whether
/// it is the day-before one.
class EventAlert {
  const EventAlert({
    required this.at,
    required this.occurrence,
    required this.dayBefore,
  });

  final DateTime at;
  final DateTime occurrence;
  final bool dayBefore;
}

/// The time of the occurrence of [event] on [day]: its start time, or
/// [allDayAlertHour] for an all-day event.
DateTime occurrenceTime(CalendarEventModel event, DateTime day) =>
    event.isAllDay
        ? DateTime(day.year, day.month, day.day, allDayAlertHour)
        : DateTime(
          day.year,
          day.month,
          day.day,
          event.startTime.hour,
          event.startTime.minute,
        );

/// The alerts of [event] after [now] within [alertHorizon], at most
/// [maxAlertOccurrences] occurrences, sorted by time. Empty when the event
/// has no alert, or is archived or trashed.
List<EventAlert> upcomingEventAlerts(CalendarEventModel event, DateTime now) {
  if (!event.hasAlerts || event.isArchived || event.deletedAt != null) {
    return const [];
  }
  final alerts = <EventAlert>[];
  var occurrences = 0;
  final today = DateTime(now.year, now.month, now.day);
  // Today's occurrence can still have its same-day alert ahead; the
  // day-before alert of the last day in the window falls inside it.
  for (var d = 0; d <= alertHorizon.inDays; d++) {
    final day = DateTime(today.year, today.month, today.day + d);
    if (!event.occursOn(day)) continue;
    final at = occurrenceTime(event, day);
    final dayBefore = DateTime(
      at.year,
      at.month,
      at.day - 1,
      at.hour,
      at.minute,
    );
    var added = false;
    if (event.alertDayBefore && dayBefore.isAfter(now)) {
      alerts.add(EventAlert(at: dayBefore, occurrence: at, dayBefore: true));
      added = true;
    }
    if (event.alertSameDay && at.isAfter(now)) {
      alerts.add(EventAlert(at: at, occurrence: at, dayBefore: false));
      added = true;
    }
    if (added && ++occurrences >= maxAlertOccurrences) break;
  }
  return alerts..sort((a, b) => a.at.compareTo(b.at));
}

/// Whether [event] still has an occurrence after [now] (a recurring one
/// without an end, or with an end or a start still ahead).
bool eventHasFutureOccurrence(CalendarEventModel event, DateTime now) {
  if (event.recurrence == RecurrenceType.none) {
    return occurrenceTime(event, event.startTime).isAfter(now);
  }
  final end = event.recurrenceEndDate;
  return end == null || DateTime(end.year, end.month, end.day + 1).isAfter(now);
}
