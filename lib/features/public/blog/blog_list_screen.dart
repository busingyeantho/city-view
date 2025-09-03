import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = FirebaseFirestore.instance.collection('blogPosts').where('status', isEqualTo: 'published').orderBy('publishedAt', descending: true);
    return ResponsiveScaffold(
      title: 'Blog',
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: posts.snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index].data();
              return ListTile(
                title: Text(d['title'] ?? ''),
                subtitle: Text(d['excerpt'] ?? ''),
                onTap: () => context.go('/blog/${d['slug']}'),
              );
            },
          );
        },
      ),
    );
  }
}


