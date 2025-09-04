import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Gallery',
      body: ListView(
        children: [
          _HeroSection(),
          const _GalleryCategoriesSection(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiary,
            theme.colorScheme.primary,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'School Gallery',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Capturing moments of learning, growth, and joy',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryCategoriesSection extends StatelessWidget {
  const _GalleryCategoriesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                'Gallery Categories',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _GalleryCategory(
                              title: 'Classroom Activities',
                              description: 'Students engaged in learning, experiments, and creative projects.',
                              imageCount: 24,
                              icon: Icons.school,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _GalleryCategory(
                              title: 'Sports & Games',
                              description: 'Athletic achievements, team sports, and physical education activities.',
                              imageCount: 18,
                              icon: Icons.sports_soccer,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _GalleryCategory(
                              title: 'Special Events',
                              description: 'School celebrations, performances, and memorable occasions.',
                              imageCount: 32,
                              icon: Icons.celebration,
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _GalleryCategory(
                              title: 'Classroom Activities',
                              description: 'Students engaged in learning, experiments, and creative projects.',
                              imageCount: 24,
                              icon: Icons.school,
                            ),
                            const SizedBox(height: 16),
                            _GalleryCategory(
                              title: 'Sports & Games',
                              description: 'Athletic achievements, team sports, and physical education activities.',
                              imageCount: 18,
                              icon: Icons.sports_soccer,
                            ),
                            const SizedBox(height: 16),
                            _GalleryCategory(
                              title: 'Special Events',
                              description: 'School celebrations, performances, and memorable occasions.',
                              imageCount: 32,
                              icon: Icons.celebration,
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 32),
              _SampleGalleryGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryCategory extends StatelessWidget {
  final String title;
  final String description;
  final int imageCount;
  final IconData icon;

  const _GalleryCategory({
    required this.title,
    required this.description,
    required this.imageCount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to specific gallery category
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$imageCount photos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to specific gallery category
                },
                child: const Text('View Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleGalleryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Photos',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 700 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForIndex(index),
                            size: 32,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getTitleForIndex(index),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.science,
      Icons.computer,
      Icons.sports_soccer,
      Icons.palette,
      Icons.music_note,
      Icons.celebration,
      Icons.school,
      Icons.restaurant,
    ];
    return icons[index % icons.length];
  }

  String _getTitleForIndex(int index) {
    final titles = [
      'Science Lab',
      'IT Class',
      'Football',
      'Art Project',
      'Music Lesson',
      'School Event',
      'Classroom',
      'Lunch Time',
    ];
    return titles[index % titles.length];
  }
}


