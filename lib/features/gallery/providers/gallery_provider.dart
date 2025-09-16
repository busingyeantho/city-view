import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/gallery_category.dart';
import '../models/gallery_image.dart';

/// Provider for managing gallery data including categories and images.
/// Handles loading, uploading, and managing gallery content.

class GalleryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String categoriesCollection = 'gallery_categories';
  static const String imagesCollection = 'gallery_images';

  // State
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _isLoading = false;
  String? _error;
  
  // Categories
  List<GalleryCategory> _categories = [];
  List<GalleryCategory> get categories => _categories;

  // Images by category
  final Map<String, List<GalleryImage>> _imagesByCategory = {};
  Map<String, List<GalleryImage>> get imagesByCategory => _imagesByCategory;
  
  List<GalleryImage> getImagesByCategory(String categoryId) => 
      _imagesByCategory[categoryId] ?? [];

  // Loading states
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadCategories();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all categories
  Future<void> _loadCategories() async {
    try {
      if (_isLoading) return;
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection(categoriesCollection)
          .orderBy('createdAt', descending: true)
          .get();
      final newCategories = snapshot.docs
          .map((doc) => GalleryCategory.fromMap(doc.id, doc.data()))
          .toList();
          
      if (!listEquals(_categories, newCategories)) {
        _categories = newCategories;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load categories: $e';
      debugPrint(_error);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Track last document for pagination
  final Map<String, DocumentSnapshot?> _lastDocuments = {};

  /// Loads images for a specific category with pagination support
  /// 
  /// [categoryId] The ID of the category to load images for
  /// [startAfter] The document to start after for pagination
  /// [limit] Maximum number of documents to fetch
  Future<void> loadCategoryImages(
    String categoryId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      if (startAfter == null) {
        _isLoading = true;
        _error = null;
        notifyListeners();
      }

      Query<Map<String, dynamic>> query = _firestore
          .collection(imagesCollection)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      final newImages = snapshot.docs
          .map((doc) => GalleryImage.fromMap(doc.id, doc.data()))
          .toList();

      if (startAfter == null) {
        _imagesByCategory[categoryId] = newImages;
      } else {
        _imagesByCategory[categoryId] = [
          ..._imagesByCategory[categoryId] ?? [],
          ...newImages,
        ];
      }

      // Update last document for pagination
      if (snapshot.docs.isNotEmpty) {
        _lastDocuments[categoryId] = snapshot.docs.last;
      }
    } catch (e) {
      _error = 'Failed to load images: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets the last document for a category for pagination
  DocumentSnapshot? getLastDocument(String categoryId) => _lastDocuments[categoryId];

  /// Loads more images for the given category
  Future<void> loadMoreCategoryImages(String categoryId) async {
    final lastDoc = _lastDocuments[categoryId];
    if (lastDoc != null) {
      await loadCategoryImages(categoryId, startAfter: lastDoc);
    }
  }

  /// Add a new category
  Future<void> addCategory(GalleryCategory category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(categoriesCollection)
          .add(category.toMap());
      
      // Refresh categories list
      await _loadCategories();
    } catch (e) {
      _error = 'Failed to add category: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing category
  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String description,
    required int imageCount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update({
            'name': name,
            'description': description,
            'imageCount': imageCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      // Refresh categories list
      await _loadCategories();
    } catch (e) {
      _error = 'Failed to update category: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a category and all its associated images
  Future<void> deleteCategory(String categoryId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // First, delete all images in this category
      final imagesSnapshot = await _firestore
          .collection(imagesCollection)
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Delete each image file from storage and its document from Firestore
      final batch = _firestore.batch();
      for (final doc in imagesSnapshot.docs) {
        final image = GalleryImage.fromMap(doc.id, doc.data());
        try {
          // Delete the image file from storage
          final ref = _storage.refFromURL(image.imageUrl);
          await ref.delete();
          
          // Delete the image document
          batch.delete(doc.reference);
        } catch (e) {
          debugPrint('Failed to delete image ${image.id}: $e');
          // Continue with next image even if one fails
        }
      }
      
      // Commit the batch delete
      await batch.commit();
      
      // Delete the category
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .delete();
      
      // Update local state
      _categories.removeWhere((cat) => cat.id == categoryId);
      _imagesByCategory.remove(categoryId);
      _lastDocuments.remove(categoryId);
      
    } catch (e) {
      _error = 'Failed to delete category: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a new image to a category
  Future<GalleryImage> uploadImage({
    required String categoryId,
    required File imageFile,
    String? title,
    String? description,
    bool isFeatured = false,
    int order = 0,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload the image file to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('gallery/$categoryId/$fileName');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Create image document in Firestore
      final docRef = await _firestore.collection(imagesCollection).add({
        'categoryId': categoryId,
        'imageUrl': imageUrl,
        'title': title,
        'description': description,
        'isFeatured': isFeatured,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the category's image count
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update({
            'imageCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Create and return the new image object
      final newImage = GalleryImage(
        id: docRef.id,
        categoryId: categoryId,
        imageUrl: imageUrl,
        title: title,
        description: description,
        isFeatured: isFeatured,
        order: order,
        uploadedAt: DateTime.now(),
      );

      // Update local state
      _imagesByCategory[categoryId] = [
        ..._imagesByCategory[categoryId] ?? [],
        newImage,
      ];

      // Refresh categories to update image count
      await _loadCategories();

      return newImage;
    } catch (e) {
      _error = 'Failed to upload image: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an image from a category
  Future<void> deleteImage({
    required String categoryId,
    required String imageId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the image to delete
      final docRef = _firestore.collection(imagesCollection).doc(imageId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Image not found');
      }

      final image = GalleryImage.fromMap(doc.id, doc.data()!);

      // Delete the image file from storage
      final ref = _storage.refFromURL(image.imageUrl);
      await ref.delete();

      // Delete the image document
      await docRef.delete();

      // Update the category's image count
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update({
            'imageCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      if (_imagesByCategory[categoryId] != null) {
        _imagesByCategory[categoryId]!.removeWhere((img) => img.id == imageId);
      }

      // Refresh categories to update image count
      await _loadCategories();

    } catch (e) {
      _error = 'Failed to delete image: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
