// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/settings/theme_provider.dart';
import 'screens/archive_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/labels_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/trash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_drawer.dart';
import 'utils/notification_service.dart';
import 'utils/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await WidgetService.instance.init();
  await initializeDateFormatting('it', null);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends ConsumerWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    // Keep the Android home-screen widget in sync whenever notes or tasks
    // change — otherwise it stays on its placeholder values forever.
    ref.listen(activeNotesProvider, (_, _) => _syncHomeWidget(ref));
    ref.listen(activeTasksProvider, (_, _) => _syncHomeWidget(ref));

    return MaterialApp(
      title: 'Noteep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      home: authState.when(
        loading: () => const _SplashScreen(),
        error: (_, __) => const LoginScreen(),
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
      ),
      routes: {
        AppRoutes.tasks: (_) => const TasksScreen(),
        AppRoutes.reminders: (_) => const RemindersScreen(),
        AppRoutes.calendar: (_) => const CalendarWorkspaceView(),
        AppRoutes.labels: (_) => const LabelsScreen(),
        AppRoutes.archive: (_) => const ArchiveScreen(),
        AppRoutes.trash: (_) => const TrashScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }

  void _syncHomeWidget(WidgetRef ref) {
    final notes = ref.read(activeNotesProvider);
    final tasks = ref.read(activeTasksProvider);
    final latest =
        notes.isEmpty
            ? ''
            : (List.of(notes)..sort(
              (a, b) => b.updatedAt.compareTo(a.updatedAt),
            )).first.title;
    WidgetService.instance.updateWidget(
      noteCount: notes.length.toString(),
      taskCount: tasks.where((t) => !t.isCompleted).length.toString(),
      latestNote: latest,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.note_alt,
                size: 46,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
