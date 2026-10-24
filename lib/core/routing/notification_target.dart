// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';

enum NotificationTargetType { note, task, event }

/// What a reminder notification opens when tapped, carried in the
/// notification payload as `"<type>:<id>"` (e.g. `note:3f2a…`).
class NotificationTarget {
  const NotificationTarget(this.type, this.id);

  const NotificationTarget.note(String id)
    : this(NotificationTargetType.note, id);
  const NotificationTarget.task(String id)
    : this(NotificationTargetType.task, id);
  const NotificationTarget.event(String id)
    : this(NotificationTargetType.event, id);

  final NotificationTargetType type;
  final String id;

  String encode() => '${type.name}:$id';

  /// Parses an [encode]d payload; `null` for a missing or malformed one
  /// (e.g. notifications scheduled before payloads existed).
  static NotificationTarget? parse(String? payload) {
    if (payload == null) return null;
    final sep = payload.indexOf(':');
    if (sep <= 0 || sep == payload.length - 1) return null;
    final name = payload.substring(0, sep);
    final type =
        NotificationTargetType.values.where((t) => t.name == name).firstOrNull;
    if (type == null) return null;
    return NotificationTarget(type, payload.substring(sep + 1));
  }

  /// The live (not trashed) item this target points to, or `null` if it is
  /// not in the given lists (not loaded yet, deleted or trashed).
  Object? resolve({
    required List<NoteModel> notes,
    required List<TaskModel> tasks,
    required List<CalendarEventModel> events,
  }) {
    return switch (type) {
      NotificationTargetType.note =>
        notes.where((n) => n.id == id && n.deletedAt == null).firstOrNull,
      NotificationTargetType.task =>
        tasks.where((t) => t.id == id && t.deletedAt == null).firstOrNull,
      NotificationTargetType.event =>
        events.where((e) => e.id == id && e.deletedAt == null).firstOrNull,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationTarget && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'NotificationTarget(${encode()})';
}
