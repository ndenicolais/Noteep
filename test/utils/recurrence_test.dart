// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/screens/calendar/calendar_utils.dart';
import 'package:noteep/utils/recurrence.dart';

CalendarEventModel _event(
  DateTime start, {
  RecurrenceType recurrence = RecurrenceType.none,
  DateTime? until,
}) => CalendarEventModel(
  title: 'Evento',
  startTime: start,
  endTime: start.add(const Duration(hours: 1)),
  recurrence: recurrence,
  recurrenceEndDate: until,
);

void main() {
  group('recurrenceTypeFromString', () {
    test('round-trips every value through toShortString', () {
      for (final type in RecurrenceType.values) {
        expect(recurrenceTypeFromString(type.toShortString()), type);
      }
    });

    test('falls back to none for unknown or empty values', () {
      expect(recurrenceTypeFromString('hourly'), RecurrenceType.none);
      expect(recurrenceTypeFromString(''), RecurrenceType.none);
      expect(recurrenceTypeFromString('Daily'), RecurrenceType.none);
    });
  });

  group('calendarEventOccursOn', () {
    final start = DateTime(2026, 3, 10, 18, 30); // Tuesday

    test('non-recurring event occurs only on its start day', () {
      final e = _event(start);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 10)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 10, 23, 59)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 11)), isFalse);
      expect(calendarEventOccursOn(e, DateTime(2027, 3, 10)), isFalse);
    });

    test('never occurs before the start day, whatever the recurrence', () {
      for (final type in RecurrenceType.values) {
        final e = _event(start, recurrence: type);
        expect(
          calendarEventOccursOn(e, DateTime(2026, 3, 9)),
          isFalse,
          reason: type.name,
        );
      }
    });

    test('ignores the time of day on both sides', () {
      final e = _event(start, recurrence: RecurrenceType.daily);
      // Earlier time than the event's start, same day.
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 10, 0, 0)), isTrue);
    });

    test('daily occurs every day from the start', () {
      final e = _event(start, recurrence: RecurrenceType.daily);
      for (var i = 0; i < 400; i++) {
        expect(
          calendarEventOccursOn(e, DateTime(2026, 3, 10 + i)),
          isTrue,
          reason: 'day +$i',
        );
      }
    });

    test('weekly occurs on the same weekday only', () {
      final e = _event(start, recurrence: RecurrenceType.weekly);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 17)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 12, 29)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 18)), isFalse);
    });

    test('monthly occurs on the same day of month', () {
      final e = _event(start, recurrence: RecurrenceType.monthly);
      expect(calendarEventOccursOn(e, DateTime(2026, 4, 10)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2027, 1, 10)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 4, 11)), isFalse);
    });

    test('monthly on the 31st skips months without a 31st', () {
      final e = _event(
        DateTime(2026, 1, 31),
        recurrence: RecurrenceType.monthly,
      );
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 31)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 2, 28)), isFalse);
      expect(calendarEventOccursOn(e, DateTime(2026, 4, 30)), isFalse);
    });

    test('yearly occurs on the same month and day', () {
      final e = _event(start, recurrence: RecurrenceType.yearly);
      expect(calendarEventOccursOn(e, DateTime(2030, 3, 10)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2027, 4, 10)), isFalse);
      expect(calendarEventOccursOn(e, DateTime(2027, 3, 11)), isFalse);
    });

    test('yearly on Feb 29 occurs only in leap years', () {
      final e = _event(
        DateTime(2024, 2, 29),
        recurrence: RecurrenceType.yearly,
      );
      expect(calendarEventOccursOn(e, DateTime(2028, 2, 29)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2025, 2, 28)), isFalse);
      expect(calendarEventOccursOn(e, DateTime(2025, 3, 1)), isFalse);
    });

    test('recurrence end date is inclusive and ignores its time', () {
      final e = _event(
        start,
        recurrence: RecurrenceType.daily,
        until: DateTime(2026, 3, 20, 0, 0),
      );
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 20, 22, 0)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 21)), isFalse);
    });

    test('recurrence end date stops weekly occurrences', () {
      final e = _event(
        start,
        recurrence: RecurrenceType.weekly,
        until: DateTime(2026, 3, 24),
      );
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 24)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 3, 31)), isFalse);
    });
  });
}
