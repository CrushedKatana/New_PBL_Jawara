// Firebase Options - DEMO/LOCAL MODE
// To connect to a real Firebase project:
// 1. Go to https://console.firebase.google.com
// 2. Create a new project or select existing
// 3. Add Android/iOS/Web apps
// 4. Copy credentials below OR run: flutterfire configure

// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Demo values - Replace with real Firebase project credentials
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEMO_KEY_REPLACE_ME',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'pbl-jawara-demo',
    authDomain: 'pbl-jawara-demo.firebaseapp.com',
    storageBucket: 'pbl-jawara-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEMO_KEY_REPLACE_ME',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'pbl-jawara-demo',
    storageBucket: 'pbl-jawara-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEMO_KEY_REPLACE_ME',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'pbl-jawara-demo',
    storageBucket: 'pbl-jawara-demo.appspot.com',
    iosBundleId: 'com.example.pblNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDEMO_KEY_REPLACE_ME',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'pbl-jawara-demo',
    storageBucket: 'pbl-jawara-demo.appspot.com',
    iosBundleId: 'com.example.pblNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEMO_KEY_REPLACE_ME',
    appId: '1:123456789:windows:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'pbl-jawara-demo',
    authDomain: 'pbl-jawara-demo.firebaseapp.com',
    storageBucket: 'pbl-jawara-demo.appspot.com',
  );
}
