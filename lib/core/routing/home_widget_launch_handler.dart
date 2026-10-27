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
import 'package:home_widget/home_widget.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import 'app_router.dart';
import 'home_widget_action.dart';

/// Opens an empty note/task/event editor when a quick action home screen
/// widget is tapped, like the in-app "+" buttons do.
///
/// Wraps the signed-in home, so it sits under `MaterialApp`'s navigator. A
/// cold start from a widget is read once per process: the launch intent
/// stays on the activity, and this widget is rebuilt on every sign-in.
/// Android only; on web it just returns [child].
class HomeWidgetLaunchHandler extends StatefulWidget {
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
  State<HomeWidgetLaunchHandler> createState() =>
      _HomeWidgetLaunchHandlerState();
}

class _HomeWidgetLaunchHandlerState extends State<HomeWidgetLaunchHandler> {
  StreamSubscription<Uri?>? _clicks;

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
    super.dispose();
  }

  void _handle(Uri? uri) {
    final action = HomeWidgetAction.parse(uri);
    if (action == null || !mounted) return;
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

  @override
  Widget build(BuildContext context) => widget.child;
}
