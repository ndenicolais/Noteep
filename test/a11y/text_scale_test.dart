// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/screens/calendar/calendar_month_view.dart';
import 'package:noteep/screens/calendar/calendar_search_bar.dart';
import 'package:noteep/screens/home/reorderable_grid_view.dart';
import 'package:noteep/screens/note_editor/note_editor_screen.dart';
import 'package:noteep/screens/task_editor/task_editor_screen.dart';
import 'package:noteep/theme/app_theme.dart';
import 'package:noteep/widgets/reminder_banner.dart';
import 'package:noteep/widgets/shared/empty_state.dart';
import 'package:noteep/widgets/shared/search_field.dart';
import 'package:noteep/widgets/style_editor/style_editor_sheet.dart';
import '../helpers/test_container.dart';
import 'package:noteep/providers/core_providers.dart';

/// Renders key widgets on a small phone (360×690 dp) with the system text
/// size at 200% and fails on any layout overflow.
void main() {
  late FakeFirebaseFirestore db;
  late ProviderContainer container;
  late NotesNotifier notes;
  late TasksNotifier tasks;
  final query = valueStateProvider<String>('');

  setUpAll(() => initializeDateFormatting('it'));

  setUp(() {
    db = FakeFirebaseFirestore();
    container = createTestContainer(db);
    notes = container.read(notesProvider.notifier);
    tasks = container.read(tasksProvider.notifier);
  });

  Future<void> pumpScaled(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
          home: home,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// AppBar laid out like NavScaffold's (toolbarHeight 56).
  Widget appBarWith(Widget title) => Scaffold(
    appBar: AppBar(toolbarHeight: 56, title: title),
    body: const SizedBox(),
  );

  testWidgets('search field in the app bar', (tester) async {
    final c = TextEditingController(text: 'una ricerca');
    addTearDown(c.dispose);
    await pumpScaled(
      tester,
      appBarWith(
        SearchField(
          controller: c,
          provider: query,
          hintText: 'Cerca nelle note...',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar search bar in the app bar', (tester) async {
    final c = TextEditingController(text: 'evento');
    addTearDown(c.dispose);
    await pumpScaled(
      tester,
      appBarWith(
        CalendarSearchBar(controller: c, provider: query, hintText: 'Cerca'),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state and reminder banner', (tester) async {
    await pumpScaled(
      tester,
      Scaffold(
        body: Column(
          children: [
            ReminderBanner(
              reminder: DateTime(2026, 12, 24, 18, 30),
              onTap: () {},
              onRemove: () {},
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.cloud_off,
                message:
                    'Errore di sincronizzazione. Verifica la connessione e riprova.',
                actionLabel: 'Riprova',
                actionIcon: Icons.refresh,
                onAction: () {},
              ),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('home grid with long and tagged notes', (tester) async {
    await pumpScaled(
      tester,
      Scaffold(
        body: ReorderableGridView(
          notes: [
            NoteModel(
              title: 'Una nota con un titolo piuttosto lungo',
              content: List.filled(8, 'riga di testo').join('\n'),
              tags: ['lavoro', 'personale', 'urgente'],
              isPinned: true,
              reminder: DateTime(2026, 12, 24),
            ),
            NoteModel(title: 'Corta', content: 'ok'),
            NoteModel(title: 'Protetta', isLocked: true),
          ],
          onReorder: (_, __) {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('style editor sheet', (tester) async {
    await pumpScaled(
      tester,
      Scaffold(
        body: StyleEditorSheet(style: const NoteStyle(), onChanged: (_) {}),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar month view', (tester) async {
    await pumpScaled(
      tester,
      Scaffold(
        body: CalendarMonthView(
          focusedMonth: DateTime(2026, 10),
          allEvents: const [],
          onPreviousMonth: () {},
          onNextMonth: () {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('note editor', (tester) async {
    final note = NoteModel(
      title: 'Titolo della nota',
      content: 'Contenuto',
      reminder: DateTime(2026, 12, 24, 18, 30),
    );
    await notes.addNote(note);
    await pumpScaled(tester, NoteEditorScreen(note: note));
    expect(tester.takeException(), isNull);
  });

  testWidgets('task editor', (tester) async {
    final task = TaskModel(
      title: 'Titolo del task',
      description: 'Descrizione',
      dueDate: DateTime(2026, 12, 24),
      reminder: DateTime(2026, 12, 24, 18, 30),
    );
    await tasks.addTask(task);
    await pumpScaled(tester, TaskEditorScreen(task: task));
    expect(tester.takeException(), isNull);
  });
}
