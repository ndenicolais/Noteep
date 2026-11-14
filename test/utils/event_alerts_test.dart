// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/utils/event_alerts.dart';
import 'package:noteep/utils/recurrence.dart';

void main() {
  // Monday 9 November 2026, 12:00.
  final now = DateTime(2026, 11, 9, 12);

  CalendarEventModel event({
    required DateTime start,
    bool allDay = false,
    bool sameDay = false,
    bool dayBefore = false,
    RecurrenceType recurrence = RecurrenceType.none,
    DateTime? recurrenceEnd,
  }) => CalendarEventModel(
    startTime: start,
    endTime: start,
    isAllDay: allDay,
    alertSameDay: sameDay,
    alertDayBefore: dayBefore,
    recurrence: recurrence,
    recurrenceEndDate: recurrenceEnd,
  );

  List<DateTime> times(CalendarEventModel e) =>
      upcomingEventAlerts(e, now).map((a) => a.at).toList();

  test('all-day event without alerts selected: nothing', () {
    expect(times(event(start: DateTime(2026, 11, 10), allDay: true)), isEmpty);
  });

  test('timed event: always at its start, the alert flags are ignored', () {
    final plain = event(start: DateTime(2026, 11, 11, 15, 30));
    expect(times(plain), [DateTime(2026, 11, 11, 15, 30)]);
    expect(upcomingEventAlerts(plain, now).single.dayBefore, isFalse);
    final flagged = event(
      start: DateTime(2026, 11, 11, 15, 30),
      sameDay: true,
      dayBefore: true,
    );
    expect(times(flagged), [DateTime(2026, 11, 11, 15, 30)]);
  });

  test('all-day event: day before and same day as chosen', () {
    final e = event(
      start: DateTime(2026, 11, 12),
      allDay: true,
      dayBefore: true,
    );
    expect(times(e), [DateTime(2026, 11, 11, 9)]);
    expect(upcomingEventAlerts(e, now).single.dayBefore, isTrue);
  });

  test('all-day event alerts at 09:00', () {
    final e = event(
      start: DateTime(2026, 11, 12),
      allDay: true,
      sameDay: true,
      dayBefore: true,
    );
    expect(times(e), [DateTime(2026, 11, 11, 9), DateTime(2026, 11, 12, 9)]);
  });

  test('all-day event alerts at the chosen default time', () {
    final e = event(
      start: DateTime(2026, 11, 12),
      allDay: true,
      sameDay: true,
      dayBefore: true,
    );
    final alerts = upcomingEventAlerts(e, now, allDayMinutes: 20 * 60 + 30);
    expect(alerts.map((a) => a.at), [
      DateTime(2026, 11, 11, 20, 30),
      DateTime(2026, 11, 12, 20, 30),
    ]);
  });

  test('the day-before alert has its own time', () {
    final e = event(
      start: DateTime(2026, 11, 12),
      allDay: true,
      sameDay: true,
      dayBefore: true,
    );
    final alerts = upcomingEventAlerts(
      e,
      now,
      allDayMinutes: 8 * 60,
      dayBeforeMinutes: 21 * 60 + 15,
    );
    expect(alerts.map((a) => a.at), [
      DateTime(2026, 11, 11, 21, 15),
      DateTime(2026, 11, 12, 8),
    ]);
    expect(alerts.first.occurrence, DateTime(2026, 11, 12, 8));
  });

  test('a custom default time does not move timed events', () {
    final e = event(start: DateTime(2026, 11, 12, 15), sameDay: true);
    final alerts = upcomingEventAlerts(e, now, allDayMinutes: 7 * 60);
    expect(alerts.single.at, DateTime(2026, 11, 12, 15));
  });

  test('alerts already past are skipped', () {
    // Today at 09:00 (past) and tomorrow's day-before alert today at 09:00.
    final today = event(
      start: DateTime(2026, 11, 9),
      allDay: true,
      sameDay: true,
    );
    expect(times(today), isEmpty);
    final tomorrow = event(
      start: DateTime(2026, 11, 10),
      allDay: true,
      dayBefore: true,
    );
    expect(times(tomorrow), isEmpty);
  });

  test('yearly birthday: the next occurrence only', () {
    final e = event(
      start: DateTime(1990, 11, 20),
      allDay: true,
      sameDay: true,
      recurrence: RecurrenceType.yearly,
    );
    expect(times(e), [DateTime(2026, 11, 20, 9)]);
  });

  test('weekly event repeats within the window', () {
    final e = event(
      start: DateTime(2026, 1, 7, 18),
      sameDay: true,
      recurrence: RecurrenceType.weekly,
    );
    // Wednesdays in the next 30 days.
    expect(times(e), [
      DateTime(2026, 11, 11, 18),
      DateTime(2026, 11, 18, 18),
      DateTime(2026, 11, 25, 18),
      DateTime(2026, 12, 2, 18),
      DateTime(2026, 12, 9, 18),
    ]);
  });

  test('a daily event is capped at maxAlertOccurrences', () {
    final e = event(
      start: DateTime(2026, 1, 1, 8),
      sameDay: true,
      dayBefore: true,
      recurrence: RecurrenceType.daily,
    );
    final alerts = upcomingEventAlerts(e, now);
    final occurrences = alerts.map((a) => a.occurrence).toSet();
    expect(occurrences.length, maxAlertOccurrences);
  });

  test('archived, trashed or ended events have no alerts', () {
    final e = event(start: DateTime(2026, 11, 10, 15), sameDay: true);
    expect(upcomingEventAlerts(e.copyWith(isArchived: true), now), isEmpty);
    expect(upcomingEventAlerts(e.copyWith(deletedAt: now), now), isEmpty);
    final ended = event(
      start: DateTime(2026, 1, 1, 8),
      sameDay: true,
      recurrence: RecurrenceType.daily,
      recurrenceEnd: DateTime(2026, 11, 1),
    );
    expect(times(ended), isEmpty);
    expect(eventHasFutureOccurrence(ended, now), isFalse);
  });
}
