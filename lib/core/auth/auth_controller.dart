import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  fb.User? _user;
  String? _role; // 'super_admin' | 'content_manager' | 'blogger'
  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roleSub;

  AuthController() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    _user = _auth.currentUser;
    if (_user != null) {
      _subscribeRole(_user!.uid);
    }
  }

  fb.User? get user => _user;
  String? get role => _role;
  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _onAuthChanged(fb.User? user) {
    _user = user;
    _role = null;
    _roleSub?.cancel();
    if (user != null) {
      _subscribeRole(user.uid);
    }
    notifyListeners();
  }

  void _subscribeRole(String uid) {
    _roleSub = _firestore.collection('users').doc(uid).snapshots().listen((doc) {
      _role = doc.data()?['role'] as String?;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _roleSub?.cancel();
    super.dispose();
  }
}


