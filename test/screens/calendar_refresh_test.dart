// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:noteep/screens/calendar/calendar_screen.dart';
import 'package:noteep/screens/tasks/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/l10n.dart';
import '../helpers/test_container.dart';

void main() {
  for (final view in ['schedule', 'day', 'week', 'month']) {
    for (final isTask in [false, true]) {
      testWidgets(
        '$view: ${isTask ? 'task' : 'event'} edited shows up on return',
        (tester) async {
          tester.view.physicalSize = const Size(420, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({'calendar_view_mode': view});
          final prefs = await SharedPreferences.getInstance();
          final container = createTestContainer(
            FakeFirebaseFirestore(),
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          );
          final now = DateTime.now();
          final start = DateTime(now.year, now.month, now.day, now.hour);
          if (isTask) {
            await container
                .read(tasksProvider.notifier)
                .addTask(TaskModel(title: 'Old', dueDate: start));
          } else {
            await container
                .read(calendarProvider.notifier)
                .addEvent(
                  CalendarEventModel(
                    title: 'Old',
                    startTime: start,
                    endTime: start,
                  ),
                );
          }

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: testLocale,
                supportedLocales: testSupportedLocales,
                localizationsDelegates: testLocalizationsDelegates,
                onGenerateRoute: AppRouter.onGenerateRoute,
                home: const CalendarWorkspaceView(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('Old'), findsOneWidget);

          await tester.tap(find.textContaining('Old'));
          await tester.pumpAndSettle();
          await tester.enterText(find.widgetWithText(TextField, 'Old'), 'New');
          await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
          await tester.pumpAndSettle();

          expect(find.textContaining('New'), findsOneWidget);
          expect(find.textContaining('Old'), findsNothing);
        },
      );
    }
  }

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Map<String, Object> prefs = const {},
    TaskModel? task,
    String taskQuery = '',
  }) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final instance = await SharedPreferences.getInstance();
    final container = createTestContainer(
      FakeFirebaseFirestore(),
      overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
    );
    if (task != null) {
      await container.read(tasksProvider.notifier).addTask(task);
    }
    container.read(taskSearchQueryProvider.notifier).set(taskQuery);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: testLocale,
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationsDelegates,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  testWidgets('a task with a reminder stays in the task list', (tester) async {
    await pumpScreen(
      tester,
      const TasksScreen(),
      task: TaskModel(
        title: 'Pay water',
        dueDate: today,
        reminder: today.add(const Duration(hours: 23)),
      ),
    );
    expect(find.text('Pay water'), findsOneWidget);
  });

  testWidgets('a search kept from a previous visit is shown in the field', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const TasksScreen(),
      task: TaskModel(title: 'Pay water'),
      taskQuery: 'gas',
    );
    expect(find.text('Pay water'), findsNothing);
    expect(find.widgetWithText(TextField, 'gas'), findsOneWidget);
  });

  testWidgets(
    'a task with a reminder shows its reminder time in the schedule',
    (tester) async {
      await pumpScreen(
        tester,
        const CalendarWorkspaceView(),
        prefs: {'calendar_view_mode': 'schedule'},
        task: TaskModel(
          title: 'Pay water',
          reminder: today.add(const Duration(hours: 23, minutes: 30)),
        ),
      );
      expect(find.text('Pay water'), findsOneWidget);
      expect(find.text('23:30'), findsOneWidget);
    },
  );

  testWidgets('a due date with a time (Google Tasks import) keeps its time', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const CalendarWorkspaceView(),
      prefs: {'calendar_view_mode': 'schedule'},
      task: TaskModel(
        title: 'Action',
        dueDate: today.add(const Duration(hours: 23, minutes: 45)),
      ),
    );
    expect(find.text('23:45'), findsOneWidget);
  });
}
