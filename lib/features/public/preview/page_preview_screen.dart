import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/optimized_image.dart';

class PagePreviewScreen extends StatelessWidget {
  final String pageId;
  final String variant; // 'draft' | 'published'
  const PagePreviewScreen({super.key, required this.pageId, required this.variant});

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance.collection('pages').doc(pageId);
    return ResponsiveScaffold(
      title: 'Preview: $pageId ($variant)',
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};
          final map = (data[variant] ?? {}) as Map<String, dynamic>;
          final heroUrl = map['heroImageUrl'] as String?;
          final heroPath = map['heroImagePath'] as String?;
          return ListView(
            children: [
              if (heroUrl != null && heroUrl.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16/9,
                  child: OptimizedImage(url: heroUrl, storagePath: heroPath),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('This is a basic preview for "$pageId" ($variant).'),
              )
            ],
          );
        },
      ),
    );
  }
}


