import 'package:flutter/material.dart';
import '../models/page_data.dart';

class PageUtils {
  /// Generates a URL-friendly slug from a title
  static String generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special chars
        .replaceAll(' ', '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .trim(); // Trim leading/trailing hyphens
  }

  /// Validates if a slug is in the correct format
  static String? validateSlug(String? value) {
    if (value == null || value.isEmpty) {
      return 'Slug cannot be empty';
    }
    if (value.contains(' ')) {
      return 'Slug cannot contain spaces';
    }
    if (value.startsWith('-') || value.endsWith('-')) {
      return 'Slug cannot start or end with a hyphen';
    }
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
      return 'Slug can only contain lowercase letters, numbers, and hyphens';
    }
    return null;
  }

  /// Formats a DateTime for display
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Gets the appropriate icon for a page status
  static IconData getStatusIcon(bool isPublished) {
    return isPublished ? Icons.check_circle : Icons.pending;
  }

  /// Gets the appropriate color for a page status
  static Color getStatusColor(bool isPublished, BuildContext context) {
    final theme = Theme.of(context);
    return isPublished
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;
  }

  /// Creates a new PageData with updated fields
  static PageData updatePageData({
    required PageData original,
    String? title,
    String? slug,
    String? seoDescription,
    String? content,
    bool? isPublished,
    String? heroImageUrl,
  }) {
    return PageData(
      id: original.id,
      title: title ?? original.title,
      slug: slug ?? original.slug,
      content: content != null ? {'content': content} : original.content,
      seoDescription: seoDescription ?? original.seoDescription,
      isPublished: isPublished ?? original.isPublished,
      heroImageUrl: heroImageUrl ?? original.heroImageUrl,
      createdAt: original.createdAt,
      updatedAt: DateTime.now(),
      createdBy: original.createdBy,
      updatedBy: 'current_user_id', // Replace with actual user ID
    );
  }
}
