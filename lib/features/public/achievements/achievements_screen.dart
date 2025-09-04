import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Achievements',
      body: ListView(
        children: [
          _HeroSection(),
          const _AcademicExcellenceSection(),
          const _SportsAchievementsSection(),
          const _ArtsAndCreativitySection(),
          const _CommunityServiceSection(),
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
            theme.colorScheme.secondary,
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
                  'Student Achievements',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Celebrating excellence and recognizing outstanding accomplishments',
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

class _AcademicExcellenceSection extends StatelessWidget {
  const _AcademicExcellenceSection();

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
                'Academic Excellence',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _AchievementCard(
                              title: 'Mathematics Olympiad',
                              year: '2024',
                              description: 'Our students secured top positions in the regional mathematics competition, demonstrating exceptional problem-solving skills.',
                              icon: Icons.calculate,
                              category: 'Mathematics',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _AchievementCard(
                              title: 'Science Fair Winners',
                              year: '2024',
                              description: 'Innovative science projects earned our students recognition at the district science fair, showcasing creativity and scientific thinking.',
                              icon: Icons.science,
                              category: 'Science',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _AchievementCard(
                              title: 'Reading Champions',
                              year: '2023',
                              description: 'Students achieved remarkable reading milestones, with several completing reading challenges and literacy programs.',
                              icon: Icons.menu_book,
                              category: 'Literacy',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _AchievementCard(
                              title: 'Mathematics Olympiad',
                              year: '2024',
                              description: 'Our students secured top positions in the regional mathematics competition, demonstrating exceptional problem-solving skills.',
                              icon: Icons.calculate,
                              category: 'Mathematics',
                            ),
                            const SizedBox(height: 16),
                            _AchievementCard(
                              title: 'Science Fair Winners',
                              year: '2024',
                              description: 'Innovative science projects earned our students recognition at the district science fair, showcasing creativity and scientific thinking.',
                              icon: Icons.science,
                              category: 'Science',
                            ),
                            const SizedBox(height: 16),
                            _AchievementCard(
                              title: 'Reading Champions',
                              year: '2023',
                              description: 'Students achieved remarkable reading milestones, with several completing reading challenges and literacy programs.',
                              icon: Icons.menu_book,
                              category: 'Literacy',
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

class _AchievementCard extends StatelessWidget {
  final String title;
  final String year;
  final String description;
  final IconData icon;
  final String category;

  const _AchievementCard({
    required this.title,
    required this.year,
    required this.description,
    required this.icon,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    year,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

class _SportsAchievementsSection extends StatelessWidget {
  const _SportsAchievementsSection();

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
                'Sports & Athletics',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _SportsAchievementCard(
                    sport: 'Football',
                    achievement: 'Regional Champions',
                    year: '2024',
                    description: 'Under-10 team won the regional championship with outstanding teamwork and skill.',
                    icon: Icons.sports_soccer,
                  ),
                  _SportsAchievementCard(
                    sport: 'Swimming',
                    achievement: 'District Medals',
                    year: '2024',
                    description: 'Multiple students won medals in various swimming categories at district competitions.',
                    icon: Icons.pool,
                  ),
                  _SportsAchievementCard(
                    sport: 'Athletics',
                    achievement: 'Track Records',
                    year: '2023',
                    description: 'Students set new school records in track and field events across different age groups.',
                    icon: Icons.track_changes,
                  ),
                  _SportsAchievementCard(
                    sport: 'Basketball',
                    achievement: 'Tournament Winners',
                    year: '2023',
                    description: 'Our basketball teams excelled in inter-school tournaments, showcasing talent and dedication.',
                    icon: Icons.sports_basketball,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportsAchievementCard extends StatelessWidget {
  final String sport;
  final String achievement;
  final String year;
  final String description;
  final IconData icon;

  const _SportsAchievementCard({
    required this.sport,
    required this.achievement,
    required this.year,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.secondary),
              const SizedBox(height: 16),
              Text(
                sport,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                year,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtsAndCreativitySection extends StatelessWidget {
  const _ArtsAndCreativitySection();

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
                'Arts & Creativity',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _ArtsCard(
                              icon: Icons.palette,
                              title: 'Art Exhibition',
                              description: 'Student artwork was featured in a local gallery, showcasing creativity and artistic talent.',
                              year: '2024',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ArtsCard(
                              icon: Icons.music_note,
                              title: 'Music Festival',
                              description: 'Our choir and instrumental groups performed at the regional music festival, earning recognition for their musical excellence.',
                              year: '2024',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ArtsCard(
                              icon: Icons.theater_comedy,
                              title: 'Drama Performance',
                              description: 'Students staged a successful theatrical production, demonstrating acting skills and stage presence.',
                              year: '2023',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _ArtsCard(
                              icon: Icons.palette,
                              title: 'Art Exhibition',
                              description: 'Student artwork was featured in a local gallery, showcasing creativity and artistic talent.',
                              year: '2024',
                            ),
                            const SizedBox(height: 16),
                            _ArtsCard(
                              icon: Icons.music_note,
                              title: 'Music Festival',
                              description: 'Our choir and instrumental groups performed at the regional music festival, earning recognition for their musical excellence.',
                              year: '2024',
                            ),
                            const SizedBox(height: 16),
                            _ArtsCard(
                              icon: Icons.theater_comedy,
                              title: 'Drama Performance',
                              description: 'Students staged a successful theatrical production, demonstrating acting skills and stage presence.',
                              year: '2023',
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

class _ArtsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String year;

  const _ArtsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.year,
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
            Icon(icon, size: 48, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              year,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.tertiary,
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
          ],
        ),
      ),
    );
  }
}

class _CommunityServiceSection extends StatelessWidget {
  const _CommunityServiceSection();

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
                'Community Service & Leadership',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ServiceCard(
                    icon: Icons.volunteer_activism,
                    title: 'Community Outreach',
                    description: 'Students organized food drives and charity events, demonstrating compassion and leadership.',
                    impact: '500+ families helped',
                  ),
                  _ServiceCard(
                    icon: Icons.eco,
                    title: 'Environmental Projects',
                    description: 'Green initiatives led by students including tree planting and recycling programs.',
                    impact: '100+ trees planted',
                  ),
                  _ServiceCard(
                    icon: Icons.elderly,
                    title: 'Senior Care Program',
                    description: 'Regular visits to local nursing homes, bringing joy and companionship to elderly residents.',
                    impact: 'Monthly visits',
                  ),
                  _ServiceCard(
                    icon: Icons.school,
                    title: 'Peer Tutoring',
                    description: 'Older students mentor younger ones, creating a supportive learning environment.',
                    impact: '50+ students mentored',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String impact;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  impact,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
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


