import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/core/routing/home_widget_action.dart';
import 'package:noteep/core/routing/home_widget_launch_handler.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/task_model.dart';

void main() {
  late StreamController<Uri?> clicks;
  late int initialReads;

  setUp(() {
    clicks = StreamController<Uri?>.broadcast();
    initialReads = 0;
    HomeWidgetLaunchHandler.initialLaunchHandled = false;
  });

  tearDown(() => clicks.close());

  // Detail routes render a marker instead of the real editors, so the test
  // only checks which kind of editor AppNav was asked to open.
  Route<dynamic> fakeRoute(RouteSettings s) {
    final label = switch (s.arguments) {
      NoteRouteArgs _ => 'new note',
      TaskModel _ => 'new task',
      CalendarEventModel _ => 'new event',
      _ => 'opened ${s.name}',
    };
    return MaterialPageRoute(
      settings: s,
      builder: (_) => Scaffold(body: Text(label)),
    );
  }

  Future<void> pump(WidgetTester tester, {Uri? initial}) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: fakeRoute,
        home: HomeWidgetLaunchHandler(
          clicks: clicks.stream,
          initialUri: () async {
            initialReads++;
            return initial;
          },
          child: const Scaffold(body: Text('home')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a cold start from a widget opens the empty editor', (
    tester,
  ) async {
    await pump(tester, initial: HomeWidgetAction.newTask.uri);

    expect(find.text('new task'), findsOneWidget);
  });

  testWidgets('a tap while running opens the matching editor', (tester) async {
    await pump(tester);

    for (final (action, label) in [
      (HomeWidgetAction.newNote, 'new note'),
      (HomeWidgetAction.newTask, 'new task'),
      (HomeWidgetAction.newEvent, 'new event'),
    ]) {
      clicks.add(action.uri);
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget, reason: '$action');
    }
  });

  testWidgets('a launch without an action stays on home', (tester) async {
    await pump(tester, initial: Uri.parse('noteep://open'));
    clicks.add(null);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('the launch URI is read once, not on every sign-in', (
    tester,
  ) async {
    await pump(tester, initial: HomeWidgetAction.newNote.uri);
    // Signing out and in again rebuilds the handler from scratch.
    await tester.pumpWidget(const SizedBox());
    await pump(tester, initial: HomeWidgetAction.newNote.uri);

    expect(initialReads, 1);
    expect(find.text('home'), findsOneWidget);
  });
}
