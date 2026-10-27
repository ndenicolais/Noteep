// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/label_model.dart';
import 'auth_provider.dart';
import 'core_providers.dart';
import 'sync_provider.dart';

/// SharedPreferences key where older versions kept the labels, only on the
/// device.
const legacyLabelsPrefsKey = 'custom_labels';

/// The user's labels, synced in `users/{uid}/labels` so they follow the
/// account to other devices. Renaming or deleting a label on the notes that
/// use it is up to `NotesNotifier.renameTag`/`deleteTag`.
class LabelsNotifier extends Notifier<List<LabelModel>>
    with FirestoreListMutations<LabelModel> {
  late String _uid;

  @override
  List<LabelModel> build() {
    _uid = ref.watch(currentUidProvider);
    ref.watch(firestoreProvider);
    _load().ignore();
    return [];
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      db.collection('users').doc(_uid).collection('labels');

  /// Re-fetches all labels from Firestore, replacing local state.
  @override
  Future<void> reload() => _load(replace: true);

  Future<void> _load({bool replace = false}) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final snap = await _col.get();
    if (uid != _uid) return;
    final labels =
        snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return LabelModel.fromJson(data);
        }).toList();
    if (replace) {
      state = labels;
    } else {
      final existingIds = state.map((l) => l.id).toSet();
      state = [...state, ...labels.where((l) => !existingIds.contains(l.id))];
    }
    // Shared by overlapping loads, so the labels aren't migrated twice.
    await (_migration ??= _migrateLocalLabels().whenComplete(
      () => _migration = null,
    ));
  }

  Future<void>? _migration;

  /// Moves the labels that older versions kept only on this device into
  /// Firestore, then forgets the local copy.
  Future<void> _migrateLocalLabels() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final local = prefs.getStringList(legacyLabelsPrefsKey);
    if (local == null) return;
    await addAll(local);
    await prefs.remove(legacyLabelsPrefsKey);
  }

  bool _exists(String name) => state.any((l) => l.name == name);

  /// Adds the labels in [names] that don't exist yet (trimmed, blanks
  /// skipped).
  Future<void> addAll(Iterable<String> names) async {
    final added = <LabelModel>[];
    for (final name in names.map((n) => n.trim())) {
      if (name.isEmpty || _exists(name) || added.any((l) => l.name == name)) {
        continue;
      }
      added.add(LabelModel(name: name));
    }
    if (added.isEmpty) return;
    await mutate(
      (current) => [...current, ...added],
      () => commitInChunks([
        for (final l in added)
          (WriteBatch b) => b.set(_col.doc(l.id), l.toJson()),
      ]),
    );
  }

  Future<void> add(String name) => addAll([name]);

  /// Renames [oldName] to [newName]; if a label called [newName] already
  /// exists the two are merged.
  Future<void> rename(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return;
    final label = state.where((l) => l.name == oldName).firstOrNull;
    if (label == null) return add(trimmed);
    if (_exists(trimmed)) return delete(oldName);
    final updated = label.copyWith(name: trimmed);
    await mutate(
      (current) => current.map((l) => l.id == label.id ? updated : l).toList(),
      () => _col.doc(label.id).set(updated.toJson()),
    );
  }

  Future<void> delete(String name) async {
    final ids = state.where((l) => l.name == name).map((l) => l.id).toList();
    if (ids.isEmpty) return;
    await mutate(
      (current) => current.where((l) => l.name != name).toList(),
      () => commitInChunks([
        for (final id in ids) (WriteBatch b) => b.delete(_col.doc(id)),
      ]),
    );
  }
}

final labelsProvider = NotifierProvider<LabelsNotifier, List<LabelModel>>(
  LabelsNotifier.new,
);
