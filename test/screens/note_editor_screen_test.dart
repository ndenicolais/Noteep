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
import 'package:noteep/models/note_model.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/screens/note_editor/note_editor_screen.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotesNotifier notifier;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifier = NotesNotifier('test-uid', firestore, (_) {}, () {});
  });

  Widget wrap(NoteModel note) {
    return ProviderScope(
      overrides: [notesProvider.overrideWith((ref) => notifier)],
      child: MaterialApp(
        home: Builder(
          builder:
              (context) => ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(note: note),
                      ),
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
  }

  testWidgets('renders the existing note title and content', (tester) async {
    final note = NoteModel(title: 'My note', content: 'Some content');
    await notifier.addNote(note);

    await tester.pumpWidget(wrap(note));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('My note'), findsOneWidget);
    expect(find.text('Some content'), findsOneWidget);
  });

  testWidgets('editing the title and leaving the screen saves the change', (
    tester,
  ) async {
    final note = NoteModel(title: 'Old title');
    await notifier.addNote(note);

    await tester.pumpWidget(wrap(note));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New title');
    await tester.pump();

    Navigator.pop(tester.element(find.byType(NoteEditorScreen)));
    await tester.pumpAndSettle();

    expect(notifier.state.single.title, 'New title');
  });

  testWidgets('pinning the note from the overflow menu persists the change', (
    tester,
  ) async {
    final note = NoteModel(title: 'Pin me');
    await notifier.addNote(note);

    await tester.pumpWidget(wrap(note));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fissa'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.isPinned, isTrue);
  });
}
