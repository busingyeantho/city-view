import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class BlogAdminListScreen extends StatelessWidget {
  const BlogAdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Blog Admin',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              FilledButton(onPressed: () {}, child: const Text('New Post')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Drafts')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Published')),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (i) => Card(child: ListTile(title: Text('Post ${i + 1}'), subtitle: const Text('Author • Status • Updated')))),
        ],
      ),
    );
  }
}


