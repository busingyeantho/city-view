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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: q.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No posts found'),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(data['title']?.toString() ?? '(Untitled)'),
                        subtitle: Text('${data['status'] ?? 'draft'} • ${(data['updatedAt'] as Timestamp?)?.toDate().toLocal().toString()}'),
                        onTap: () => context.go('/admin/blog/editor?slug=${data['slug']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


