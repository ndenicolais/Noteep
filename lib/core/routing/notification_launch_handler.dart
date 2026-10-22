// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/notification_service.dart';
import 'app_router.dart';
import 'notification_target.dart';

/// Opens the note/task/event of a tapped reminder notification.
///
/// Wraps the signed-in home, so it sits under `MaterialApp`'s navigator.
/// A target arriving before the data is loaded (cold start from the
/// notification) waits for the list to load: notes and tasks until their
/// loading flag clears, events — which have no such flag — up to
/// [eventLoadTimeout]. An item that never shows up (deleted or trashed)
/// shows a snackbar instead.
class NotificationLaunchHandler extends ConsumerStatefulWidget {
  NotificationLaunchHandler({
    super.key,
    required this.child,
    ValueNotifier<NotificationTarget?>? targets,
    this.eventLoadTimeout = const Duration(seconds: 10),
  }) : targets = targets ?? NotificationService.instance.pendingTarget;

  final Widget child;
  final ValueNotifier<NotificationTarget?> targets;
  final Duration eventLoadTimeout;

  @override
  ConsumerState<NotificationLaunchHandler> createState() =>
      _NotificationLaunchHandlerState();
}

class _NotificationLaunchHandlerState
    extends ConsumerState<NotificationLaunchHandler> {
  Timer? _eventTimeout;
  bool _eventTimedOut = false;

  @override
  void initState() {
    super.initState();
    widget.targets.addListener(_onTarget);
    // Re-check whenever the data a pending target may be waiting for changes.
    for (final p in <ProviderListenable<Object?>>[
      notesProvider,
      notesLoadingProvider,
      tasksProvider,
      tasksLoadingProvider,
      calendarProvider,
    ]) {
      ref.listenManual(p, (_, _) => _tryOpen());
    }
    // A cold-start tap is already pending before this widget exists.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTarget());
  }

  @override
  void dispose() {
    widget.targets.removeListener(_onTarget);
    _eventTimeout?.cancel();
    super.dispose();
  }

  void _onTarget() {
    _eventTimeout?.cancel();
    _eventTimedOut = false;
    if (widget.targets.value?.type == NotificationTargetType.event) {
      _eventTimeout = Timer(widget.eventLoadTimeout, () {
        _eventTimedOut = true;
        _tryOpen();
      });
    }
    _tryOpen();
  }

  void _tryOpen() {
    final target = widget.targets.value;
    if (target == null || !mounted) return;

    final item = target.resolve(
      notes: ref.read(notesProvider),
      tasks: ref.read(tasksProvider),
      events: ref.read(calendarProvider),
    );
    if (item == null) {
      final loaded = switch (target.type) {
        NotificationTargetType.note => !ref.read(notesLoadingProvider),
        NotificationTargetType.task => !ref.read(tasksLoadingProvider),
        NotificationTargetType.event => _eventTimedOut,
      };
      if (!loaded) return; // Still loading: retried on the next change.
      _consume();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Elemento del promemoria non trovato')),
      );
      return;
    }
    _consume();
    _open(item);
  }

  void _consume() {
    _eventTimeout?.cancel();
    widget.targets.value = null;
  }

  Future<void> _open(Object item) async {
    switch (item) {
      case NoteModel note:
        await AppNav.openNote(context, note);
      case TaskModel task:
        await AppNav.openTask(context, task);
      case CalendarEventModel event:
        await AppNav.openEvent(context, event);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
