class GalleryCategory {
  final String id;
  final String name;
  final String? description;
  final int imageCount;

  const GalleryCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageCount = 0,
  });

  GalleryCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? imageCount,
  }) {
    return GalleryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageCount: imageCount ?? this.imageCount,
    );
  }
}
