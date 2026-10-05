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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/providers/notes_provider.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotesNotifier notifier;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifier = NotesNotifier('test-uid', firestore, (_) {}, () {});
  });

  Future<Map<String, dynamic>?> firestoreDoc(String id) async {
    final snap =
        await firestore
            .collection('users')
            .doc('test-uid')
            .collection('notes')
            .doc(id)
            .get();
    return snap.data();
  }

  group('NotesNotifier CRUD', () {
    test('addNote adds to state and persists to Firestore', () async {
      final note = NoteModel(title: 'Hello');
      await notifier.addNote(note);

      expect(notifier.state.map((n) => n.id), contains(note.id));
      final data = await firestoreDoc(note.id);
      expect(data, isNotNull);
      expect(data!['title'], 'Hello');
    });

    test('updateNote replaces the existing note', () async {
      final note = NoteModel(title: 'Original');
      await notifier.addNote(note);

      final updated = note.copyWith(title: 'Updated');
      await notifier.updateNote(updated);

      expect(notifier.state.single.title, 'Updated');
      final data = await firestoreDoc(note.id);
      expect(data!['title'], 'Updated');
    });

    test('deleteNote removes from state and Firestore', () async {
      final note = NoteModel(title: 'ToDelete');
      await notifier.addNote(note);

      await notifier.deleteNote(note.id);

      expect(notifier.state, isEmpty);
      expect(await firestoreDoc(note.id), isNull);
    });

    test('clearAll removes every note', () async {
      await notifier.addNote(NoteModel(title: 'A'));
      await notifier.addNote(NoteModel(title: 'B'));

      await notifier.clearAll();

      expect(notifier.state, isEmpty);
    });
  });

  group('NotesNotifier trash lifecycle', () {
    test('softDelete sets deletedAt and clears archive flag', () async {
      final note = NoteModel(title: 'Archived', isArchived: true);
      await notifier.addNote(note);

      await notifier.softDelete(note.id);

      final result = notifier.state.single;
      expect(result.deletedAt, isNotNull);
      expect(result.isArchived, isFalse);
    });

    test('restoreFromTrash clears deletedAt', () async {
      final note = NoteModel(title: 'Trashed');
      await notifier.addNote(note);
      await notifier.softDelete(note.id);

      await notifier.restoreFromTrash(note.id);

      expect(notifier.state.single.deletedAt, isNull);
    });

    test('permanentlyDelete removes the note entirely', () async {
      final note = NoteModel(title: 'Gone');
      await notifier.addNote(note);
      await notifier.softDelete(note.id);

      await notifier.permanentlyDelete(note.id);

      expect(notifier.state, isEmpty);
      expect(await firestoreDoc(note.id), isNull);
    });
  });

  group('NotesNotifier toggles', () {
    test('toggleArchive flips isArchived', () async {
      final note = NoteModel(title: 'A');
      await notifier.addNote(note);

      await notifier.toggleArchive(note.id);
      expect(notifier.state.single.isArchived, isTrue);

      await notifier.toggleArchive(note.id);
      expect(notifier.state.single.isArchived, isFalse);
    });

    test('togglePin flips isPinned', () async {
      final note = NoteModel(title: 'A');
      await notifier.addNote(note);

      await notifier.togglePin(note.id);

      expect(notifier.state.single.isPinned, isTrue);
    });
  });

  group('NotesNotifier tags', () {
    test('renameTag updates the tag only on notes that have it', () async {
      final withTag = NoteModel(title: 'One', tags: ['work']);
      final other = NoteModel(title: 'Two', tags: ['personal']);
      await notifier.addNote(withTag);
      await notifier.addNote(other);

      await notifier.renameTag('work', 'job');

      expect(
        notifier.state.firstWhere((n) => n.id == withTag.id).tags,
        ['job'],
      );
      expect(
        notifier.state.firstWhere((n) => n.id == other.id).tags,
        ['personal'],
      );
    });

    test('deleteTag removes the tag from every note that has it', () async {
      final note = NoteModel(title: 'One', tags: ['work', 'urgent']);
      await notifier.addNote(note);

      await notifier.deleteTag('work');

      expect(notifier.state.single.tags, ['urgent']);
    });
  });

  test('reorderNotes moves a note to its new position', () async {
    final a = NoteModel(title: 'A');
    final b = NoteModel(title: 'B');
    final c = NoteModel(title: 'C');
    // addNote prepends, so the resulting state order is [C, B, A].
    await notifier.addNote(a);
    await notifier.addNote(b);
    await notifier.addNote(c);

    await notifier.reorderNotes(notifier.state, 0, 2);

    expect(notifier.state.map((n) => n.title).toList(), ['B', 'C', 'A']);
  });

  test(
    'toggling a non-existent note id throws without touching state',
    () async {
      final note = NoteModel(title: 'Untouched');
      await notifier.addNote(note);

      expect(
        () => notifier.toggleArchive('non-existent-id'),
        throwsStateError,
      );
      expect(notifier.state.single.id, note.id);
    },
  );

  group('Derived providers', () {
    test('activeNotesProvider/archivedNotesProvider/trashedNotesProvider '
        'filter by archive/trash status', () async {
      final container = ProviderContainer(
        overrides: [notesProvider.overrideWith((ref) => notifier)],
      );
      addTearDown(container.dispose);

      final active = NoteModel(title: 'Active');
      final archived = NoteModel(title: 'Archived', isArchived: true);
      final trashed = NoteModel(title: 'Trashed', deletedAt: DateTime.now());
      await notifier.addNote(active);
      await notifier.addNote(archived);
      await notifier.addNote(trashed);

      expect(
        container.read(activeNotesProvider).map((n) => n.title),
        ['Active'],
      );
      expect(
        container.read(archivedNotesProvider).map((n) => n.title),
        ['Archived'],
      );
      expect(
        container.read(trashedNotesProvider).map((n) => n.title),
        ['Trashed'],
      );
    });
  });
}
