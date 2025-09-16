import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImage {
  final String id;
  final String categoryId;
  final String imageUrl;
  final String? title;
  final String? description;
  final bool isFeatured;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalleryImage({
    required this.id,
    required this.categoryId,
    required this.imageUrl,
    this.title,
    this.description,
    this.isFeatured = false,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create a copy of the image with some updated fields
  GalleryImage copyWith({
    String? id,
    String? categoryId,
    String? imageUrl,
    String? title,
    String? description,
    bool? isFeatured,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      isFeatured: isFeatured ?? this.isFeatured,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert the image to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'isFeatured': isFeatured,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create an image from a Firestore document
  factory GalleryImage.fromMap(Map<String, dynamic> map, String id) {
    return GalleryImage(
      id: id,
      categoryId: map['categoryId'] as String,
      imageUrl: map['imageUrl'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      isFeatured: map['isFeatured'] as bool? ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GalleryImage &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.imageUrl == imageUrl &&
        other.title == title &&
        other.description == description &&
        other.isFeatured == isFeatured &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        imageUrl.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isFeatured.hashCode ^
        order.hashCode;
  }

  @override
  String toString() {
    return 'GalleryImage(id: $id, categoryId: $categoryId, isFeatured: $isFeatured, order: $order)';
  }
}
