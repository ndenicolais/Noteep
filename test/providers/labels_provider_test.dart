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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/labels_provider.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_container.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  Future<ProviderContainer> containerWith(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final instance = await SharedPreferences.getInstance();
    return createTestContainer(
      firestore,
      overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
    );
  }

  Future<List<String>> remoteNames() async {
    final snap = await firestore.collection('users/test-uid/labels').get();
    return snap.docs.map((d) => d.data()['name'] as String).toList()..sort();
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  group('LabelsNotifier', () {
    test('add trims, skips blanks and duplicates, persists', () async {
      final container = await containerWith({});
      final notifier = container.read(labelsProvider.notifier);
      await notifier.reload();

      await notifier.add('  Work ');
      await notifier.add('Work');
      await notifier.add('   ');

      expect(container.read(labelsProvider).map((l) => l.name), ['Work']);
      expect(await remoteNames(), ['Work']);
    });

    test('rename updates the label, or merges into an existing one', () async {
      final container = await containerWith({});
      final notifier = container.read(labelsProvider.notifier);
      await notifier.reload();
      await notifier.addAll(['Work', 'Home', 'Job']);

      await notifier.rename('Work', 'Office');
      await notifier.rename('Home', 'Job');

      expect(await remoteNames(), ['Job', 'Office']);
    });

    test('delete removes the label from Firestore', () async {
      final container = await containerWith({});
      final notifier = container.read(labelsProvider.notifier);
      await notifier.reload();
      await notifier.addAll(['Work', 'Home']);

      await notifier.delete('Work');

      expect(await remoteNames(), ['Home']);
    });

    test('moves labels kept on the device into Firestore once', () async {
      final container = await containerWith({
        legacyLabelsPrefsKey: ['Work', 'Home'],
      });
      await container.read(labelsProvider.notifier).reload();

      expect(await remoteNames(), ['Home', 'Work']);
      expect(
        container
            .read(sharedPreferencesProvider)
            .getStringList(legacyLabelsPrefsKey),
        isNull,
      );
    });
  });

  group('label providers', () {
    test('allTagsProvider merges labels and tags found on notes', () async {
      final container = await containerWith({});
      await container.read(labelsProvider.notifier).reload();
      await container.read(labelsProvider.notifier).add('Work');
      await container
          .read(notesProvider.notifier)
          .addNote(NoteModel(title: 'A', tags: ['Home', 'Work']));

      expect(container.read(allTagsProvider), ['Home', 'Work']);
    });

    test('notesWithTagProvider lists active then archived notes', () async {
      final container = await containerWith({});
      final notes = container.read(notesProvider.notifier);
      final archived = NoteModel(
        title: 'Archived',
        tags: ['Work'],
        isArchived: true,
      );
      final active = NoteModel(title: 'Active', tags: ['Work']);
      final trashed = NoteModel(
        title: 'Trashed',
        tags: ['Work'],
        deletedAt: DateTime.now(),
      );
      await notes.addNote(archived);
      await notes.addNote(active);
      await notes.addNote(trashed);
      await notes.addNote(NoteModel(title: 'Other', tags: ['Home']));

      final sub = container.listen(notesWithTagProvider('Work'), (_, _) {});
      expect(sub.read().map((n) => n.id), [active.id, archived.id]);
      expect(container.read(tagNoteCountsProvider)['Work'], 2);
    });
  });
}
