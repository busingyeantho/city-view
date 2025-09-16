import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

import '../models/gallery_category.dart';
import '../models/gallery_image.dart';

class GalleryAdminProvider with ChangeNotifier {
  // Flag to track if the provider is still mounted
  bool _mounted = true;
  bool get mounted => _mounted;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Stream controllers for state management
  final StreamController<String?> _errorController = StreamController<String?>.broadcast();
  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();
  
  // Dispose flag to prevent calling notifyListeners after dispose
  bool _isDisposed = false;
  
  // Public streams
  Stream<String?> get errorStream => _errorController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  
  // Helper methods for state management
  void _setError(String? error) {
    if (_isDisposed) return;
    _errorController.add(error);
    if (mounted) {
      notifyListeners();
    }
  }
  
  void _setLoading(bool isLoading) {
    if (_isDisposed) return;
    _loadingController.add(isLoading);
    if (mounted) {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _mounted = false;
    _isDisposed = true;
    _errorController.close();
    _loadingController.close();
    super.dispose();
  }
  
  // Collections
  static const String categoriesCollection = 'gallery_categories';
  static const String imagesCollection = 'gallery_images';
  
  // State
  List<GalleryCategory> _categories = [];
  final Map<String, List<GalleryImage>> _imagesByCategory = {};
  final Set<String> _processingCategories = {};
  final Set<String> _processingImages = {};
  
  // Getters
  List<GalleryCategory> get categories => List.unmodifiable(_categories);
  Map<String, List<GalleryImage>> get imagesByCategory => Map.unmodifiable(
    _imagesByCategory.map((key, value) => MapEntry(key, List.unmodifiable(value)))
  );
  
  bool isProcessingCategory(String categoryId) => _processingCategories.contains(categoryId);
  bool isProcessingImage(String imageId) => _processingImages.contains(imageId);
  
  // Delete an image
  Future<void> deleteImage(String imageId, String categoryId, {bool updateState = true}) async {
    if (_isDisposed) return;
    
    try {
      _processingImages.add(imageId);
      if (updateState) {
        _setLoading(true);
        _setError(null);
      }
      
      // Get the image to delete its storage file
      final doc = await _firestore
          .collection(imagesCollection)
          .doc(imageId)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!..['id'] = doc.id;
        final image = GalleryImage.fromMap(data, categoryId);
        
        // Delete the image file from storage
        if (image.imageUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(image.imageUrl).delete();
          } catch (e) {
            debugPrint('Failed to delete image file: $e');
            // Continue even if file deletion fails
          }
        }
        
        // Delete the image document
        await _firestore.collection(imagesCollection).doc(imageId).delete();
        
        // Update local state
        if (_imagesByCategory.containsKey(categoryId)) {
          _imagesByCategory[categoryId]!.removeWhere((img) => img.id == imageId);
          if (mounted && updateState) notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to delete image: ${e.toString()}');
      rethrow;
    } finally {
      _processingImages.remove(imageId);
      if (updateState) {
        _setLoading(false);
      }
    }
  }
  
  // Initialize the provider and load initial data
  Future<void> initialize() async {
    if (_isDisposed) return;
    
    try {
      _setLoading(true);
      _setError(null);
      
      // Load initial data
      await _loadCategories();
      
      if (_isDisposed) return;
      _setLoading(false);
    } catch (e) {
      if (!_isDisposed) {
        _setError('Failed to initialize: $e');
        _setLoading(false);
        rethrow;
      }
    }
  }
  
  // Load all categories
  Future<void> _loadCategories() async {
    if (_isDisposed) return;
    
    try {
      _setLoading(true);
      _setError(null);
      
      final snapshot = await _firestore
          .collection(categoriesCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      if (_isDisposed) return;
      
      final newCategories = <GalleryCategory>[];
      for (final doc in snapshot.docs) {
        try {
          newCategories.add(GalleryCategory.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ));
        } catch (e) {
          debugPrint('Error parsing category ${doc.id}: $e');
          // Continue with other categories even if one fails
        }
      }
      
      if (_isDisposed) return;
      _categories = newCategories;
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }
  
  // Set up real-time listeners for categories
  void _setupCategoryListeners() {
    _firestore
        .collection(categoriesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docChanges.isNotEmpty) {
        // Handle category changes
        for (final change in snapshot.docChanges) {
          final categoryId = change.doc.id;
          final category = GalleryCategory.fromMap(change.doc.data()!, categoryId);
          
          switch (change.type) {
            case DocumentChangeType.added:
              _updateOrAddCategory(category);
              break;
            case DocumentChangeType.modified:
              _updateOrAddCategory(category);
              break;
            case DocumentChangeType.removed:
              _removeCategory(categoryId);
              break;
          }
        }
        
        // Set up image listeners for any new categories
        for (final category in _categories) {
          if (!_imagesByCategory.containsKey(category.id)) {
            _setupImageListeners(category.id);
          }
        }
        
        _setLoading(false);
        _setError(null);
        notifyListeners();
      }
    });
  }
  
  // Set up real-time listeners for images in a category
  void _setupImageListeners(String categoryId) {
    _firestore
        .collection(imagesCollection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges.isNotEmpty) {
        _imagesByCategory[categoryId] = snapshot.docs
            .map((doc) => GalleryImage.fromMap(doc.data(), doc.id))
            .toList();
        
        _setLoading(false);
        _setError(null);
        notifyListeners();
      }
    });
  }
  
  // Load images for a specific category
  Future<void> _loadImagesForCategory(String categoryId) async {
    try {
      _setLoading(true);
      _setError(null);
      final snapshot = await _firestore
          .collection(imagesCollection)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _imagesByCategory[categoryId] = snapshot.docs
          .map((doc) => GalleryImage.fromMap(doc.data(), doc.id))
          .toList();
      
      // Set up listener for future changes
      _setupImageListeners(categoryId);
      
      _setLoading(false);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      debugPrint('Error loading images for category $categoryId: $e');
      rethrow;
    }
  }
  
  // Add a new category
  Future<void> addCategory(GalleryCategory category) async {
    if (_isDisposed) return;
    
    try {
      _processingCategories.add(category.id);
      _setLoading(true);
      _setError(null);
      
      final docRef = _firestore.collection(categoriesCollection).doc();
      final newCategory = category.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(newCategory.toMap());
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    } finally {
      _processingCategories.remove(category.id);
      notifyListeners();
    }
  }
  
  // Update an existing category
  Future<void> updateCategory(String categoryId, GalleryCategory updates) async {
    try {
      _processingCategories.add(categoryId);
      _setLoading(true);
      _setError(null);
      
      await _firestore
          .collection(categoriesCollection)
          .doc(categoryId)
          .update(updates.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    } finally {
      _processingCategories.remove(categoryId);
      notifyListeners();
    }
  }
  
  // Delete a category and all its images
  Future<void> deleteCategory(String categoryId) async {
    try {
      _processingCategories.add(categoryId);
      _setLoading(true);
      _setError(null);
      
      // First delete all images in this category
      final images = _imagesByCategory[categoryId] ?? [];
      for (final image in images) {
        await deleteImage(image.id, categoryId, updateState: false);
      }
      
      // Then delete the category
      await _firestore.collection(categoriesCollection).doc(categoryId).delete();
      
      // Update local state
      _categories.removeWhere((cat) => cat.id == categoryId);
      _imagesByCategory.remove(categoryId);
      
      if (mounted) notifyListeners();
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      rethrow;
    } finally {
      _processingCategories.remove(categoryId);
      _setLoading(false);
    }
  }
  
  // Upload multiple images to a category
  Future<void> uploadImages({
    required String categoryId,
    required List<PlatformFile> files,
    bool isFeatured = false,
  }) async {
    try {
      _processingCategories.add(categoryId);
      _setLoading(true);
      _setError(null);
      
      final category = _categories.firstWhere((cat) => cat.id == categoryId);
      
      // Upload each file
      for (final file in files) {
        final imageId = const Uuid().v4();
        _processingImages.add(imageId);
        
        try {
          // Upload the file to Firebase Storage
          final fileExtension = path.extension(file.name).toLowerCase();
          final storageRef = _storage
              .ref('gallery/$categoryId/$imageId$fileExtension');
          
          final uploadTask = storageRef.putData(
            file.bytes!,
            SettableMetadata(contentType: 'image/${fileExtension.replaceAll('.', '')}'),
          );
          
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();
          
          // Create the image document in Firestore
          final image = GalleryImage(
            id: imageId,
            categoryId: categoryId,
            imageUrl: downloadUrl,
            title: path.basenameWithoutExtension(file.name),
            isFeatured: isFeatured,
            order: _imagesByCategory[categoryId]?.length ?? 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _firestore
              .collection(imagesCollection)
              .doc(imageId)
              .set(image.toMap());
              
        } catch (e) {
          debugPrint('Error uploading image ${file.name}: $e');
          // Continue with next file even if one fails
        } finally {
          _processingImages.remove(imageId);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error in uploadImages: $e');
      rethrow;
    } finally {
      _processingCategories.remove(categoryId);
      notifyListeners();
    }
  }
  
  
  // Toggle featured status of an image
  Future<void> toggleFeaturedStatus(String imageId, String categoryId) async {
    try {
      _processingImages.add(imageId);
      _setLoading(true);
      _setError(null);
      
      final currentImage = _imagesByCategory[categoryId]?.firstWhere(
        (img) => img.id == imageId,
      );
      
      if (currentImage != null) {
        await _firestore
            .collection(imagesCollection)
            .doc(imageId)
            .update({
              'isFeatured': !currentImage.isFeatured,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error toggling featured status: $e');
      rethrow;
    } finally {
      _processingImages.remove(imageId);
      notifyListeners();
    }
  }
  
  // Update image order
  Future<void> updateImageOrder(String categoryId, int oldIndex, int newIndex) async {
    try {
      _setLoading(true);
      _setError(null);
      final images = List<GalleryImage>.from(_imagesByCategory[categoryId] ?? []);
      
      if (oldIndex < 0 || oldIndex >= images.length || newIndex < 0 || newIndex >= images.length) {
        return;
      }
      
      final movedImage = images.removeAt(oldIndex);
      images.insert(newIndex, movedImage);
      
      // Update the order field for all affected images
      final batch = _firestore.batch();
      for (int i = 0; i < images.length; i++) {
        if (images[i].order != i) {
          final docRef = _firestore.collection(imagesCollection).doc(images[i].id);
          batch.update(docRef, {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
        }
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating image order: $e');
      rethrow;
    }
  }
  
  
  // Helper methods to update local state
  void _updateOrAddCategory(GalleryCategory category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
    } else {
      _categories.add(category);
      // Sort categories by order
      _categories.sort((a, b) => a.order.compareTo(b.order));
    }
  }
  
  void _removeCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    _imagesByCategory.remove(categoryId);
  }
  
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
