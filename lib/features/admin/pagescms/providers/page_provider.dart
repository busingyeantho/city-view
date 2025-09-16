import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../models/page_data.dart';

class PageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'pages';
  final String _versionsCollection = 'page_versions';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  PageProvider({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  // Get a stream of all pages with error handling
  Stream<List<PageData>> watchPages() {
    return _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .handleError((error) {
          _error = 'Failed to load pages: ${error.toString()}';
          notifyListeners();
          return <QueryDocumentSnapshot>[];
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) {
                    try {
                      return PageData.fromFirestore(doc);
                    } catch (e) {
                      _error = 'Error parsing page data: $e';
                      notifyListeners();
                      return null;
                    }
                  })
                  .whereType<PageData>()
                  .toList(),
        );
  }

  // Get a single page by ID with proper error handling
  Future<PageData> getPage(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Page ID cannot be empty');
    }

    try {
      _setLoading(true);

      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Page with ID $id not found');
      }

      return PageData.fromFirestore(doc);
    } catch (e) {
      _handleError('Failed to get page', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Save or update a page
  Future<void> savePage(PageData page, {bool publish = false}) async {
    try {
      _setLoading(true);

      final pageData = page.toFirestore();

      if (publish) {
        // If publishing, move draft to content and clear draft
        pageData['content'] = page.draft ?? page.content;
        pageData.remove('draft');
        pageData['isPublished'] = true;
      }

      if (page.id.isEmpty) {
        // New page
        await _firestore.collection(_collection).add(pageData);
      } else {
        // Update existing page
        await _firestore.collection(_collection).doc(page.id).update(pageData);
      }

      // Save version history
      await _saveVersion(page);
    } catch (e) {
      _handleError('Failed to save page', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a page
  Future<void> deletePage(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Page ID cannot be empty');
    }

    try {
      _setLoading(true);
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      _handleError('Failed to delete page', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Upload image for a page
  Future<String> uploadImage(String pageId, String filePath) async {
    if (pageId.isEmpty) {
      throw ArgumentError('Page ID cannot be empty');
    }
    if (filePath.isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }

    try {
      _setLoading(true);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('pages/$pageId/$fileName');
      final uploadTask = await ref.putFile(File(filePath));

      if (uploadTask.state == TaskState.success) {
        return await uploadTask.ref.getDownloadURL();
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _handleError('Failed to upload image', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get page versions with error handling
  Stream<List<Map<String, dynamic>>> getPageVersions(String pageId) {
    if (pageId.isEmpty) {
      return Stream.error(ArgumentError('Page ID cannot be empty'));
    }

    return _firestore
        .collection(_versionsCollection)
        .where('pageId', isEqualTo: pageId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          _handleError('Failed to load versions', error);
          return const <QueryDocumentSnapshot>[];
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                      'createdAt':
                          (doc.data() as Map<String, dynamic>)['createdAt']
                              as Timestamp,
                    },
                  )
                  .toList(),
        );
  }

  // Restore a previous version
  Future<void> restoreVersion(String pageId, String versionId) async {
    if (pageId.isEmpty || versionId.isEmpty) {
      throw ArgumentError('Page ID and Version ID cannot be empty');
    }

    try {
      _setLoading(true);

      final versionDoc =
          await _firestore.collection(_versionsCollection).doc(versionId).get();

      if (!versionDoc.exists) {
        throw Exception('Version not found');
      }

      final versionData = versionDoc.data() as Map<String, dynamic>?;
      if (versionData == null) {
        throw Exception('Invalid version data');
      }

      await _firestore.collection(_collection).doc(pageId).update({
        'content': versionData['content'],
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': versionData['updatedBy'],
      });
    } catch (e) {
      _handleError('Failed to restore version', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh the pages list
  Future<void> refreshPages() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Force a refresh by reading the pages again
      final pages = await _firestore.collection(_collection).get();
      final List<PageData> _pages =
          pages.docs.map((doc) => PageData.fromFirestore(doc)).toList();
    } catch (e) {
      _error = 'Failed to refresh pages: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to save version history
  Future<void> _saveVersion(PageData page) async {
    try {
      await _firestore.collection(_versionsCollection).add({
        'pageId': page.id,
        'content': page.content,
        'updatedBy': page.updatedBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the main operation
      debugPrint('Failed to save version history: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message, dynamic error) {
    _error = '$message: ${error.toString()}';
    debugPrint(_error);
    notifyListeners();
  }
}
