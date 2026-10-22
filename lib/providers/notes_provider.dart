// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import 'auth_provider.dart';
import 'sync_provider.dart';

// ─── SharedPreferences singleton (used by settings providers) ────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Initialize SharedPreferences before using this provider',
  );
});

// ─── Notes Notifier ───────────────────────────────────────────────────────────

class NotesNotifier extends StateNotifier<List<NoteModel>>
    with FirestoreListMutations<NoteModel> {
  NotesNotifier(
    this._uid,
    this._db,
    this._onLoadError,
    this._onLoadDone, {
    this.syncStatus,
  }) : super([]) {
    _load();
  }

  final String _uid;
  final FirebaseFirestore _db;
  final void Function(Object? error) _onLoadError;
  final void Function() _onLoadDone;

  @override
  FirebaseFirestore get db => _db;

  @override
  final SyncStatusNotifier? syncStatus;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('notes');

  /// Re-fetches all notes from Firestore, replacing local state (e.g.
  /// pull-to-refresh after a sync error or edits from another device).
  @override
  Future<void> reload() => _load(replace: true);

  Future<void> _load({bool replace = false}) async {
    if (_uid.isEmpty) return;
    try {
      final snap = await _col.get();
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

  /// Renames a tag across all notes that have it.
  Future<void> renameTag(String oldTag, String newTag) async {
    if (newTag.trim().isEmpty || oldTag == newTag) return;
    final affected = state.where((n) => n.tags.contains(oldTag)).toList();
    if (affected.isEmpty) return;
    final updates = {
      for (final n in affected)
        n.id: n.copyWith(
          tags: n.tags.map((t) => t == oldTag ? newTag.trim() : t).toList(),
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
final notesLoadErrorProvider = StateProvider<Object?>((ref) => null);

/// True while the initial Firestore load in [NotesNotifier] is in flight,
/// so the UI can tell "still loading" apart from a genuinely empty list.
final notesLoadingProvider = StateProvider<bool>((ref) => true);

final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  return NotesNotifier(
    user?.uid ?? '',
    FirebaseFirestore.instance,
    (error) => ref.read(notesLoadErrorProvider.notifier).state = error,
    () => ref.read(notesLoadingProvider.notifier).state = false,
    syncStatus: ref.read(syncStatusProvider.notifier),
  );
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
