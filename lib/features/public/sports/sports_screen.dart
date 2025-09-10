import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class SportsScreen extends StatelessWidget {
  const SportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Sports',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            const _SportsActivitiesSection(),
            const _AchievementsSection(),
            const _BenefitsSection(),
          ],
        ),
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
            theme.colorScheme.tertiary,
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
                  'Sports & Physical Education',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Building champions in sports and life',
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

class _SportsActivitiesSection extends StatelessWidget {
  const _SportsActivitiesSection();

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
                'Sports Activities',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _SportCard(
                    icon: Icons.sports_soccer,
                    title: 'Football',
                    description: 'Team building, coordination, and strategic thinking through the beautiful game.',
                    ageGroup: 'Ages 5-11',
                  ),
                  _SportCard(
                    icon: Icons.sports_basketball,
                    title: 'Basketball',
                    description: 'Developing agility, teamwork, and quick decision-making skills.',
                    ageGroup: 'Ages 6-11',
                  ),
                  _SportCard(
                    icon: Icons.sports_tennis,
                    title: 'Tennis',
                    description: 'Building hand-eye coordination and individual sportsmanship.',
                    ageGroup: 'Ages 5-11',
                  ),
                  _SportCard(
                    icon: Icons.sports_volleyball,
                    title: 'Volleyball',
                    description: 'Enhancing teamwork, communication, and spatial awareness.',
                    ageGroup: 'Ages 7-11',
                  ),
                  _SportCard(
                    icon: Icons.sports_gymnastics,
                    title: 'Gymnastics',
                    description: 'Building flexibility, strength, and body awareness.',
                    ageGroup: 'Ages 4-11',
                  ),
                  _SportCard(
                    icon: Icons.pool,
                    title: 'Swimming',
                    description: 'Water safety, fitness, and confidence building in the pool.',
                    ageGroup: 'Ages 3-11',
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

class _SportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String ageGroup;

  const _SportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.ageGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.secondary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ageGroup,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
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
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

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
                'Recent Achievements',
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
                              title: 'Inter-School Football Championship',
                              year: '2024',
                              description: 'Our under-10 team secured first place in the regional championship, showcasing excellent teamwork and sportsmanship.',
                              icon: Icons.emoji_events,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _AchievementCard(
                              title: 'Swimming Competition',
                              year: '2024',
                              description: 'Three of our students won medals in the district swimming competition, demonstrating dedication and skill.',
                              icon: Icons.pool,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _AchievementCard(
                              title: 'Athletics Meet',
                              year: '2023',
                              description: 'Outstanding performance in track and field events, with multiple podium finishes across different age groups.',
                              icon: Icons.track_changes,
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _AchievementCard(
                              title: 'Inter-School Football Championship',
                              year: '2024',
                              description: 'Our under-10 team secured first place in the regional championship, showcasing excellent teamwork and sportsmanship.',
                              icon: Icons.emoji_events,
                            ),
                            const SizedBox(height: 16),
                            _AchievementCard(
                              title: 'Swimming Competition',
                              year: '2024',
                              description: 'Three of our students won medals in the district swimming competition, demonstrating dedication and skill.',
                              icon: Icons.pool,
                            ),
                            const SizedBox(height: 16),
                            _AchievementCard(
                              title: 'Athletics Meet',
                              year: '2023',
                              description: 'Outstanding performance in track and field events, with multiple podium finishes across different age groups.',
                              icon: Icons.track_changes,
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

  const _AchievementCard({
    required this.title,
    required this.year,
    required this.description,
    required this.icon,
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
                Icon(icon, size: 32, color: theme.colorScheme.secondary),
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
                        year,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection();

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
                'Benefits of Sports at City View',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _BenefitCard(
                              icon: Icons.fitness_center,
                              title: 'Physical Health',
                              benefits: [
                                'Improved cardiovascular health',
                                'Enhanced motor skills development',
                                'Better coordination and balance',
                                'Increased strength and flexibility',
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _BenefitCard(
                              icon: Icons.psychology,
                              title: 'Mental Well-being',
                              benefits: [
                                'Reduced stress and anxiety',
                                'Improved concentration',
                                'Better sleep patterns',
                                'Enhanced self-confidence',
                              ],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _BenefitCard(
                              icon: Icons.group,
                              title: 'Social Skills',
                              benefits: [
                                'Teamwork and cooperation',
                                'Leadership development',
                                'Communication skills',
                                'Respect for others',
                              ],
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _BenefitCard(
                              icon: Icons.fitness_center,
                              title: 'Physical Health',
                              benefits: [
                                'Improved cardiovascular health',
                                'Enhanced motor skills development',
                                'Better coordination and balance',
                                'Increased strength and flexibility',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _BenefitCard(
                              icon: Icons.psychology,
                              title: 'Mental Well-being',
                              benefits: [
                                'Reduced stress and anxiety',
                                'Improved concentration',
                                'Better sleep patterns',
                                'Enhanced self-confidence',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _BenefitCard(
                              icon: Icons.group,
                              title: 'Social Skills',
                              benefits: [
                                'Teamwork and cooperation',
                                'Leadership development',
                                'Communication skills',
                                'Respect for others',
                              ],
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

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> benefits;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 16, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(benefit, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}


