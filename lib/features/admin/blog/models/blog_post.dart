import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String authorId;
  final String status; // 'draft' or 'published'
  final List<String> tags;
  final String? coverImageUrl;
  final String? metaTitle;
  final String? metaDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    required this.authorId,
    required this.status,
    this.tags = const [],
    this.coverImageUrl,
    this.metaTitle,
    this.metaDescription,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  // Convert model to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'authorId': authorId,
      'status': status,
      'tags': tags,
      'coverImageUrl': coverImageUrl,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
    };
  }

  // Create model from Firestore document
  factory BlogPost.fromMap(String id, Map<String, dynamic> map) {
    return BlogPost(
      id: id,
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      content: map['content'] ?? '',
      excerpt: map['excerpt'] ?? '',
      authorId: map['authorId'] ?? '',
      status: map['status'] ?? 'draft',
      tags: List<String>.from(map['tags'] ?? []),
      coverImageUrl: map['coverImageUrl'],
      metaTitle: map['metaTitle'],
      metaDescription: map['metaDescription'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create a copy of the model with some fields updated
  BlogPost copyWith({
    String? id,
    String? title,
    String? slug,
    String? content,
    String? excerpt,
    String? authorId,
    String? status,
    List<String>? tags,
    String? coverImageUrl,
    String? metaTitle,
    String? metaDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      authorId: authorId ?? this.authorId,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
