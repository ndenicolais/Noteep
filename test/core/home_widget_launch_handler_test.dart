import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/core/routing/home_widget_action.dart';
import 'package:noteep/core/routing/home_widget_launch_handler.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';

void main() {
  late StreamController<Uri?> clicks;
  late int initialReads;
  // Stand-ins for the loaded lists, so a test can make an item appear later.
  final notes = valueStateProvider<Map<String, NoteModel>>({});
  final tasks = valueStateProvider<Map<String, TaskModel>>({});
  final events = valueStateProvider<Map<String, CalendarEventModel>>({});
  late ProviderContainer container;

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
      NoteRouteArgs(:final note) when note.title.isNotEmpty =>
        'note ${note.title}',
      TaskModel(:final title) when title.isNotEmpty => '${s.name} $title',
      CalendarEventModel(:final title) when title.isNotEmpty =>
        '${s.name} $title',
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
    container = ProviderContainer(
      overrides: [
        notesByIdProvider.overrideWith((ref) => ref.watch(notes)),
        tasksByIdProvider.overrideWith((ref) => ref.watch(tasks)),
        eventsByIdProvider.overrideWith((ref) => ref.watch(events)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
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

  testWidgets('a list widget row opens its note, task or event', (
    tester,
  ) async {
    await pump(tester);
    container.read(notes.notifier).set({
      'n1': NoteModel(id: 'n1', title: 'Spesa'),
    });
    container.read(tasks.notifier).set({
      't1': TaskModel(id: 't1', title: 'Mail'),
    });
    final now = DateTime(2026, 11, 12);
    container.read(events.notifier).set({
      'e1': CalendarEventModel(
        id: 'e1',
        title: 'Cena',
        startTime: now,
        endTime: now,
      ),
    });

    for (final (item, label) in [
      (const HomeWidgetOpenItem(HomeWidgetItemKind.note, 'n1'), 'note Spesa'),
      (
        const HomeWidgetOpenItem(HomeWidgetItemKind.task, 't1'),
        '${AppRoutes.taskDetails} Mail',
      ),
      (
        const HomeWidgetOpenItem(HomeWidgetItemKind.event, 'e1'),
        '${AppRoutes.eventDetails} Cena',
      ),
    ]) {
      clicks.add(item.uri);
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget, reason: '${item.kind}');
    }
  });

  testWidgets('a row tapped on a cold start waits for its item to load', (
    tester,
  ) async {
    await pump(
      tester,
      initial: const HomeWidgetOpenItem(HomeWidgetItemKind.task, 't1').uri,
    );
    expect(find.text('home'), findsOneWidget);

    container.read(tasks.notifier).set({
      't1': TaskModel(id: 't1', title: 'Mail'),
    });
    await tester.pumpAndSettle();

    expect(find.text('${AppRoutes.taskDetails} Mail'), findsOneWidget);
  });

  testWidgets('a list widget header opens its section', (tester) async {
    await pump(tester);

    clicks.add(HomeWidgetSection.calendar.uri);
    await tester.pumpAndSettle();
    expect(find.text('opened ${AppRoutes.calendar}'), findsOneWidget);

    clicks.add(HomeWidgetSection.notes.uri);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
