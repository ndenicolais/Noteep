// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/tasks_provider.dart';
import 'app_router.dart';
import 'home_widget_action.dart';

/// Handles taps on the Android home screen widgets: a quick action (or a list
/// widget's "+") opens an empty note/task/event editor, like the in-app "+"
/// buttons do; a list widget row opens that item, its header its section.
///
/// Wraps the signed-in home, so it sits under `MaterialApp`'s navigator. A
/// cold start from a widget is read once per process: the launch intent
/// stays on the activity, and this widget is rebuilt on every sign-in.
/// Android only; on web it just returns [child].
class HomeWidgetLaunchHandler extends ConsumerStatefulWidget {
  const HomeWidgetLaunchHandler({
    super.key,
    required this.child,
    this.initialUri,
    this.clicks,
  });

  final Widget child;

  /// Overrides for tests; default to the `home_widget` plugin.
  final Future<Uri?> Function()? initialUri;
  final Stream<Uri?>? clicks;

  @visibleForTesting
  static bool initialLaunchHandled = false;

  @override
  ConsumerState<HomeWidgetLaunchHandler> createState() =>
      _HomeWidgetLaunchHandlerState();
}

class _HomeWidgetLaunchHandlerState
    extends ConsumerState<HomeWidgetLaunchHandler> {
  /// How long a row tapped on a cold start waits for its item to load.
  static const _loadTimeout = Duration(seconds: 20);

  StreamSubscription<Uri?>? _clicks;
  ProviderSubscription<Object?>? _waiting;
  Timer? _waitTimeout;

  bool get _enabled =>
      widget.clicks != null ||
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  @override
  void initState() {
    super.initState();
    if (!_enabled) return;
    // Taps while the app is already running (singleTop: onNewIntent).
    _clicks = (widget.clicks ?? HomeWidget.widgetClicked).listen(_handle);
    if (!HomeWidgetLaunchHandler.initialLaunchHandled) {
      HomeWidgetLaunchHandler.initialLaunchHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final uri =
            await (widget.initialUri ??
                HomeWidget.initiallyLaunchedFromHomeWidget)();
        _handle(uri);
      });
    }
  }

  @override
  void dispose() {
    _clicks?.cancel();
    _stopWaiting();
    super.dispose();
  }

  void _handle(Uri? uri) {
    if (!mounted) return;
    if (HomeWidgetOpenItem.parse(uri) case final item?) {
      _openItem(item);
      return;
    }
    if (HomeWidgetSection.parse(uri) case final section?) {
      _openSection(section);
      return;
    }
    final action = HomeWidgetAction.parse(uri);
    if (action == null) return;
    switch (action) {
      case HomeWidgetAction.newNote:
        AppNav.openNote(context, NoteModel(type: NoteType.note));
      case HomeWidgetAction.newTask:
        AppNav.openTask(context, TaskModel());
      case HomeWidgetAction.newEvent:
        final now = DateTime.now();
        AppNav.openEvent(
          context,
          CalendarEventModel(startTime: now, endTime: now),
        );
    }
  }

  void _openSection(HomeWidgetSection section) {
    _stopWaiting();
    final navigator = Navigator.of(context)..popUntil((r) => r.isFirst);
    switch (section) {
      case HomeWidgetSection.notes:
        break; // The home itself.
      case HomeWidgetSection.tasks:
        navigator.pushNamed(AppRoutes.tasks);
      case HomeWidgetSection.calendar:
        navigator.pushNamed(AppRoutes.calendar);
    }
  }

  /// Opens the tapped row's item. On a cold start the lists may still be
  /// loading, so a missing item is waited for (up to [_loadTimeout]).
  void _openItem(HomeWidgetOpenItem item) {
    _stopWaiting();
    switch (item.kind) {
      case HomeWidgetItemKind.note:
        _openWhenLoaded(
          notesByIdProvider,
          item.id,
          (note) => AppNav.openNote(context, note),
        );
      case HomeWidgetItemKind.task:
        _openWhenLoaded(
          tasksByIdProvider,
          item.id,
          (task) => AppNav.viewTask(context, task),
        );
      case HomeWidgetItemKind.event:
        _openWhenLoaded(
          eventsByIdProvider,
          item.id,
          (event) => AppNav.viewEvent(context, event),
        );
    }
  }

  void _openWhenLoaded<T>(
    ProviderListenable<Map<String, T>> byId,
    String id,
    void Function(T item) open,
  ) {
    final found = ref.read(byId)[id];
    if (found != null) {
      open(found);
      return;
    }
    _waiting = ref.listenManual<Map<String, T>>(byId, (_, items) {
      final item = items[id];
      if (item == null || !mounted) return;
      _stopWaiting();
      open(item);
    });
    _waitTimeout = Timer(_loadTimeout, _stopWaiting);
  }

  void _stopWaiting() {
    _waiting?.close();
    _waiting = null;
    _waitTimeout?.cancel();
    _waitTimeout = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
