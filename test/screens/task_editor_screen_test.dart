// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
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
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/screens/task_editor/task_editor_screen.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TasksNotifier notifier;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifier = TasksNotifier('test-uid', firestore, (_) {}, () {});
  });

  Widget wrap(TaskModel task) {
    return ProviderScope(
      overrides: [tasksProvider.overrideWith((ref) => notifier)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskEditorScreen(task: task),
                        ),
                      ),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the existing task title and description', (
    tester,
  ) async {
    final task = TaskModel(title: 'Buy milk', description: 'From the shop');
    await notifier.addTask(task);

    await tester.pumpWidget(wrap(task));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('From the shop'), findsOneWidget);
  });

  testWidgets('editing the title and leaving the screen saves the change', (
    tester,
  ) async {
    final task = TaskModel(title: 'Old title');
    await notifier.addTask(task);

    await tester.pumpWidget(wrap(task));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New title');
    await tester.pump();

    Navigator.pop(tester.element(find.byType(TaskEditorScreen)));
    await tester.pumpAndSettle();

    expect(notifier.state.single.title, 'New title');
  });

  testWidgets('adding a subtask appends it to the task', (tester) async {
    final task = TaskModel(title: 'With subtasks');
    await notifier.addTask(task);

    await tester.pumpWidget(wrap(task));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Aggiungi sottoattività...'),
      'First subtask',
    );
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('First subtask'), findsOneWidget);
  });

  testWidgets('deleting moves the task to the trash and Annulla restores it', (
    tester,
  ) async {
    final task = TaskModel(title: 'To trash');
    await notifier.addTask(task);

    await tester.pumpWidget(wrap(task));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Elimina task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.deletedAt, isNotNull);
    expect(find.text('Task spostato nel cestino'), findsOneWidget);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.deletedAt, isNull);
  });
}
