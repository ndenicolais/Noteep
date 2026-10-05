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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'notification_service.dart';
import 'widget_service.dart';

/// App startup: global error handlers and service initialization.
class AppBootstrap {
  /// Routes uncaught async errors to the debug log instead of letting them
  /// kill the app, and replaces the grey release-mode error box with a
  /// neutral placeholder.
  static void installErrorHandlers() {
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
      return true;
    };
    if (kReleaseMode) {
      ErrorWidget.builder =
          (_) => const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Icon(Icons.error_outline, color: Colors.grey, size: 32),
            ),
          );
    }
  }

  /// Initializes all services and returns the [SharedPreferences] instance
  /// to inject into the provider scope.
  ///
  /// Throws if a service the app cannot run without (Firebase,
  /// SharedPreferences) fails; optional ones (notifications, home widget,
  /// date locale) only log the failure.
  static Future<SharedPreferences> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await _optional('notifications', () async {
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermissions();
    });
    await _optional('home widget', WidgetService.instance.init);
    await _optional('date formatting', () async {
      await initializeDateFormatting('it');
      // DateFormat calls without an explicit locale use this one.
      Intl.defaultLocale = 'it';
    });
    return SharedPreferences.getInstance();
  }

  static Future<void> _optional(
    String name,
    Future<void> Function() init,
  ) async {
    try {
      await init();
    } catch (e) {
      if (kDebugMode) debugPrint('Bootstrap: $name init failed: $e');
    }
  }
}
