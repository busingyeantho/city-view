import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/blog_post.dart';

class BlogProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // State
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _currentFilter = 'all';
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  
  // Get last document for pagination
  DocumentSnapshot? get lastDocument => _lastDocument;
  
  // Cache for posts by filter
  final Map<String, List<BlogPost>> _postsCache = {};
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  List<BlogPost> get posts => _postsCache[_currentFilter] ?? [];
  
  // Initialize the provider
  Future<void> initialize({String? filter}) async {
    _currentFilter = filter ?? 'all';
    await _loadPosts(reset: true);
  }
  
  // Load posts from Firestore with pagination
  Future<void> _loadPosts({
    bool reset = false,
    bool loadMore = false,
    int limit = 10,
  }) async {
    if ((_isLoading && !loadMore) || (_isLoadingMore && loadMore)) return;
    
    try {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
      }
      
      notifyListeners();
      
      final filterKey = _currentFilter!;
      
      if (reset) {
        _postsCache[filterKey] = [];
        _lastDocument = null;
        _hasMore = true;
      }
      
      if (!_hasMore && loadMore) return;
      
      Query<Map<String, dynamic>> query = _firestore
          .collection('blogPosts')
          .orderBy('updatedAt', descending: true)
          .limit(limit);
      
      if (filterKey != 'all') {
        query = query.where('status', isEqualTo: filterKey);
      }
      
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        _hasMore = false;
        return;
      }
      
      final newPosts = snapshot.docs.map((doc) {
        return BlogPost.fromMap(doc.id, doc.data());
      }).toList();
      
      _postsCache[filterKey] = reset 
          ? newPosts 
          : [...(_postsCache[filterKey] ?? []), ...newPosts];
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _hasMore = newPosts.length >= limit;
      } else {
        _hasMore = false;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load posts: $e';
      rethrow;
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  
  // Get a single post by ID
  Future<BlogPost?> getPost(String id) async {
    try {
      final doc = await _firestore.collection('blogPosts').doc(id).get();
      if (!doc.exists) return null;
      return BlogPost.fromMap(doc.id, doc.data()!);
    } catch (e) {
      _error = 'Failed to get post: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // Create a new blog post
  Future<void> createPost(BlogPost post) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final slug = _createSlug(post.title);
      final postWithSlug = post.copyWith(
        slug: slug,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('blogPosts').add(postWithSlug.toMap());
      
      // Refresh the posts list
      await _loadPosts(reset: true);
      
    } catch (e) {
      _error = 'Failed to create post: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update an existing blog post
  Future<void> updatePost({
    required String id,
    String? title,
    String? content,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final data = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };
      
      if (title != null) {
        data['title'] = title;
        data['slug'] = _createSlug(title);
      }
      if (content != null) data['content'] = content;
      if (status != null) data['status'] = status;
      
      await _firestore.collection('blogPosts').doc(id).update(data);
      
      // Refresh the posts list
      await _loadPosts(reset: true);
      
    } catch (e) {
      _error = 'Failed to update post: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a post
  Future<void> deletePost(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore.collection('blogPosts').doc(id).delete();
      
      // Refresh the current filter to reflect the deletion
      await _loadPosts(reset: true);
      
    } catch (e) {
      _error = 'Failed to delete post: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Toggle post status between draft and published
  Future<void> togglePostStatus(String id, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'draft' ? 'published' : 'draft';
      await updatePost(id: id, status: newStatus);
    } catch (e) {
      _error = 'Failed to toggle post status: $e';
      rethrow;
    }
  }
  
  // Load more posts for pagination
  Future<void> loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    await _loadPosts(loadMore: true);
  }
  
  // Refresh posts
  Future<void> refreshPosts() async {
    await _loadPosts(reset: true);
  }
  
  String _createSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
