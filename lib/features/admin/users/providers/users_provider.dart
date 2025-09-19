import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UsersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // State
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String _selectedRole = 'all';
  DocumentSnapshot? _lastDocument;
  bool _hasMoreUsers = true;
  final int _usersPerPage = 10;
  List<Map<String, dynamic>> _users = [];
  
  // Getters for state
  String? get searchQuery => _searchQuery;

  // Getters
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreUsers => _hasMoreUsers;
  
  // For backward compatibility
  Stream<String> get errorStream => Stream.value(_error ?? '').asBroadcastStream();
  
  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Search users by email
  Future<void> searchUsers(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query.isEmpty ? null : query;
    await _loadUsers(reset: true);
  }
  
  // Toggle user active status
  Future<bool> toggleUserStatus(String userId, bool isCurrentlyActive) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore.collection('users').doc(userId).update({
        'isActive': !isCurrentlyActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local state
      final userIndex = _users.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['isActive'] = !isCurrentlyActive;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update user status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Available roles
  static const List<Map<String, dynamic>> availableRoles = [
    {'value': 'super_admin', 'label': 'Super Admin'},
    {'value': 'content_manager', 'label': 'Content Manager'},
    {'value': 'blogger', 'label': 'Blogger'},
    {'value': 'user', 'label': 'User'},
  ];

  // Initialize the provider
  Future<void> initialize() async {
    await _loadUsers(reset: true);
  }

  // Load users with pagination
  Future<void> _loadUsers({
    bool reset = false,
    DocumentSnapshot? startAfter,
    int? limit,
  }) async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      if (reset) {
        _users = [];
        _lastDocument = null;
        _hasMoreUsers = true;
      }
      notifyListeners();
      
      if (!_hasMoreUsers) return;
      
      final effectiveLimit = limit ?? _usersPerPage;
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .orderBy('email')
          .limit(effectiveLimit);
      
      if (_selectedRole != 'all') {
        query = query.where('role', isEqualTo: _selectedRole);
      }
      
      if (_searchQuery?.isNotEmpty == true) {
        query = query.where('email', isGreaterThanOrEqualTo: _searchQuery)
                    .where('email', isLessThanOrEqualTo: '${_searchQuery!}\uf8ff');
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get(const GetOptions(source: Source.serverAndCache));
      
      if (_isDisposed) return;
      
      if (snapshot.docs.isEmpty) {
        _hasMoreUsers = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      _lastDocument = snapshot.docs.last;
      final newUsers = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final userRole = data['role'] ?? 'user';
        return {
          'id': doc.id,
          ...data,
          'roleLabel': getRoleLabel(userRole),
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
        };
      }));
      
      _users = reset ? newUsers : [..._users, ...newUsers];
      _hasMoreUsers = newUsers.length == effectiveLimit;
      _lastDocument = snapshot.docs.last;
      _hasMoreUsers = newUsers.length >= _usersPerPage;
      
    } catch (e) {
      _error = 'Failed to load users: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load more users for pagination
  Future<void> loadMoreUsers() async {
    if (_isLoading || !_hasMoreUsers) return;
    await _loadUsers(startAfter: _lastDocument);
  }
  
  // Refresh users list
  Future<void> refreshUsers() async {
    await _loadUsers(reset: true);
  }
  
  // Filter users by role
  Future<void> filterByRole(String role) async {
    if (_selectedRole == role) return;
    _selectedRole = role;
    await _loadUsers(reset: true);
  }
  
  
  // Create a new user
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Use a secondary FirebaseApp so the admin session is not affected
      FirebaseApp? secondaryApp;
      firebase_auth.FirebaseAuth? secondaryAuth;
      try {
        // Get default app options and initialize a secondary app
        final defaultApp = Firebase.app();
        try {
          secondaryApp = Firebase.app('secondary');
        } catch (_) {
          secondaryApp = await Firebase.initializeApp(
            name: 'secondary',
            options: defaultApp.options,
          );
        }

        secondaryAuth = firebase_auth.FirebaseAuth.instanceFor(app: secondaryApp);
        final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user?.uid;
        if (uid == null) {
          throw Exception('Failed to create user');
        }

        // Create user document in Firestore
        final userData = {
          'email': email,
          'role': role,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (additionalData != null) ...additionalData,
        };

        await _firestore.collection('users').doc(uid).set(userData);

        // Refresh users list
        await _loadUsers(reset: true);

        return {
          'success': true,
          'id': uid,
          ...userData,
        };
      } finally {
        // Clean up secondary auth/app to avoid resource leaks
        try {
          await secondaryAuth?.signOut();
        } catch (_) {}
        try {
          await secondaryApp?.delete();
        } catch (_) {}
      }
    } catch (e) {
      _error = 'Failed to create user: $e';
      return {
        'success': false,
        'error': _error,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local state
      final userIndex = _users.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['role'] = newRole;
        _users[userIndex]['roleLabel'] = getRoleLabel(newRole);
        _users[userIndex]['updatedAt'] = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update user role: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // Client cannot delete Auth users securely; remove Firestore doc instead
      await _firestore.collection('users').doc(userId).delete();
      await _loadUsers(reset: true);
    } catch (e) {
      _error = 'Failed to delete user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper method to get role label
  static String getRoleLabel(String role) {
    final roleData = availableRoles.firstWhere(
      (r) => r['value'] == role,
      orElse: () => {'label': role},
    );
    return roleData['label'] as String;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
