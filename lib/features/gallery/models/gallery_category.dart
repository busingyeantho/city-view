class GalleryCategory {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int imageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  GalleryCategory({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.imageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory GalleryCategory.fromMap(String id, Map<String, dynamic> map) {
    return GalleryCategory(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      coverImageUrl: map['coverImageUrl'],
      imageCount: (map['imageCount'] ?? 0).toInt(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'imageCount': imageCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  GalleryCategory copyWith({
    String? name,
    String? description,
    String? coverImageUrl,
    int? imageCount,
    bool? isActive,
  }) {
    return GalleryCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      imageCount: imageCount ?? this.imageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
