import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/gallery_category.dart';
import '../models/gallery_image.dart';

/// Minimal provider to unblock build. Stores data in-memory for now.
class GalleryProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<GalleryCategory> _categories = [];
  List<GalleryCategory> get categories => List.unmodifiable(_categories);

  final Map<String, List<GalleryImage>> imagesByCategory = {};

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _error = null;
      // Seed with some demo categories if empty
      if (_categories.isEmpty) {
        _categories.addAll([
          const GalleryCategory(id: 'classroom', name: 'Classroom Activities', description: 'Learning and projects'),
          const GalleryCategory(id: 'sports', name: 'Sports & Games', description: 'Athletics and games'),
          const GalleryCategory(id: 'events', name: 'Special Events', description: 'Celebrations and ceremonies'),
        ]);
        for (final c in _categories) {
          imagesByCategory[c.id] = [];
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(GalleryCategory category) async {
    // Generate simple id if not provided
    final id = category.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : category.id;
    _categories.add(category.copyWith(id: id));
    imagesByCategory[id] = imagesByCategory[id] ?? [];
    notifyListeners();
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    String? description,
    int? imageCount,
  }) async {
    final idx = _categories.indexWhere((c) => c.id == categoryId);
    if (idx == -1) return;
    final current = _categories[idx];
    _categories[idx] = current.copyWith(
      name: name,
      description: description,
      imageCount: imageCount,
    );
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    imagesByCategory.remove(categoryId);
    notifyListeners();
  }

  Future<void> loadCategoryImages(String categoryId) async {
    // No-op for now; images already in memory
    imagesByCategory.putIfAbsent(categoryId, () => []);
    notifyListeners();
  }

  Future<void> uploadImage({
    required String categoryId,
    required File imageFile,
  }) async {
    // In-memory mock upload; just add a placeholder entry
    final list = imagesByCategory.putIfAbsent(categoryId, () => []);
    list.add(GalleryImage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      imageUrl: '', // real implementation would upload and set URL
      description: imageFile.path.split(Platform.pathSeparator).last,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> deleteImage({
    required String categoryId,
    required String imageId,
  }) async {
    final list = imagesByCategory[categoryId];
    if (list == null) return;
    list.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
