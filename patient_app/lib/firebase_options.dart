// Firebase configuration for project: emergencyos-innovationx
// Generated for Flutter Web target.
//
// NOTE: This repo currently uses placeholder values (see staff_app too).
// Replace these with your Firebase Console → Web app config values.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'emergencyos-innovationx',
    authDomain: 'emergencyos-innovationx.firebaseapp.com',
    storageBucket: 'emergencyos-innovationx.firebasestorage.app',
  );
}

