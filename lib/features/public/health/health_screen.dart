import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Health & Nutrition',
      body: ListView(
        children: [
          _HeroSection(),
          const _NutritionPhilosophySection(),
          const _MealPlansSection(),
          const _HealthProgramsSection(),
          const _WellnessTipsSection(),
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
                  'Health & Nutrition',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nourishing minds and bodies for optimal learning',
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

class _NutritionPhilosophySection extends StatelessWidget {
  const _NutritionPhilosophySection();

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
                'Our Nutrition Philosophy',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _PhilosophyCard(
                              icon: Icons.favorite,
                              title: 'Balanced Nutrition',
                              description: 'We believe in providing balanced meals that fuel both the body and mind, ensuring students have the energy and focus needed for optimal learning.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _PhilosophyCard(
                              icon: Icons.eco,
                              title: 'Fresh & Local',
                              description: 'Our meals are prepared using fresh, locally-sourced ingredients whenever possible, supporting both student health and community sustainability.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _PhilosophyCard(
                              icon: Icons.school,
                              title: 'Educational Approach',
                              description: 'We use mealtime as an opportunity to teach students about healthy eating habits and the importance of nutrition in their daily lives.',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _PhilosophyCard(
                              icon: Icons.favorite,
                              title: 'Balanced Nutrition',
                              description: 'We believe in providing balanced meals that fuel both the body and mind, ensuring students have the energy and focus needed for optimal learning.',
                            ),
                            const SizedBox(height: 16),
                            _PhilosophyCard(
                              icon: Icons.eco,
                              title: 'Fresh & Local',
                              description: 'Our meals are prepared using fresh, locally-sourced ingredients whenever possible, supporting both student health and community sustainability.',
                            ),
                            const SizedBox(height: 16),
                            _PhilosophyCard(
                              icon: Icons.school,
                              title: 'Educational Approach',
                              description: 'We use mealtime as an opportunity to teach students about healthy eating habits and the importance of nutrition in their daily lives.',
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

class _PhilosophyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PhilosophyCard({
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
            Icon(icon, size: 48, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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

class _MealPlansSection extends StatelessWidget {
  const _MealPlansSection();

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
                'Weekly Meal Plans',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _MealPlanCard(
                              day: 'Monday',
                              breakfast: 'Oatmeal with berries & nuts',
                              lunch: 'Grilled chicken with vegetables',
                              snack: 'Apple slices with peanut butter',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _MealPlanCard(
                              day: 'Tuesday',
                              breakfast: 'Whole grain toast with eggs',
                              lunch: 'Fish with rice & steamed broccoli',
                              snack: 'Greek yogurt with honey',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _MealPlanCard(
                              day: 'Wednesday',
                              breakfast: 'Smoothie bowl with granola',
                              lunch: 'Turkey sandwich with salad',
                              snack: 'Carrot sticks with hummus',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _MealPlanCard(
                              day: 'Monday',
                              breakfast: 'Oatmeal with berries & nuts',
                              lunch: 'Grilled chicken with vegetables',
                              snack: 'Apple slices with peanut butter',
                            ),
                            const SizedBox(height: 16),
                            _MealPlanCard(
                              day: 'Tuesday',
                              breakfast: 'Whole grain toast with eggs',
                              lunch: 'Fish with rice & steamed broccoli',
                              snack: 'Greek yogurt with honey',
                            ),
                            const SizedBox(height: 16),
                            _MealPlanCard(
                              day: 'Wednesday',
                              breakfast: 'Smoothie bowl with granola',
                              lunch: 'Turkey sandwich with salad',
                              snack: 'Carrot sticks with hummus',
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

class _MealPlanCard extends StatelessWidget {
  final String day;
  final String breakfast;
  final String lunch;
  final String snack;

  const _MealPlanCard({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.snack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _MealItem(
              icon: Icons.wb_sunny,
              title: 'Breakfast',
              description: breakfast,
            ),
            const SizedBox(height: 12),
            _MealItem(
              icon: Icons.restaurant,
              title: 'Lunch',
              description: lunch,
            ),
            const SizedBox(height: 12),
            _MealItem(
              icon: Icons.local_cafe,
              title: 'Snack',
              description: snack,
            ),
          ],
        ),
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MealItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.tertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthProgramsSection extends StatelessWidget {
  const _HealthProgramsSection();

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
                'Health & Wellness Programs',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _HealthProgramCard(
                    icon: Icons.monitor_heart,
                    title: 'Health Monitoring',
                    description: 'Regular health check-ups and monitoring to ensure students maintain optimal health and identify any concerns early.',
                  ),
                  _HealthProgramCard(
                    icon: Icons.psychology,
                    title: 'Mental Wellness',
                    description: 'Programs focused on stress management, emotional well-being, and building resilience in students.',
                  ),
                  _HealthProgramCard(
                    icon: Icons.fitness_center,
                    title: 'Physical Fitness',
                    description: 'Structured physical education programs that promote fitness, coordination, and healthy lifestyle habits.',
                  ),
                  _HealthProgramCard(
                    icon: Icons.medical_services,
                    title: 'First Aid Training',
                    description: 'Basic first aid and safety training for students to promote health awareness and emergency preparedness.',
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

class _HealthProgramCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HealthProgramCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
      ),
    );
  }
}

class _WellnessTipsSection extends StatelessWidget {
  const _WellnessTipsSection();

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
                'Wellness Tips for Students',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _WellnessTipCard(
                              icon: Icons.water_drop,
                              title: 'Stay Hydrated',
                              tip: 'Drink plenty of water throughout the day to maintain energy and focus.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _WellnessTipCard(
                              icon: Icons.bedtime,
                              title: 'Get Enough Sleep',
                              tip: 'Aim for 8-10 hours of sleep each night to support growth and learning.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _WellnessTipCard(
                              icon: Icons.self_improvement,
                              title: 'Practice Mindfulness',
                              tip: 'Take short breaks to breathe deeply and stay present in the moment.',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _WellnessTipCard(
                              icon: Icons.water_drop,
                              title: 'Stay Hydrated',
                              tip: 'Drink plenty of water throughout the day to maintain energy and focus.',
                            ),
                            const SizedBox(height: 16),
                            _WellnessTipCard(
                              icon: Icons.bedtime,
                              title: 'Get Enough Sleep',
                              tip: 'Aim for 8-10 hours of sleep each night to support growth and learning.',
                            ),
                            const SizedBox(height: 16),
                            _WellnessTipCard(
                              icon: Icons.self_improvement,
                              title: 'Practice Mindfulness',
                              tip: 'Take short breaks to breathe deeply and stay present in the moment.',
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

class _WellnessTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tip;

  const _WellnessTipCard({
    required this.icon,
    required this.title,
    required this.tip,
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
            Icon(icon, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              tip,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


