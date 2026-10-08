// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/settings/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/boot_error_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_bootstrap.dart';
import 'utils/widget_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppBootstrap.installErrorHandlers();
  _start();
}

Future<void> _start() async {
  try {
    final prefs = await AppBootstrap.init();
    runApp(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const NotesApp(),
      ),
    );
  } catch (e, st) {
    if (kDebugMode) debugPrint('Bootstrap failed: $e\n$st');
    runApp(BootErrorApp(error: e, onRetry: _start));
  }
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
      // UI strings are Italian-only for now, so system widgets (pickers,
      // text selection menu, tooltips) are pinned to Italian to match.
      locale: const Locale('it'),
      supportedLocales: const [Locale('it'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: authState.when(
        loading: () => const _SplashScreen(),
        error: (_, __) => const LoginScreen(),
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }

  void _syncHomeWidget(WidgetRef ref) {
    WidgetService.instance.scheduleSync(
      ref.read(activeNotesProvider),
      ref.read(activeTasksProvider),
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
