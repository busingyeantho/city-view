import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class BlogAdminListScreen extends StatelessWidget {
  const BlogAdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Blog Admin',
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('blogPosts');
    if (_filter == 'drafts') q = q.where('status', isEqualTo: 'draft');
    if (_filter == 'published') q = q.where('status', isEqualTo: 'published');
    q = q.orderBy('updatedAt', descending: true);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            FilledButton(
              onPressed: () => context.go('/admin/blog/editor'),
              child: const Text('New Post'),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Drafts'),
              selected: _filter == 'drafts',
              onSelected: (_) => setState(() => _filter = _filter == 'drafts' ? 'all' : 'drafts'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Published'),
              selected: _filter == 'published',
              onSelected: (_) => setState(() => _filter = _filter == 'published' ? 'all' : 'published'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: q.snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No posts'));
            }
            return Column(
              children: docs.map((d) {
                final data = d.data();
                return Card(
                  child: ListTile(
                    title: Text(data['title'] ?? '(Untitled)'),
                    subtitle: Text('${data['status'] ?? 'draft'} • ${(data['updatedAt'] as Timestamp?)?.toDate().toLocal()}'),
                    onTap: () => context.go('/admin/blog/editor?slug=${data['slug']}'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}


