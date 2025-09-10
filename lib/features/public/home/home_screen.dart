import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/widgets/school_image.dart';
import '../../../shared/widgets/animated_card.dart';
import '../../../core/theme/school_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'City View School',
      body: Column(
        children: [
          // Hero section with the background image and overlay
          Stack(
            children: [
              // Background image
              SizedBox(
                height: 500, // Reduced height to fit screen better
                width: double.infinity,
                child: Image.asset(
                  'assets/images/school/CombinedParade.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              // Dark overlay
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              // Content
              SizedBox(
                height: 400,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // School name
                        const Text(
                          'CITY VIEW SCHOOL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Tagline
                        const Text(
                          'A Caring Community, A Culture of Excellence',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Buttons - Responsive layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Stack buttons vertically on small screens, horizontally on larger screens
                            final isSmallScreen = constraints.maxWidth < 600;
                            
                            final buttons = [
                              // Enroll Now button
                              SizedBox(
                                width: isSmallScreen ? double.infinity : null,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to admissions page
                                    GoRouter.of(context).go('/admissions');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_document,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'ENROLL NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 0, width: isSmallScreen ? 0 : 20),
                              // Learn More button
                              SizedBox(
                                width: isSmallScreen ? double.infinity : null,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Navigate to about page
                                    GoRouter.of(context).go('/about');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'LEARN MORE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ];
                            
                            return isSmallScreen 
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: buttons,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: buttons,
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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

class _CalloutBand extends StatelessWidget {
  const _CalloutBand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(gradient: SchoolColors.primaryGradient),
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
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final columns =
                      w > 1000
                          ? 3
                          : w > 680
                          ? 2
                          : 1;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(3, (i) {
                      return SizedBox(
                        width: w / columns - (16 * (columns - 1) / columns),
                        child: FeatureCard(
                          icon: _iconFor(i),
                          title: _titleFor(i),
                          description: _descFor(i),
                          onTap: () {
                            // Add navigation or interaction here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Learn more about ${_titleFor(i)}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
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

  Widget _iconFor(int i) {
    switch (i % 3) {
      case 0:
        return SchoolImages.digitalLab(width: 32, height: 32);
      case 1:
        return SchoolImages.sportsActivity(width: 32, height: 32);
      case 2:
        return SchoolImages.healthyMeals(width: 32, height: 32);
      default:
        return const Icon(Icons.school, size: 32);
    }
  }

  String _titleFor(int i) =>
      ['💻 Digital Literacy', '⚽ Sports & Games', '🍎 Healthy Meals'][i % 3];
  String _descFor(int i) =>
      [
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
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                '🏗️ Building Our Future Together',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                          Expanded(
                            child: ConstructionCard(
                              floor: 'Ground & 1st Floor',
                              status: '✅ Completed',
                              description:
                                  'Fully operational classrooms, offices, and facilities',
                              progress: 100,
                              statusColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ConstructionCard(
                              floor: '2nd Floor',
                              status: '🔨 In Progress',
                              description:
                                  'Advanced classrooms and specialized learning spaces',
                              progress: 85,
                              statusColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ConstructionCard(
                              floor: '3rd Floor',
                              status: '📋 Planning',
                              description:
                                  'Future expansion for growing student population',
                              progress: 30,
                              statusColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ConstructionCard(
                              floor: '4th Floor',
                              status: '🎯 Planned',
                              description:
                                  'Additional facilities and administrative offices',
                              progress: 0,
                              statusColor: Colors.grey,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          ConstructionCard(
                            floor: 'Ground & 1st Floor',
                            status: '✅ Completed',
                            description:
                                'Fully operational classrooms, offices, and facilities',
                            progress: 100,
                            statusColor: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          ConstructionCard(
                            floor: '2nd Floor',
                            status: '🔨 In Progress',
                            description:
                                'Advanced classrooms and specialized learning spaces',
                            progress: 85,
                            statusColor: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          ConstructionCard(
                            floor: '3rd Floor',
                            status: '📋 Planning',
                            description:
                                'Future expansion for growing student population',
                            progress: 30,
                            statusColor: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          ConstructionCard(
                            floor: '4th Floor',
                            status: '🎯 Planned',
                            description:
                                'Additional facilities and administrative offices',
                            progress: 0,
                            statusColor: Colors.grey,
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
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
              AnimatedCard(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      SchoolImages.digitalLab(
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      Container(
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
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                '🎓 Student Life at City View',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
                          Expanded(
                            child: AnimatedCard(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Discover our active learning environment!',
                                    ),
                                  ),
                                );
                              },
                              child: _StudentLifeCard(
                                icon: SchoolImages.studentsLearning(
                                  width: 40,
                                  height: 40,
                                ),
                                title: 'Active Learning',
                                description:
                                    'Students engaged in hands-on activities and collaborative projects',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedCard(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Join our vibrant school community!',
                                    ),
                                  ),
                                );
                              },
                              child: _StudentLifeCard(
                                icon: SchoolImages.sportsActivity(
                                  width: 40,
                                  height: 40,
                                ),
                                title: 'Community Spirit',
                                description:
                                    'Building friendships and teamwork in our diverse school community',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedCard(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Explore our exciting events!',
                                    ),
                                  ),
                                );
                              },
                              child: _StudentLifeCard(
                                icon: SchoolImages.healthyMeals(
                                  width: 40,
                                  height: 40,
                                ),
                                title: 'Special Events',
                                description:
                                    'Cultural celebrations, sports days, and educational field trips',
                              ),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          AnimatedCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Discover our active learning environment!',
                                  ),
                                ),
                              );
                            },
                            child: _StudentLifeCard(
                              icon: SchoolImages.studentsLearning(
                                width: 40,
                                height: 40,
                              ),
                              title: 'Active Learning',
                              description:
                                  'Students engaged in hands-on activities and collaborative projects',
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Join our vibrant school community!',
                                  ),
                                ),
                              );
                            },
                            child: _StudentLifeCard(
                              icon: SchoolImages.sportsActivity(
                                width: 40,
                                height: 40,
                              ),
                              title: 'Community Spirit',
                              description:
                                  'Building friendships and teamwork in our diverse school community',
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Explore our exciting events!'),
                                ),
                              );
                            },
                            child: _StudentLifeCard(
                              icon: SchoolImages.healthyMeals(
                                width: 40,
                                height: 40,
                              ),
                              title: 'Special Events',
                              description:
                                  'Cultural celebrations, sports days, and educational field trips',
                            ),
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
  final Widget icon;
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: icon,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
    );
  }
}
