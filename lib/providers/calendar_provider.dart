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
import '../models/calendar_model.dart';
import 'auth_provider.dart';

// ─── Calendar Notifier ────────────────────────────────────────────────────────

class CalendarNotifier extends StateNotifier<List<CalendarEventModel>> {
  CalendarNotifier(this._uid, this._db) : super([]) {
    _load();
  }

  final String _uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('calendar_events');

  /// Applies [apply] to state immediately (optimistic update), then runs
  /// [persist]; if it throws, the state change is rolled back and the error
  /// is rethrown instead of being silently swallowed.
  Future<void> _mutate(
    List<CalendarEventModel> Function(List<CalendarEventModel> current) apply,
    Future<void> Function() persist,
  ) async {
    final previous = state;
    state = apply(previous);
    try {
      await persist();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  /// Commits Firestore batch writes in chunks of 500 (Firestore's per-batch
  /// operation limit).
  Future<void> _commitInChunks(
    List<void Function(WriteBatch batch)> ops,
  ) async {
    for (var i = 0; i < ops.length; i += 500) {
      final batch = _db.batch();
      for (final op in ops.skip(i).take(500)) {
        op(batch);
      }
      await batch.commit();
    }
  }

  Future<void> _load() async {
    if (_uid.isEmpty) return;
    final snap = await _col.get();
    final events =
        snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return CalendarEventModel.fromJson(data);
        }).toList();
    // Merge instead of replace: an event added locally while this initial
    // fetch was in flight must not be wiped out by it.
    final existingIds = state.map((e) => e.id).toSet();
    state = [...state, ...events.where((e) => !existingIds.contains(e.id))];
    await _purgeOldTrashFirestore();
  }

  Future<void> _saveDoc(CalendarEventModel event) async {
    await _col.doc(event.id).set(event.toJson());
  }

  Future<void> _deleteDoc(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> _purgeOldTrashFirestore() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final expired =
        state
            .where((e) => e.deletedAt != null && e.deletedAt!.isBefore(cutoff))
            .toList();
    if (expired.isEmpty) return;
    state =
        state
            .where((e) => e.deletedAt == null || e.deletedAt!.isAfter(cutoff))
            .toList();
    await _commitInChunks(
      expired.map((e) => (WriteBatch b) => b.delete(_col.doc(e.id))).toList(),
    );
  }

  void purgeOldTrash() {
    _purgeOldTrashFirestore();
  }

  Future<void> addEvent(CalendarEventModel event) =>
      _mutate((current) => [event, ...current], () => _saveDoc(event));

  Future<void> updateEvent(CalendarEventModel updated) => _mutate(
    (current) => current.map((e) => e.id == updated.id ? updated : e).toList(),
    () => _saveDoc(updated),
  );

  Future<void> softDelete(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(deletedAt: DateTime.now(), isArchived: false);
    await _mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(clearDeletedAt: true);
    await _mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> permanentlyDelete(String id) => _mutate(
    (current) => current.where((e) => e.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> toggleArchive(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(isArchived: !state.firstWhere((e) => e.id == id).isArchived);
    await _mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> deleteEvent(String id) => _mutate(
    (current) => current.where((e) => e.id != id).toList(),
    () => _deleteDoc(id),
  );

  /// Import events from an external source (e.g. ICS file), skipping
  /// events whose [id] already exists in the current state.
  Future<void> importEvents(List<CalendarEventModel> events) async {
    final existingIds = state.map((e) => e.id).toSet();
    final newEvents =
        events.where((e) => !existingIds.contains(e.id)).toList();
    if (newEvents.isEmpty) return;
    await _mutate(
      (current) => [...newEvents, ...current],
      () => _commitInChunks(
        newEvents
            .map((e) => (WriteBatch b) => b.set(_col.doc(e.id), e.toJson()))
            .toList(),
      ),
    );
  }

  /// Permanently delete all calendar events.
  Future<void> clearAllEvents() {
    final ids = state.map((e) => e.id).toList();
    return _mutate(
      (_) => [],
      () => _commitInChunks(
        ids.map((id) => (WriteBatch b) => b.delete(_col.doc(id))).toList(),
      ),
    );
  }

  /// Replaces the entire calendar collection (used for full backup restore).
  Future<void> replaceAll(List<CalendarEventModel> events) => _mutate(
    (_) => events,
    () => _commitInChunks(
      events
          .map((e) => (WriteBatch b) => b.set(_col.doc(e.id), e.toJson()))
          .toList(),
    ),
  );
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, List<CalendarEventModel>>((ref) {
      final user = ref.watch(currentUserProvider);
      return CalendarNotifier(user?.uid ?? '', FirebaseFirestore.instance);
    });

final activeEventsProvider = Provider<List<CalendarEventModel>>((ref) {
  final events = ref.watch(calendarProvider);
  return events.where((e) => !e.isArchived && e.deletedAt == null).toList();
});

final archivedEventsProvider = Provider<List<CalendarEventModel>>((ref) {
  final events = ref.watch(calendarProvider);
  return events.where((e) => e.isArchived && e.deletedAt == null).toList();
});

final trashedEventsProvider = Provider<List<CalendarEventModel>>((ref) {
  final events = ref.watch(calendarProvider);
  return events.where((e) => e.deletedAt != null).toList();
});

final calendarSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCalendarEventsProvider = Provider<List<CalendarEventModel>>((
  ref,
) {
  final events = ref.watch(activeEventsProvider);
  final query = ref.watch(calendarSearchQueryProvider);

  if (query.isEmpty) return events;

  return events
      .where(
        (e) =>
            e.title.toLowerCase().contains(query.toLowerCase()) ||
            e.description.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});
