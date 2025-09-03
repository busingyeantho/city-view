import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static bool _initialized = false;

  static bool _hasWebEnv() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
    const appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    return apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (kIsWeb) {
      // Web config provided by user
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCuDms3l6Mk2iuoZIgUi0V3EV_M6sP1R08',
          appId: '1:734879789408:web:5a2ca08f16cfca0290ae05',
          messagingSenderId: '734879789408',
          projectId: 'city-view-8e128',
          authDomain: 'city-view-8e128.firebaseapp.com',
          storageBucket: 'city-view-8e128.firebasestorage.app',
          measurementId: 'G-N6CV6SEVTH',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    _initialized = true;
  }
}


