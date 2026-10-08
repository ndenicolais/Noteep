// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/screens/archive_screen.dart';
import 'package:noteep/screens/calendar/calendar_event_editor_screen.dart';
import 'package:noteep/screens/calendar/calendar_screen.dart';
import 'package:noteep/screens/export_screen.dart';
import 'package:noteep/screens/info_screen.dart';
import 'package:noteep/screens/labels_screen.dart';
import 'package:noteep/screens/note_editor/note_editor_screen.dart';
import 'package:noteep/screens/reminders_screen.dart';
import 'package:noteep/screens/settings/settings_screen.dart';
import 'package:noteep/screens/statistics/statistics_screen.dart';
import 'package:noteep/screens/task_editor/task_editor_screen.dart';
import 'package:noteep/screens/tasks_screen.dart';
import 'package:noteep/screens/trash_screen.dart';
import 'package:noteep/screens/unknown_route_screen.dart';

void main() {
  /// Resolves [name] through the router and returns the widget its builder
  /// produces (without building it), or null if the router rejects it.
  Future<Widget?> resolve(
    WidgetTester tester,
    String name, [
    Object? arguments,
  ]) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    final route = AppRouter.onGenerateRoute(
      RouteSettings(name: name, arguments: arguments),
    );
    if (route == null) return null;
    expect(route.settings.name, name);
    return (route as MaterialPageRoute).builder(context);
  }

  testWidgets('maps every section route to its screen', (tester) async {
    final expected = <String, Type>{
      AppRoutes.tasks: TasksScreen,
      AppRoutes.reminders: RemindersScreen,
      AppRoutes.calendar: CalendarWorkspaceView,
      AppRoutes.labels: LabelsScreen,
      AppRoutes.archive: ArchiveScreen,
      AppRoutes.trash: TrashScreen,
      AppRoutes.settings: SettingsScreen,
      AppRoutes.statistics: StatisticsScreen,
      AppRoutes.export: ExportScreen,
      AppRoutes.info: InfoScreen,
    };
    for (final entry in expected.entries) {
      final widget = await resolve(tester, entry.key);
      expect(widget.runtimeType, entry.value, reason: entry.key);
    }
  });

  testWidgets('passes typed arguments to the editors', (tester) async {
    final note = NoteModel(title: 'N');
    final noteScreen =
        await resolve(
              tester,
              AppRoutes.note,
              NoteRouteArgs(note, autoOpenRecorder: true),
            )
            as NoteEditorScreen;
    expect(noteScreen.note, same(note));
    expect(noteScreen.autoOpenRecorder, isTrue);

    final task = TaskModel(title: 'T');
    final taskScreen =
        await resolve(tester, AppRoutes.task, task) as TaskEditorScreen;
    expect(taskScreen.task, same(task));

    final event = CalendarEventModel(
      startTime: DateTime(2026),
      endTime: DateTime(2026),
    );
    final eventScreen =
        await resolve(tester, AppRoutes.event, event)
            as CalendarEventEditorScreen;
    expect(eventScreen.event, same(event));
  });

  testWidgets('rejects detail routes with missing or wrong arguments', (
    tester,
  ) async {
    expect(await resolve(tester, AppRoutes.note), isNull);
    expect(await resolve(tester, AppRoutes.note, TaskModel()), isNull);
    expect(await resolve(tester, AppRoutes.task, NoteModel()), isNull);
    expect(await resolve(tester, AppRoutes.event), isNull);
    expect(await resolve(tester, '/does-not-exist'), isNull);
  });

  testWidgets('unknown routes show the not-found page and go back home', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Home')),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
      ),
    );

    navigatorKey.currentState!.pushNamed('/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.byType(UnknownRouteScreen), findsOneWidget);
    expect(find.text('Pagina non trovata'), findsOneWidget);

    await tester.tap(find.text('Torna alla home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(UnknownRouteScreen), findsNothing);
  });
}
