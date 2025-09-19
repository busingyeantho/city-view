class GalleryImage {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  const GalleryImage({
    required this.id,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });

  GalleryImage copyWith({
    String? id,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
