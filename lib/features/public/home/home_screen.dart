import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'City View School',
      body: ListView(
        children: [
          _HeroSection(),
          const _CalloutBand(),
          const _HighlightsGrid(),
          const _ConstructionProgressSection(),
          const _DigitalLabShowcase(),
          const _StudentLifeSection(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Background Image Container
        Container(
          height: 500,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Dark overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '🏫 City View Nursery and Primary School',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                          Text(
                    'IT Digital Community Laboratory • Inspiring Young Minds',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                  const SizedBox(height: 8),
                          Text(
                    'Where Learning Meets Innovation • Building Tomorrow\'s Leaders Today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                    spacing: 16,
                    runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                      ElevatedButton.icon(
                                onPressed: () {},
                        icon: const Icon(Icons.school),
                        label: const Text('Enroll Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                                onPressed: () {},
                        icon: const Icon(Icons.explore),
                        label: const Text('Explore Academics'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                              ),
                            ],
                          ),
                        ],
              ),
                      ),
                    ),
                  ),
                ],
              );
  }
}

class _CalloutBand extends StatelessWidget {
  const _CalloutBand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '🌟 A Caring Community, A Culture of Excellence',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Modern classrooms, digital literacy, sports, and healthy meals — all designed to help every child thrive in our growing campus.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
            padding: const EdgeInsets.all(24),
      child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                '✨ What Makes Us Special',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final columns = w > 1000 ? 3 : w > 680 ? 2 : 1;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(3, (i) {
                      return SizedBox(
                        width: w / columns - (16 * (columns - 1) / columns),
                        child: Card(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surface,
                                  theme.colorScheme.surfaceVariant,
                                ],
                              ),
                            ),
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_iconFor(i), size: 32, color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _titleFor(i),
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                const SizedBox(height: 8),
                                  Text(_descFor(i), style: theme.textTheme.bodyMedium),
                              ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(int i) => [Icons.computer, Icons.sports_soccer, Icons.restaurant][i % 3];
  String _titleFor(int i) => ['💻 Digital Literacy', '⚽ Sports & Games', '🍎 Healthy Meals'][i % 3];
  String _descFor(int i) => [
        'Empowering students with modern IT skills, coding, and digital creativity in our state-of-the-art lab.',
        'Team spirit and fitness through comprehensive sports programs and outdoor activities.',
        'Nutritious, balanced diets prepared fresh daily to support learning and healthy growth.',
      ][i % 3];
}

class _ConstructionProgressSection extends StatelessWidget {
  const _ConstructionProgressSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceVariant,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                '🏗️ Building Our Future Together',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Watch our campus grow as we expand to serve more students',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _ConstructionCard(
                              floor: 'Ground & 1st Floor',
                              status: '✅ Completed',
                              description: 'Fully operational classrooms, offices, and facilities',
                              progress: 100,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ConstructionCard(
                              floor: '2nd Floor',
                              status: '🔨 In Progress',
                              description: 'Advanced classrooms and specialized learning spaces',
                              progress: 85,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ConstructionCard(
                              floor: '3rd Floor',
                              status: '📋 Planning',
                              description: 'Future expansion for growing student population',
                              progress: 30,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ConstructionCard(
                              floor: '4th Floor',
                              status: '🎯 Planned',
                              description: 'Additional facilities and administrative offices',
                              progress: 0,
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _ConstructionCard(
                              floor: 'Ground & 1st Floor',
                              status: '✅ Completed',
                              description: 'Fully operational classrooms, offices, and facilities',
                              progress: 100,
                            ),
                            const SizedBox(height: 16),
                            _ConstructionCard(
                              floor: '2nd Floor',
                              status: '🔨 In Progress',
                              description: 'Advanced classrooms and specialized learning spaces',
                              progress: 85,
                            ),
                            const SizedBox(height: 16),
                            _ConstructionCard(
                              floor: '3rd Floor',
                              status: '📋 Planning',
                              description: 'Future expansion for growing student population',
                              progress: 30,
                            ),
                            const SizedBox(height: 16),
                            _ConstructionCard(
                              floor: '4th Floor',
                              status: '🎯 Planned',
                              description: 'Additional facilities and administrative offices',
                              progress: 0,
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConstructionCard extends StatelessWidget {
  final String floor;
  final String status;
  final String description;
  final int progress;

  const _ConstructionCard({
    required this.floor,
    required this.status,
    required this.description,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              floor,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '$progress% Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DigitalLabShowcase extends StatelessWidget {
  const _DigitalLabShowcase();

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
                '💻 Our IT Digital Community Laboratory',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Preparing students for the digital future with cutting-edge technology',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 6,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2025&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modern Computer Lab',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Equipped with latest computers, interactive whiteboards, and educational software',
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentLifeSection extends StatelessWidget {
  const _StudentLifeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceVariant,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                '🎓 Student Life at City View',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Where every day is an adventure in learning and growth',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _StudentLifeCard(
                              icon: Icons.school,
                              title: 'Active Learning',
                              description: 'Students engaged in hands-on activities and collaborative projects',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _StudentLifeCard(
                              icon: Icons.groups,
                              title: 'Community Spirit',
                              description: 'Building friendships and teamwork in our diverse school community',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _StudentLifeCard(
                              icon: Icons.celebration,
                              title: 'Special Events',
                              description: 'Cultural celebrations, sports days, and educational field trips',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _StudentLifeCard(
                              icon: Icons.school,
                              title: 'Active Learning',
                              description: 'Students engaged in hands-on activities and collaborative projects',
                            ),
                            const SizedBox(height: 16),
                            _StudentLifeCard(
                              icon: Icons.groups,
                              title: 'Community Spirit',
                              description: 'Building friendships and teamwork in our diverse school community',
                            ),
                            const SizedBox(height: 16),
                            _StudentLifeCard(
                              icon: Icons.celebration,
                              title: 'Special Events',
                              description: 'Cultural celebrations, sports days, and educational field trips',
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentLifeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _StudentLifeCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}




