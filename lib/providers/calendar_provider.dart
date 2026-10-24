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
import '../models/calendar_model.dart';
import 'auth_provider.dart';
import 'core_providers.dart';
import 'sync_provider.dart';

// ─── Calendar Notifier ────────────────────────────────────────────────────────

class CalendarNotifier extends Notifier<List<CalendarEventModel>>
    with FirestoreListMutations<CalendarEventModel> {
  late String _uid;

  @override
  List<CalendarEventModel> build() {
    _uid = ref.watch(currentUidProvider);
    ref.watch(firestoreProvider);
    _load().ignore();
    return [];
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      db.collection('users').doc(_uid).collection('calendar_events');

  /// Re-fetches all events from Firestore, replacing local state.
  @override
  Future<void> reload() => _load(replace: true);

  Future<void> _load({bool replace = false}) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final snap = await _col.get();
    // The user changed while this fetch was in flight.
    if (uid != _uid) return;
    final events =
        snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return CalendarEventModel.fromJson(data);
        }).toList();
    if (replace) {
      state = events;
      return;
    }
    // Merge instead of replace: an event added locally while this initial
    // fetch was in flight must not be wiped out by it.
    final existingIds = state.map((e) => e.id).toSet();
    state = [...state, ...events.where((e) => !existingIds.contains(e.id))];
    // Not awaited: offline the deletes stay queued.
    _purgeOldTrashFirestore().ignore();
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
    await mutate(
      (current) =>
          current
              .where((e) => e.deletedAt == null || e.deletedAt!.isAfter(cutoff))
              .toList(),
      () => commitInChunks(
        expired.map((e) => (WriteBatch b) => b.delete(_col.doc(e.id))).toList(),
      ),
    );
  }

  void purgeOldTrash() {
    _purgeOldTrashFirestore();
  }

  Future<void> addEvent(CalendarEventModel event) =>
      mutate((current) => [event, ...current], () => _saveDoc(event));

  Future<void> updateEvent(CalendarEventModel updated) => mutate(
    (current) => current.map((e) => e.id == updated.id ? updated : e).toList(),
    () => _saveDoc(updated),
  );

  Future<void> softDelete(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(deletedAt: DateTime.now(), isArchived: false);
    await mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(clearDeletedAt: true);
    await mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> permanentlyDelete(String id) => mutate(
    (current) => current.where((e) => e.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> toggleArchive(String id) async {
    final updated = state
        .firstWhere((e) => e.id == id)
        .copyWith(isArchived: !state.firstWhere((e) => e.id == id).isArchived);
    await mutate(
      (current) => current.map((e) => e.id == id ? updated : e).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> deleteEvent(String id) => mutate(
    (current) => current.where((e) => e.id != id).toList(),
    () => _deleteDoc(id),
  );

  /// Import events from an external source (e.g. ICS file), skipping
  /// events whose [id] already exists in the current state.
  Future<void> importEvents(List<CalendarEventModel> events) async {
    final existingIds = state.map((e) => e.id).toSet();
    final newEvents = events.where((e) => !existingIds.contains(e.id)).toList();
    if (newEvents.isEmpty) return;
    await mutate(
      (current) => [...newEvents, ...current],
      () => commitInChunks(
        newEvents
            .map((e) => (WriteBatch b) => b.set(_col.doc(e.id), e.toJson()))
            .toList(),
      ),
    );
  }

  /// Permanently delete all calendar events.
  Future<void> clearAllEvents() {
    final ids = state.map((e) => e.id).toList();
    return mutate(
      (_) => [],
      () => commitInChunks(
        ids.map((id) => (WriteBatch b) => b.delete(_col.doc(id))).toList(),
      ),
    );
  }

  /// Replaces the entire calendar collection (used for full backup restore).
  /// Events missing from [events] are deleted from Firestore too, otherwise
  /// they would reappear on the next load.
  Future<void> replaceAll(List<CalendarEventModel> events) {
    final keep = {for (final e in events) e.id};
    final stale = [
      for (final e in state)
        if (!keep.contains(e.id)) e.id,
    ];
    return mutate(
      (_) => events,
      () => commitInChunks([
        for (final id in stale) (WriteBatch b) => b.delete(_col.doc(id)),
        for (final e in events)
          (WriteBatch b) => b.set(_col.doc(e.id), e.toJson()),
      ]),
    );
  }
}

final calendarProvider =
    NotifierProvider<CalendarNotifier, List<CalendarEventModel>>(
      CalendarNotifier.new,
    );

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

final calendarSearchQueryProvider = valueStateProvider<String>('');

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
