// Firebase configuration for project: emergencyos-innovationx
// Generated for Flutter Web target.
// Replace the placeholder values below with the actual values from your
// Firebase Console → Project Settings → Your apps → Web app config.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for web.',
    );
  }

  // Replace ALL placeholder values with your real Firebase project config.
  // Firebase Console → Project Settings → General → Your apps → Web app
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'emergencyos-innovationx',
    authDomain: 'emergencyos-innovationx.firebaseapp.com',
    storageBucket: 'emergencyos-innovationx.firebasestorage.app',
  );
}
