import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../firebase/firebase_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AuthController extends ChangeNotifier {
  final log = Logger('AuthController');
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseBootstrap.firestore;

  fb.User? _user;
  String? _role; // 'super_admin' | 'content_manager' | 'blogger' | 'user'
  bool _isLoading = true;
  String? _error;
  
  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roleSub;

  AuthController() {
    _init();
  }

  fb.User? get user => _user;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Check if user has admin role
  bool get isAdmin => _role == 'super_admin' || _role == 'content_manager';
  
  // Check if user has blogger role
  bool get isBlogger => _role == 'blogger' || isAdmin;

  Future<void> _init() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _authSub = _auth.authStateChanges().listen(_onAuthChanged);
      _user = _auth.currentUser;
      
      if (_user != null) {
        await _subscribeRole(_user!.uid);
      }
    } catch (e, stackTrace) {
      _error = 'Failed to initialize authentication: ${e.toString()}';
      log.severe('Auth initialization error', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e);
      rethrow;
    } catch (e, stackTrace) {
      _error = 'An unexpected error occurred';
      log.severe('Sign in error', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _auth.signOut();
    } catch (e, stackTrace) {
      _error = 'Failed to sign out';
      log.severe('Sign out error', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onAuthChanged(fb.User? user) {
    try {
      _user = user;
      _role = null;
      _roleSub?.cancel();
      
      if (user != null) {
        _subscribeRole(user.uid);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _error = 'Error in auth state change';
      log.severe('Auth state change error', e, stackTrace);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _subscribeRole(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _roleSub?.cancel();
      _roleSub = _firestore.collection('users').doc(uid).snapshots().listen(
        (doc) {
          if (doc.exists && doc.data() != null) {
            _role = doc.data()!['role'] as String? ?? 'user';
          } else {
            _role = 'user'; // Default role if not specified
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Failed to load user role';
          _isLoading = false;
          notifyListeners();
          log.severe('Role subscription error', error);
        },
      );
    } catch (e, stackTrace) {
      _error = 'Error subscribing to user role';
      _isLoading = false;
      notifyListeners();
      log.severe('Role subscription error', e, stackTrace);
    }
  }
  
  String _getAuthErrorMessage(fb.FirebaseAuthException e) {
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
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _roleSub?.cancel();
    super.dispose();
  }
}


