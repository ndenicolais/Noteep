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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../providers/settings/locale_provider.dart';
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
    registerFontLicenses();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Must run before the first Firestore call. Android already persists
      // by default, web does not: with this, writes made offline are queued
      // in the local cache on both instead of being lost on reload.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await _optional('date formatting', () async {
      await initializeDateFormatting('it');
      await initializeDateFormatting('en');
    });
    // Strings and dates built before the first frame (notification channel,
    // home widget) use this; MaterialApp.builder then keeps it in sync.
    Intl.defaultLocale = startupLanguageCode(prefs);
    await _optional('notifications', NotificationService.instance.init);
    await _optional('home widget', WidgetService.instance.init);
    return prefs;
  }

  /// Bundled fonts, as (package names on the licenses page, OFL text asset).
  static const fontLicenses = [
    ('Exo 2', 'assets/fonts/Exo2-OFL.txt'),
    ('Montserrat', 'assets/fonts/Montserrat-OFL.txt'),
    ('Open Sans', 'assets/fonts/OpenSans-OFL.txt'),
    ('Dancing Script', 'assets/fonts/DancingScript-OFL.txt'),
    ('Playfair Display', 'assets/fonts/PlayfairDisplay-OFL.txt'),
    ('Pacifico', 'assets/fonts/Pacifico-OFL.txt'),
  ];

  static bool _fontLicensesRegistered = false;

  /// Adds the SIL Open Font License of each bundled font to the licenses
  /// page (Info → Open-source licenses), as the OFL requires. The texts are
  /// read only when the page is opened. Safe to call again on Retry.
  static void registerFontLicenses() {
    if (_fontLicensesRegistered) return;
    _fontLicensesRegistered = true;
    LicenseRegistry.addLicense(() async* {
      for (final (family, asset) in fontLicenses) {
        yield LicenseEntryWithLineBreaks([
          family,
        ], await rootBundle.loadString(asset));
      }
    });
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
