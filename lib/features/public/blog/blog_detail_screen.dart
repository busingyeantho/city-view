import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/utils/seo_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/widgets/optimized_image.dart';

class BlogDetailScreen extends StatelessWidget {
  final String slug;
  const BlogDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('blogPosts').where('slug', isEqualTo: slug).limit(1);
    return ResponsiveScaffold(
      title: 'Blog',
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          final doc = (snapshot.data?.docs ?? []).isNotEmpty ? snapshot.data!.docs.first.data() : null;
          if (doc == null) {
            return const Center(child: Text('Post not found'));
          }
          setPageSeo(title: doc['metaTitle'] ?? doc['title'] ?? 'Blog', description: doc['metaDescription'] ?? doc['excerpt']);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextRenderer(
                child: Text(doc['title'] ?? '', style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Share',
                    onPressed: () => Share.shareUri(Uri.base),
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if ((doc['coverImage'] ?? '').toString().isNotEmpty)
                ImageRenderer(
                  alt: doc['title'] ?? '',
                  child: OptimizedImage(url: doc['coverImage'], storagePath: doc['coverPath']),
                ),
              const SizedBox(height: 16),
              TextRenderer(
                child: Text(doc['excerpt'] ?? ''),
              ),
              const SizedBox(height: 24),
              // For now, render content as plain text if html not provided
              if ((doc['html'] ?? '').toString().isNotEmpty)
                SelectableText(doc['html'])
              else
                SelectableText((doc['contentDelta'] ?? '').toString()),
            ],
          );
        },
      ),
    );
  }
}


