import 'package:cloud_firestore/cloud_firestore.dart';

class PageData {
  final String id;
  final String title;
  final String slug;
  final Map<String, dynamic> content;
  final Map<String, dynamic>? draft;
  final bool isPublished;
  final String? heroImageUrl;
  final String? seoDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  PageData({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.draft,
    this.isPublished = false,
    this.heroImageUrl,
    this.seoDescription,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory PageData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PageData(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      slug: data['slug'] ?? '',
      content: Map<String, dynamic>.from(data['content'] ?? {}),
      draft:
          data['draft'] != null
              ? Map<String, dynamic>.from(data['draft'] as Map)
              : null,
      isPublished: data['isPublished'] ?? false,
      heroImageUrl: data['heroImageUrl'],
      seoDescription: data['seoDescription'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'slug': slug,
      'content': content,
      if (draft != null) 'draft': draft,
      'isPublished': isPublished,
      if (heroImageUrl != null) 'heroImageUrl': heroImageUrl,
      if (seoDescription != null) 'seoDescription': seoDescription,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      if (createdBy != null) 'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  PageData copyWith({
    String? id,
    String? title,
    String? slug,
    Map<String, dynamic>? content,
    Map<String, dynamic>? draft,
    bool? isPublished,
    String? heroImageUrl,
    String? seoDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PageData(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      content: content ?? this.content,
      draft: draft ?? this.draft,
      isPublished: isPublished ?? this.isPublished,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      seoDescription: seoDescription ?? this.seoDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
