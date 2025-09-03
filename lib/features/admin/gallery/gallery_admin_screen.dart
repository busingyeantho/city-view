import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class GalleryAdminScreen extends StatelessWidget {
  const GalleryAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Gallery Admin',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Upload Images')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Create Album')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.image),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


