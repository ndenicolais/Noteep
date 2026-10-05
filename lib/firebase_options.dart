// File generated manually — mirrors the flutterfire_cli output format.
// TODO: replace the web placeholders below with the values from the
// Firebase Console (Project settings > Your apps > Web app "noteep").
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkUQS2lWgheeyNLylMKZY7dbSD1nzEUlI',
    appId: '1:295028811498:web:c86dd7700f06f73d3ad993',
    messagingSenderId: '295028811498',
    projectId: 'noteep',
    authDomain: 'noteep.firebaseapp.com',
    storageBucket: 'noteep.firebasestorage.app',
    measurementId: 'G-XVBR6PZZZ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2lsfi_ZvrmK4vxkM4n3ElsF5spCirf_U',
    appId: '1:295028811498:android:18d797f435b2edde3ad993',
    messagingSenderId: '295028811498',
    projectId: 'noteep',
    storageBucket: 'noteep.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_IOS_API_KEY',
    appId: 'TODO_IOS_APP_ID',
    messagingSenderId: '295028811498',
    projectId: 'noteep',
    storageBucket: 'noteep.firebasestorage.app',
    iosBundleId: 'com.ndn21.noteep',
  );
}
