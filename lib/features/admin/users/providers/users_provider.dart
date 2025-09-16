import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UsersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
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

  // Getters
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreUsers => _hasMoreUsers;
  
  // For backward compatibility
  Stream<String> get errorStream => Stream.value(_error ?? '').asBroadcastStream();
  
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
      
      final snapshot = await query.get();
      
      if (_isDisposed) return;
      
      if (snapshot.docs.isEmpty) {
        _hasMoreUsers = false;
        return;
      }
      
      final newUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'roleLabel': getRoleLabel(data['role'] ?? 'user'),
        };
      }).toList();
      
      _users = reset ? newUsers : [..._users, ...newUsers];
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
  
  // Search users by email
  Future<void> searchUsers(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
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
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }
      
      // Create user document in Firestore
      final userData = {
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      };
      
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);
      
      // Refresh users list
      await _loadUsers(reset: true);
      
      return {
        'id': userCredential.user!.uid,
        ...userData,
      };
    } catch (e) {
      _error = 'Failed to create user: $e';
      rethrow;
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
      
      // Delete from Auth (only if not the current user)
      if (_auth.currentUser?.uid != userId) {
        await _auth.currentUser?.delete();
      }
      
      // Delete from Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // Update local state
      _users.removeWhere((user) => user['id'] == userId);
      notifyListeners();
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
