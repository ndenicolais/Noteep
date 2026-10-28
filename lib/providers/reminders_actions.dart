// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../utils/notification_service.dart';
import 'notes_provider.dart';
import 'tasks_provider.dart';

/// Reminder operations behind the Reminders screen: removing reminders from
/// notes and tasks (one or all the past ones) and undoing the removal.
class RemindersActions {
  RemindersActions(this._ref);

  final Ref _ref;

  NotificationService get _notifications => NotificationService.instance;

  /// Clears the reminder of [notes] and [tasks] and cancels their
  /// notifications. Returns the persistence future.
  Future<void> clear({
    List<NoteModel> notes = const [],
    List<TaskModel> tasks = const [],
  }) async {
    final notesNotifier = _ref.read(notesProvider.notifier);
    final tasksNotifier = _ref.read(tasksProvider.notifier);
    await Future.wait([
      for (final note in notes) ...[
        notesNotifier.updateNote(note.copyWith(clearReminder: true)),
        _notifications.cancelNotification(
          NotificationService.idForNote(note.id),
        ),
      ],
      for (final task in tasks) ...[
        tasksNotifier.updateTask(task.copyWith(clearReminder: true)),
        _notifications.cancelNotification(
          NotificationService.idForTask(task.id),
        ),
      ],
    ]);
  }

  /// Puts back the reminders of [notes] and [tasks] as they were before
  /// [clear], on the current version of each item (still existing ones only),
  /// and reschedules the notifications still in the future.
  Future<void> restore({
    List<NoteModel> notes = const [],
    List<TaskModel> tasks = const [],
  }) async {
    final currentNotes = {for (final n in _ref.read(notesProvider)) n.id: n};
    final currentTasks = {for (final t in _ref.read(tasksProvider)) t.id: t};
    final notesNotifier = _ref.read(notesProvider.notifier);
    final tasksNotifier = _ref.read(tasksProvider.notifier);
    await Future.wait([
      for (final note in notes)
        if (currentNotes[note.id] case final current?) ...[
          notesNotifier.updateNote(current.copyWith(reminder: note.reminder)),
          _notifications.scheduleNoteReminder(
            current.copyWith(reminder: note.reminder),
          ),
        ],
      for (final task in tasks)
        if (currentTasks[task.id] case final current?) ...[
          tasksNotifier.updateTask(current.copyWith(reminder: task.reminder)),
          _notifications.scheduleTaskReminder(
            current.copyWith(reminder: task.reminder),
          ),
        ],
    ]);
  }
}

final remindersActionsProvider = Provider<RemindersActions>(
  RemindersActions.new,
);
