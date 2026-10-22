import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/core/routing/notification_launch_handler.dart';
import 'package:noteep/core/routing/notification_target.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';
import '../helpers/test_container.dart';
import 'package:noteep/providers/core_providers.dart';

import '../helpers/l10n.dart';

/// A loading flag that keeps its initial value, so the test decides whether
/// loading is still in progress regardless of the fake Firestore fetch.
class _PinnedFlag extends ValueStateNotifier<bool> {
  _PinnedFlag(super.initial);

  @override
  void set(bool value) {}
}

void main() {
  late ProviderContainer container;
  late bool pinnedLoading;
  late ValueNotifier<NotificationTarget?> targets;

  setUp(() {
    pinnedLoading = false;
    // The loading flags are built lazily, so `pump(loading:)` still applies.
    container = createTestContainer(
      FakeFirebaseFirestore(),
      overrides: [
        notesLoadingProvider.overrideWith(() => _PinnedFlag(pinnedLoading)),
        tasksLoadingProvider.overrideWith(() => _PinnedFlag(pinnedLoading)),
      ],
    );
    targets = ValueNotifier(null);
  });

  // Detail routes render a marker instead of the real editors, so the test
  // only checks which item AppNav was asked to open.
  Route<dynamic> fakeRoute(RouteSettings s) {
    final label = switch (s.arguments) {
      NoteRouteArgs a => 'opened note ${a.note.id}',
      TaskModel t => 'opened task ${t.id}',
      CalendarEventModel e => 'opened event ${e.id}',
      _ => 'opened ${s.name}',
    };
    return MaterialPageRoute(
      settings: s,
      builder: (_) => Scaffold(body: Text(label)),
    );
  }

  Future<void> pump(WidgetTester tester, {bool loading = false}) async {
    pinnedLoading = loading;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: testLocale,
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationsDelegates,
          onGenerateRoute: fakeRoute,
          home: NotificationLaunchHandler(
            targets: targets,
            eventLoadTimeout: const Duration(seconds: 2),
            child: const Scaffold(body: Text('home')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens a target that was pending at launch', (tester) async {
    await container.read(notesProvider.notifier).addNote(NoteModel(id: 'n1'));
    targets.value = const NotificationTarget.note('n1');

    await pump(tester);

    expect(find.text('opened note n1'), findsOneWidget);
    expect(targets.value, isNull);
  });

  testWidgets('opens a target tapped while the app is running', (tester) async {
    await container.read(tasksProvider.notifier).addTask(TaskModel(id: 't1'));
    await container
        .read(calendarProvider.notifier)
        .addEvent(
          CalendarEventModel(
            id: 'e1',
            startTime: DateTime(2026),
            endTime: DateTime(2026),
          ),
        );
    await pump(tester);

    targets.value = const NotificationTarget.task('t1');
    await tester.pumpAndSettle();
    expect(find.text('opened task t1'), findsOneWidget);

    targets.value = const NotificationTarget.event('e1');
    await tester.pumpAndSettle();
    expect(find.text('opened event e1'), findsOneWidget);
  });

  testWidgets('waits for the item to load before opening it', (tester) async {
    targets.value = const NotificationTarget.note('n1');
    await pump(tester, loading: true);
    expect(find.text('home'), findsOneWidget);
    expect(targets.value, isNotNull);

    await container.read(notesProvider.notifier).addNote(NoteModel(id: 'n1'));
    await tester.pumpAndSettle();
    expect(find.text('opened note n1'), findsOneWidget);
  });

  testWidgets('a missing item shows a snackbar once loading is done', (
    tester,
  ) async {
    targets.value = const NotificationTarget.note('gone');
    await pump(tester);

    expect(find.text('Elemento del promemoria non trovato'), findsOneWidget);
    expect(find.text('home'), findsOneWidget);
    expect(targets.value, isNull);
  });

  testWidgets('a missing event gives up after the timeout', (tester) async {
    await pump(tester);
    targets.value = const NotificationTarget.event('gone');
    await tester.pump();
    expect(find.text('Elemento del promemoria non trovato'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Elemento del promemoria non trovato'), findsOneWidget);
    expect(targets.value, isNull);
  });
}
