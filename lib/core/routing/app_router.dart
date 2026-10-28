// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../screens/archive_screen.dart';
import '../../screens/calendar/calendar_event_editor_screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/export_screen.dart';
import '../../screens/info_screen.dart';
import '../../screens/label_notes_screen.dart';
import '../../screens/labels_screen.dart';
import '../../screens/note_editor/note_editor_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../screens/reminders_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/task_editor/task_editor_screen.dart';
import '../../screens/tasks/tasks_screen.dart';
import '../../screens/trash_screen.dart';
import '../../screens/unknown_route_screen.dart';

/// Every named route in the app. Home is `MaterialApp.home` (it depends on
/// the auth state), so it has no entry here.
abstract final class AppRoutes {
  // Drawer sections.
  static const tasks = '/tasks';
  static const reminders = '/reminders';
  static const calendar = '/calendar';
  static const labels = '/labels';
  static const archive = '/archive';
  static const trash = '/trash';
  static const settings = '/settings';

  // Detail screens (take arguments, see [AppNav]).
  static const note = '/note';
  static const task = '/task';
  static const event = '/event';
  static const label = '/label';
  static const statistics = '/statistics';
  static const export = '/export';
  static const info = '/info';
  static const onboarding = '/onboarding';
  static const privacyPolicy = '/privacy-policy';
}

/// Arguments for [AppRoutes.note].
class NoteRouteArgs {
  const NoteRouteArgs(this.note, {this.autoOpenRecorder = false});

  final NoteModel note;
  final bool autoOpenRecorder;
}

/// Builds every named route. A missing or wrongly typed argument for a
/// detail route is treated as an unknown route instead of crashing.
abstract final class AppRouter {
  /// Drawer sections: switching between them fades through instead of
  /// sliding, since they are siblings rather than a drill-down.
  static const sectionRoutes = {
    AppRoutes.tasks,
    AppRoutes.reminders,
    AppRoutes.calendar,
    AppRoutes.labels,
    AppRoutes.archive,
    AppRoutes.trash,
    AppRoutes.settings,
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = _builderFor(settings);
    if (builder == null) return null;
    if (sectionRoutes.contains(settings.name)) {
      return FadeThroughPageRoute(builder: builder, settings: settings);
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => UnknownRouteScreen(routeName: settings.name),
      settings: settings,
    );
  }

  static WidgetBuilder? _builderFor(RouteSettings settings) {
    final args = settings.arguments;
    return switch (settings.name) {
      AppRoutes.tasks => (_) => const TasksScreen(),
      AppRoutes.reminders => (_) => const RemindersScreen(),
      AppRoutes.calendar => (_) => const CalendarWorkspaceView(),
      AppRoutes.labels => (_) => const LabelsScreen(),
      AppRoutes.archive => (_) => const ArchiveScreen(),
      AppRoutes.trash => (_) => const TrashScreen(),
      AppRoutes.settings => (_) => const SettingsScreen(),
      AppRoutes.statistics => (_) => const StatisticsScreen(),
      AppRoutes.export => (_) => const ExportScreen(),
      AppRoutes.info => (_) => const InfoScreen(),
      AppRoutes.onboarding => (_) => const OnboardingScreen(replay: true),
      AppRoutes.privacyPolicy => (_) => const PrivacyPolicyScreen(),
      AppRoutes.note when args is NoteRouteArgs =>
        (_) => NoteEditorScreen(
          note: args.note,
          autoOpenRecorder: args.autoOpenRecorder,
        ),
      AppRoutes.task when args is TaskModel =>
        (_) => TaskEditorScreen(task: args),
      AppRoutes.event when args is CalendarEventModel =>
        (_) => CalendarEventEditorScreen(event: args),
      AppRoutes.label when args is String =>
        (_) => LabelNotesScreen(label: args),
      _ => null,
    };
  }
}

/// Material "fade through": a solid background first fades in over the old
/// page, then the new page fades in on it while scaling up slightly. The
/// background hides every route below (Home stays under the sections), so
/// pages never show through each other mid-transition.
/// Instant when the platform asks to reduce motion.
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({required this.builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final cover = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.3, curve: Curves.easeIn),
          );
          final incoming = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1, curve: Curves.easeOut),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              FadeTransition(
                opacity: cover,
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              FadeTransition(
                opacity: incoming,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1).animate(incoming),
                  child: child,
                ),
              ),
            ],
          );
        },
      );

  final WidgetBuilder builder;
}

/// Typed navigation helpers, so call sites can't pass the wrong arguments.
abstract final class AppNav {
  static Future<void> openNote(
    BuildContext context,
    NoteModel note, {
    bool autoOpenRecorder = false,
  }) => Navigator.pushNamed(
    context,
    AppRoutes.note,
    arguments: NoteRouteArgs(note, autoOpenRecorder: autoOpenRecorder),
  );

  static Future<void> openTask(BuildContext context, TaskModel task) =>
      Navigator.pushNamed(context, AppRoutes.task, arguments: task);

  static Future<void> openEvent(
    BuildContext context,
    CalendarEventModel event,
  ) => Navigator.pushNamed(context, AppRoutes.event, arguments: event);

  static Future<void> openLabel(BuildContext context, String label) =>
      Navigator.pushNamed(context, AppRoutes.label, arguments: label);

  static Future<void> openTasks(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.tasks);

  static Future<void> openStatistics(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.statistics);

  static Future<void> openExport(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.export);

  static Future<void> openInfo(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.info);

  static Future<void> openOnboarding(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.onboarding);

  static Future<void> openPrivacyPolicy(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.privacyPolicy);
}
