class GalleryImage {
  final String id;
  final String categoryId;
  final String imageUrl;
  final String? title;
  final String? description;
  final String? uploadedBy;
  final DateTime uploadedAt;
  final int views;
  final Map<String, dynamic>? metadata;
  final bool isFeatured;
  final int order;

  GalleryImage({
    required this.id,
    required this.categoryId,
    required this.imageUrl,
    this.title,
    this.description,
    this.uploadedBy,
    DateTime? uploadedAt,
    this.views = 0,
    this.metadata,
    this.isFeatured = false,
    this.order = 0,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory GalleryImage.fromMap(String id, Map<String, dynamic> map) {
    return GalleryImage(
      id: id,
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'],
      description: map['description'],
      uploadedBy: map['uploadedBy'],
      uploadedAt: map['uploadedAt']?.toDate() ?? DateTime.now(),
      views: (map['views'] ?? 0).toInt(),
      metadata: map['metadata'] is Map ? Map<String, dynamic>.from(map['metadata']) : null,
      isFeatured: map['isFeatured'] ?? false,
      order: (map['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'views': views,
      'metadata': metadata,
      'isFeatured': isFeatured,
      'order': order,
    };
  }

  GalleryImage copyWith({
    String? categoryId,
    String? imageUrl,
    String? title,
    String? description,
    bool? isFeatured,
    int? order,
  }) {
    return GalleryImage(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
      views: views,
      metadata: metadata,
      isFeatured: isFeatured ?? this.isFeatured,
      order: order ?? this.order,
    );
  }
}
