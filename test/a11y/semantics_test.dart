// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/screens/home/reorderable_grid_view.dart';
import 'package:noteep/widgets/note_card.dart';
import 'package:noteep/widgets/shared/app_dialogs.dart';
import '../helpers/test_container.dart';

void main() {
  late ProviderContainer container;
  late NotesNotifier notes;

  setUp(() {
    container = createTestContainer(FakeFirebaseFirestore());
    notes = container.read(notesProvider.notifier);
  });

  Widget app(Widget body) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: Scaffold(body: body)),
  );

  SemanticsNode nodeOf(WidgetTester tester, String text) =>
      tester.semantics.find(
        find.ancestor(of: find.text(text), matching: find.byType(NoteCard)),
      );

  List<String> actionLabels(SemanticsNode node) => [
    // Hints (e.g. onTapHint) are label-less overrides of standard actions.
    for (final id in node.getSemanticsData().customSemanticsActionIds ?? [])
      if (CustomSemanticsAction.getAction(id)?.label case final String l) l,
  ];

  void perform(SemanticsNode node, String label) {
    final id = node.getSemanticsData().customSemanticsActionIds!.firstWhere(
      (id) => CustomSemanticsAction.getAction(id)?.label == label,
    );
    node.owner!.performAction(node.id, SemanticsAction.customAction, id);
  }

  testWidgets('NoteCard exposes its quick actions to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final note = NoteModel(title: 'Spesa', content: 'latte');
    await notes.addNote(note);
    await tester.pumpWidget(app(NoteCard(note: note)));

    final node = nodeOf(tester, 'Spesa');
    expect(node.getSemanticsData().label, contains('Spesa'));
    expect(node.getSemanticsData().label, contains('latte'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(actionLabels(node), [
      'Fissa',
      'Archivia',
      'Blocca',
      'Sposta nel cestino',
    ]);

    perform(node, 'Fissa');
    await tester.pump();
    expect(notes.state.single.isPinned, isTrue);
    handle.dispose();
  });

  testWidgets('Home grid offers move actions instead of drag only', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final calls = <(int, int)>[];
    final list = [
      NoteModel(title: 'Uno'),
      NoteModel(title: 'Due'),
      NoteModel(title: 'Tre'),
    ];
    for (final n in list) {
      await notes.addNote(n);
    }
    await tester.pumpWidget(
      app(
        ReorderableGridView(
          noteIds: [for (final n in list) n.id],
          onReorder: (f, t) => calls.add((f, t)),
        ),
      ),
    );

    expect(
      actionLabels(nodeOf(tester, 'Uno')),
      isNot(contains('Sposta prima')),
    );
    expect(actionLabels(nodeOf(tester, 'Uno')), contains('Sposta dopo'));
    expect(actionLabels(nodeOf(tester, 'Tre')), contains('Sposta prima'));
    expect(actionLabels(nodeOf(tester, 'Tre')), isNot(contains('Sposta dopo')));

    perform(nodeOf(tester, 'Due'), 'Sposta dopo');
    perform(nodeOf(tester, 'Due'), 'Sposta prima');
    expect(calls, [(1, 2), (1, 0)]);
    handle.dispose();
  });

  testWidgets('showAppSheet keeps content above the system nav bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(bottom: 48),
                viewPadding: const EdgeInsets.only(bottom: 48),
              ),
              child: child!,
            ),
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => showAppSheet<void>(
                      context,
                      builder: (_) => const Text('contenuto'),
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final screen = tester.getSize(find.byType(MaterialApp));
    expect(
      tester.getBottomLeft(find.text('contenuto')).dy,
      lessThanOrEqualTo(screen.height - 48),
    );
  });
}
