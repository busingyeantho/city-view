import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class FirebaseUtils {
  static final _log = Logger('FirebaseUtils');

  /// Handles Firebase Authentication errors and returns a user-friendly message
  static String getAuthErrorMessage(fb.FirebaseAuthException e) {
    _log.severe('Auth Error (${e.code}): ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  /// Handles Firestore errors and returns a user-friendly message
  static String getFirestoreErrorMessage(dynamic error) {
    _log.severe('Firestore Error: $error');
    
    if (error is fb.FirebaseAuthException) {
      return getAuthErrorMessage(error);
    }
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to access this data';
        case 'not-found':
          return 'The requested document was not found';
        case 'unavailable':
          return 'The service is currently unavailable. Please check your connection and try again.';
        default:
          return 'Database error: ${error.message}';
      }
    }
    
    return 'An unexpected error occurred';
  }

  /// Logs an error with stack trace if in debug mode
  static void logError(dynamic error, StackTrace? stackTrace, {String? context}) {
    final message = context != null ? '$context: $error' : error.toString();
    _log.severe(message, error, stackTrace);
    
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (stackTrace != null) {
        debugPrint('STACK TRACE: $stackTrace');
      }
    }
  }
}
