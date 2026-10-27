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
import '../models/note_model.dart';
import 'auth_provider.dart';
import 'core_providers.dart';
import 'sync_provider.dart';

// ─── Notes Notifier ───────────────────────────────────────────────────────────

/// Notes of the signed-in user ([currentUidProvider]), loaded once from
/// Firestore and then kept in memory with optimistic updates. Rebuilt (and
/// reloaded) when the user changes.
class NotesNotifier extends Notifier<List<NoteModel>>
    with FirestoreListMutations<NoteModel> {
  late String _uid;

  @override
  List<NoteModel> build() {
    _uid = ref.watch(currentUidProvider);
    ref.watch(firestoreProvider);
    _load();
    return [];
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      db.collection('users').doc(_uid).collection('notes');

  void _onLoadError(Object? error) =>
      ref.read(notesLoadErrorProvider.notifier).set(error);

  void _onLoadDone() => ref.read(notesLoadingProvider.notifier).set(false);

  /// Re-fetches all notes from Firestore, replacing local state (e.g.
  /// pull-to-refresh after a sync error or edits from another device).
  @override
  Future<void> reload() => _load(replace: true);

  Future<void> _load({bool replace = false}) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    try {
      final snap = await _col.get();
      // The user changed while this fetch was in flight.
      if (uid != _uid) return;
      final notes =
          snap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return NoteModel.fromJson(data);
          }).toList();
      if (replace) {
        state = notes;
      } else {
        // Merge instead of replace: a note added/edited locally while this
        // initial fetch was in flight must not be wiped out by it.
        final existingIds = state.map((n) => n.id).toSet();
        state = [...state, ...notes.where((n) => !existingIds.contains(n.id))];
      }
      _onLoadError(null);
      // Not awaited: offline the deletes stay queued and must not hold up
      // the loading flag.
      _purgeOldTrashFirestore().ignore();
    } catch (e) {
      _onLoadError(e);
    } finally {
      _onLoadDone();
    }
  }

  // ── Private Firestore helpers ─────────────────────────────────────────────

  Future<void> _saveDoc(NoteModel note) async {
    await _col.doc(note.id).set(note.toJson());
  }

  Future<void> _deleteDoc(String id) async {
    await _col.doc(id).delete();
  }

  // ── Public mutations ──────────────────────────────────────────────────────

  Future<void> addNote(NoteModel note) =>
      mutate((current) => [note, ...current], () => _saveDoc(note));

  Future<void> updateNote(NoteModel updated) => mutate(
    (current) => current.map((n) => n.id == updated.id ? updated : n).toList(),
    () => _saveDoc(updated),
  );

  Future<void> deleteNote(String id) => mutate(
    (current) => current.where((n) => n.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> softDelete(String id) async {
    final updated = state
        .firstWhere((n) => n.id == id)
        .copyWith(deletedAt: DateTime.now(), isArchived: false);
    await mutate(
      (current) => current.map((n) => n.id == id ? updated : n).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final updated = state
        .firstWhere((n) => n.id == id)
        .copyWith(clearDeletedAt: true);
    await mutate(
      (current) => current.map((n) => n.id == id ? updated : n).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> permanentlyDelete(String id) => mutate(
    (current) => current.where((n) => n.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> emptyTrash() async {
    final trashed = state.where((n) => n.deletedAt != null).toList();
    await mutate(
      (current) => current.where((n) => n.deletedAt == null).toList(),
      () => commitInChunks(
        trashed.map((n) => (WriteBatch b) => b.delete(_col.doc(n.id))).toList(),
      ),
    );
  }

  Future<void> _purgeOldTrashFirestore() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final expired =
        state
            .where((n) => n.deletedAt != null && n.deletedAt!.isBefore(cutoff))
            .toList();
    if (expired.isEmpty) return;
    await mutate(
      (current) =>
          current
              .where((n) => n.deletedAt == null || n.deletedAt!.isAfter(cutoff))
              .toList(),
      () => commitInChunks(
        expired.map((n) => (WriteBatch b) => b.delete(_col.doc(n.id))).toList(),
      ),
    );
  }

  void purgeOldTrash() {
    // Kept for API compatibility; async version runs on load.
    _purgeOldTrashFirestore();
  }

  Future<void> toggleArchive(String id) async {
    final updated = state
        .firstWhere((n) => n.id == id)
        .copyWith(isArchived: !state.firstWhere((n) => n.id == id).isArchived);
    await mutate(
      (current) => current.map((n) => n.id == id ? updated : n).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> togglePin(String id) async {
    final updated = state
        .firstWhere((n) => n.id == id)
        .copyWith(isPinned: !state.firstWhere((n) => n.id == id).isPinned);
    await mutate(
      (current) => current.map((n) => n.id == id ? updated : n).toList(),
      () => _saveDoc(updated),
    );
  }

  /// Reorders a set of currently-displayed notes within the full state list.
  Future<void> reorderNotes(
    List<NoteModel> visibleNotes,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) newIndex--;

    final ids = visibleNotes.map((n) => n.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);

    final visibleSet = visibleNotes.map((n) => n.id).toSet();
    final noteMap = {for (final n in state) n.id: n};

    final newState = List<NoteModel>.from(state);
    int vi = 0;
    for (int i = 0; i < newState.length; i++) {
      if (visibleSet.contains(newState[i].id)) {
        newState[i] = noteMap[ids[vi++]]!;
      }
    }
    final reordered = ids.map((id) => noteMap[id]!).toList();
    await mutate(
      (_) => newState,
      // Only the reordered subset actually changed; writing just those keeps
      // this within Firestore's 500-op batch limit even on large
      // collections.
      () => commitInChunks(
        reordered
            .map((n) => (WriteBatch b) => b.set(_col.doc(n.id), n.toJson()))
            .toList(),
      ),
    );
  }

  /// Renames a tag across all notes that have it. A note that already has
  /// [newTag] keeps it only once.
  Future<void> renameTag(String oldTag, String newTag) async {
    if (newTag.trim().isEmpty || oldTag == newTag) return;
    final affected = state.where((n) => n.tags.contains(oldTag)).toList();
    if (affected.isEmpty) return;
    final updates = {
      for (final n in affected)
        n.id: n.copyWith(
          tags:
              {
                for (final t in n.tags) t == oldTag ? newTag.trim() : t,
              }.toList(),
        ),
    };
    await mutate(
      (current) => current.map((n) => updates[n.id] ?? n).toList(),
      () => commitInChunks(
        updates.values
            .map((n) => (WriteBatch b) => b.set(_col.doc(n.id), n.toJson()))
            .toList(),
      ),
    );
  }

  /// Removes a tag from all notes that have it.
  Future<void> deleteTag(String tag) async {
    final affected = state.where((n) => n.tags.contains(tag)).toList();
    if (affected.isEmpty) return;
    final updates = {
      for (final n in affected)
        n.id: n.copyWith(tags: n.tags.where((t) => t != tag).toList()),
    };
    await mutate(
      (current) => current.map((n) => updates[n.id] ?? n).toList(),
      () => commitInChunks(
        updates.values
            .map((n) => (WriteBatch b) => b.set(_col.doc(n.id), n.toJson()))
            .toList(),
      ),
    );
  }

  /// Replaces the entire notes collection (used for full backup restore).
  /// Notes missing from [notes] are deleted from Firestore too, otherwise
  /// they would reappear on the next load.
  Future<void> replaceAll(List<NoteModel> notes) {
    final keep = {for (final n in notes) n.id};
    final stale = [
      for (final n in state)
        if (!keep.contains(n.id)) n.id,
    ];
    return mutate(
      (_) => notes,
      () => commitInChunks([
        for (final id in stale) (WriteBatch b) => b.delete(_col.doc(id)),
        for (final n in notes)
          (WriteBatch b) => b.set(_col.doc(n.id), n.toJson()),
      ]),
    );
  }

  /// Permanently removes all notes.
  Future<void> clearAll() {
    final ids = state.map((n) => n.id).toList();
    return mutate(
      (_) => [],
      () => commitInChunks(
        ids.map((id) => (WriteBatch b) => b.delete(_col.doc(id))).toList(),
      ),
    );
  }
}

/// Set (or cleared) whenever the initial Firestore load in [NotesNotifier]
/// succeeds or fails, so the UI can tell a real sync error apart from a
/// genuinely empty notes list.
final notesLoadErrorProvider = valueStateProvider<Object?>(null);

/// True while the initial Firestore load in [NotesNotifier] is in flight,
/// so the UI can tell "still loading" apart from a genuinely empty list.
final notesLoadingProvider = valueStateProvider<bool>(true);

final notesProvider = NotifierProvider<NotesNotifier, List<NoteModel>>(
  NotesNotifier.new,
);

/// Every note by id, rebuilt once per change of [notesProvider].
final notesByIdProvider = Provider<Map<String, NoteModel>>((ref) {
  return {for (final n in ref.watch(notesProvider)) n.id: n};
});

/// A single note: notifies only when that note changes (unchanged notes
/// keep the same instance across mutations), so a card watching it is not
/// rebuilt by edits to other notes.
final noteByIdProvider = Provider.autoDispose.family<NoteModel?, String>((
  ref,
  id,
) {
  return ref.watch(notesByIdProvider.select((notes) => notes[id]));
});

final activeNotesProvider = Provider<List<NoteModel>>((ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((n) => !n.isArchived && n.deletedAt == null).toList();
});

final archivedNotesProvider = Provider<List<NoteModel>>((ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((n) => n.isArchived && n.deletedAt == null).toList();
});

final trashedNotesProvider = Provider<List<NoteModel>>((ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((n) => n.deletedAt != null).toList();
});
