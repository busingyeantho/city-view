import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/live_stream_player.dart';
import '../../../shared/widgets/optimized_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = FirebaseFirestore.instance.collection('pages');
    return ResponsiveScaffold(
      title: 'City View School',
      body: ListView(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: pages.doc('home').snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() ?? {};
              final published = data['published'] ?? {};
              final heroUrl = published['heroImageUrl'] as String?;
              final heroPath = published['heroImagePath'] as String?;
              return Column(
                children: [
                  if (heroUrl != null && heroUrl.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16/9,
                      child: OptimizedImage(url: heroUrl, storagePath: heroPath),
                    ),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('settings').doc('live').snapshots(),
                    builder: (context, snap) {
                      final live = snap.data?.data() ?? {};
                      final isActive = (live['isActive'] ?? false) as bool;
                      final url = live['url'] as String?;
                      if (!isActive || url == null || url.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: AspectRatio(
                          aspectRatio: 16/9,
                          child: LiveStreamPlayer(urlOrEmbed: url),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'IT Digital Community Laboratory',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to City View Nursery and Primary School',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                onPressed: () {},
                                child: const Text('Enroll Now'),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('Learn More'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Highlights', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(3, (i) {
                      return SizedBox(
                        width: 320,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Feature ${i + 1}', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                const Text('Short description goes here...'),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


