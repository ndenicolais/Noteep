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
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/screens/calendar/calendar_schedule_view.dart';
import 'package:noteep/screens/calendar/calendar_time_grid.dart';
import 'package:noteep/screens/calendar/calendar_utils.dart';
import 'package:noteep/utils/recurrence.dart';

import '../helpers/l10n.dart';

Widget _app(Widget child) => MaterialApp(
  locale: testLocale,
  supportedLocales: testSupportedLocales,
  localizationsDelegates: testLocalizationsDelegates,
  home: Scaffold(body: child),
);

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int h, [int m = 0]) =>
      DateTime(today.year, today.month, today.day, h, m);

  CalendarEventModel timed(String title, DateTime start, [DateTime? end]) =>
      CalendarEventModel(title: title, startTime: start, endTime: end ?? start);

  CalendarEventModel allDay(String title) => CalendarEventModel(
    title: title,
    startTime: today,
    endTime: today,
    isAllDay: true,
  );

  Future<void> setSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  test('day entries: all-day first, then by time of day', () {
    final recurring = CalendarEventModel(
      title: 'Daily 08:00',
      startTime: DateTime(2020, 1, 1, 8),
      endTime: DateTime(2020, 1, 1, 8),
      recurrence: RecurrenceType.daily,
    );
    final items = calendarItemsOn([
      timed('Noon', at(12)),
      recurring,
      allDay('All day'),
    ], today);
    expect(items.map((e) => e.title), ['All day', 'Daily 08:00', 'Noon']);
  });

  testWidgets('day grid places timed, overlapping and all-day entries', (
    tester,
  ) async {
    await setSize(tester);
    final task = TaskCalendarEvent(
      TaskModel(title: 'Task due', dueDate: today),
    );
    await tester.pumpWidget(
      _app(
        CalendarTimeGrid(
          days: [today],
          showDayHeader: false,
          allEvents: [
            timed('Meeting', at(10), at(11)),
            timed('Overlap', at(10, 30), at(12)),
            timed('No end', at(15)),
            allDay('Holiday'),
            task,
          ],
        ),
      ),
    );

    expect(find.text('Holiday'), findsOneWidget);
    expect(find.text('Task due'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget); // hour gutter

    final meeting = tester.getTopLeft(find.textContaining('Meeting'));
    final overlap = tester.getTopLeft(find.textContaining('Overlap'));
    expect(overlap.dx, greaterThan(meeting.dx), reason: 'side by side');
    expect(overlap.dy, greaterThan(meeting.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('week grid collapses extra all-day entries into +N', (
    tester,
  ) async {
    await setSize(tester);
    await tester.pumpWidget(
      _app(
        CalendarTimeGrid(
          days: [for (var i = 0; i < 7; i++) today.add(Duration(days: i))],
          allEvents: [for (var i = 0; i < 4; i++) allDay('A$i')],
        ),
      ),
    );
    expect(find.text('A0'), findsOneWidget);
    expect(find.text('A1'), findsNothing);
    expect(find.text('+3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('schedule shows the date column and the time range', (
    tester,
  ) async {
    await setSize(tester);
    await tester.pumpWidget(
      _app(CalendarScheduleView(allEvents: [timed('Call', at(9), at(10))])),
    );
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('09:00 – 10:00'), findsOneWidget);
    expect(find.text('${today.day}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('schedule subtitle: time and kind, nothing for all-day', (
    tester,
  ) async {
    await setSize(tester);
    await tester.pumpWidget(
      _app(
        CalendarScheduleView(
          allEvents: [
            allDay('Holiday'),
            CalendarEventModel(
              title: 'Birthday',
              startTime: today,
              endTime: today,
              isAllDay: true,
              isBirthday: true,
            ),
            TaskCalendarEvent(TaskModel(title: 'Task day', dueDate: today)),
          ],
        ),
      ),
    );
    expect(find.text('Compleanno'), findsOneWidget);
    expect(find.text('Tutto il giorno'), findsNothing);
    expect(find.text('Task'), findsNothing);
  });
}
