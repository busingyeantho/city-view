import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryCategory {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalleryCategory({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.order = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create a copy of the category with some updated fields
  GalleryCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GalleryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert the category to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'order': order,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a category from a Firestore document
  factory GalleryCategory.fromMap(Map<String, dynamic> map, String id) {
    return GalleryCategory(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GalleryCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.coverImageUrl == coverImageUrl &&
        other.order == order &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        coverImageUrl.hashCode ^
        order.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'GalleryCategory(id: $id, name: $name, order: $order, isActive: $isActive)';
  }
}
