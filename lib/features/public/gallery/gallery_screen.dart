import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/optimized_image.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Gallery',
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => const OptimizedImage(url: 'https://picsum.photos/seed/cityview/600/400'),
      ),
    );
  }
}


