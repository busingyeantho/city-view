import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';

// Global variable to track Firestore initialization
bool _firestoreInitialized = false;

class FirebaseBootstrap {
  static bool _initialized = false;
  static FirebaseFirestore? _firestoreInstance;

  static bool _hasWebEnv() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
    const appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    return apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    
    try {
      // First, initialize Firebase
      FirebaseApp app;
      
      if (kIsWeb) {
        app = await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: const String.fromEnvironment('FIREBASE_API_KEY', 
                defaultValue: 'AIzaSyCuDms3l6Mk2iuoZIgUi0V3EV_M6sP1R08'),
            appId: const String.fromEnvironment('FIREBASE_APP_ID',
                defaultValue: '1:734879789408:web:5a2ca08f16cfca0290ae05'),
            messagingSenderId: '734879789408',
            projectId: 'city-view-8e128',
            authDomain: 'city-view-8e128.firebaseapp.com',
            storageBucket: 'city-view-8e128.firebasestorage.app',
            measurementId: 'G-N6CV6SEVTH',
          ),
        );
      } else {
        app = await Firebase.initializeApp();
      }
      
      debugPrint('Firebase initialized: ${app.name}');
      
      // Initialize Firestore with proper error handling
      await _initializeFirestore();
      
      _initialized = true;
    } on FirebaseException catch (e) {
      debugPrint('Firebase initialization error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }
  
  static Future<void> _initializeFirestore() async {
    if (_firestoreInitialized) return;
    
    try {
      // Initialize Firestore with default settings
      _firestoreInstance = FirebaseFirestore.instance;
      
      // Enable persistence if not on web
      if (!kIsWeb) {
        try {
          await _firestoreInstance!.enablePersistence(
            const PersistenceSettings(synchronizeTabs: true),
          );
          debugPrint('Firestore persistence enabled successfully');
        } catch (e) {
          debugPrint('Note: Firestore persistence already enabled - $e');
        }
      }
      
      _firestoreInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Firestore: $e');
      rethrow;
    }
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('FirebaseBootstrap must be initialized before accessing Firestore');
    }
    return _firestoreInstance!;
  }
}

