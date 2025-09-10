import 'package:flutter/material.dart';
import '../../../shared/ui/responsive_scaffold.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Academics',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            const _ProgramsSection(),
            const _CurriculumSection(),
            const _FacilitiesSection(),
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
            theme.colorScheme.primary,
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
                  'Academic Excellence',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Preparing students for success in the digital age',
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

class _ProgramsSection extends StatelessWidget {
  const _ProgramsSection();

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
                'Academic Programs',
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
                            Expanded(child: _ProgramCard(
                              title: 'Nursery Program',
                              age: 'Ages 2-4',
                              description: 'Early childhood development through play-based learning, creativity, and social interaction.',
                              features: ['Play-based learning', 'Social skills development', 'Creative expression', 'Basic numeracy & literacy'],
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _ProgramCard(
                              title: 'Primary Program',
                              age: 'Ages 5-11',
                              description: 'Comprehensive primary education with focus on core subjects and digital literacy.',
                              features: ['Core curriculum', 'Digital literacy', 'STEM education', 'Character development'],
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _ProgramCard(
                              title: 'Nursery Program',
                              age: 'Ages 2-4',
                              description: 'Early childhood development through play-based learning, creativity, and social interaction.',
                              features: ['Play-based learning', 'Social skills development', 'Creative expression', 'Basic numeracy & literacy'],
                            ),
                            const SizedBox(height: 16),
                            _ProgramCard(
                              title: 'Primary Program',
                              age: 'Ages 5-11',
                              description: 'Comprehensive primary education with focus on core subjects and digital literacy.',
                              features: ['Core curriculum', 'Digital literacy', 'STEM education', 'Character development'],
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

class _ProgramCard extends StatelessWidget {
  final String title;
  final String age;
  final String description;
  final List<String> features;

  const _ProgramCard({
    required this.title,
    required this.age,
    required this.description,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        age,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
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
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Key Features:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection();

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
                'Our Curriculum',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _SubjectCard(
                    icon: Icons.calculate,
                    title: 'Mathematics',
                    description: 'Building strong numerical foundations and problem-solving skills.',
                  ),
                  _SubjectCard(
                    icon: Icons.menu_book,
                    title: 'English Language',
                    description: 'Developing reading, writing, and communication abilities.',
                  ),
                  _SubjectCard(
                    icon: Icons.science,
                    title: 'Science',
                    description: 'Exploring the natural world through hands-on experiments.',
                  ),
                  _SubjectCard(
                    icon: Icons.computer,
                    title: 'Digital Literacy',
                    description: 'Preparing students for the technology-driven future.',
                  ),
                  _SubjectCard(
                    icon: Icons.palette,
                    title: 'Arts & Creativity',
                    description: 'Fostering imagination and artistic expression.',
                  ),
                  _SubjectCard(
                    icon: Icons.sports_soccer,
                    title: 'Physical Education',
                    description: 'Promoting health, fitness, and teamwork.',
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

class _SubjectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SubjectCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
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

class _FacilitiesSection extends StatelessWidget {
  const _FacilitiesSection();

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
                'Modern Facilities',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: _FacilityCard(
                              icon: Icons.computer,
                              title: 'IT Digital Lab',
                              description: 'State-of-the-art computer lab with modern equipment and software for digital literacy education.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _FacilityCard(
                              icon: Icons.science,
                              title: 'Science Laboratory',
                              description: 'Well-equipped science lab for hands-on experiments and scientific discovery.',
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _FacilityCard(
                              icon: Icons.library_books,
                              title: 'Library',
                              description: 'Extensive collection of books and digital resources to support learning.',
                            )),
                          ],
                        )
                      : Column(
                          children: [
                            _FacilityCard(
                              icon: Icons.computer,
                              title: 'IT Digital Lab',
                              description: 'State-of-the-art computer lab with modern equipment and software for digital literacy education.',
                            ),
                            const SizedBox(height: 16),
                            _FacilityCard(
                              icon: Icons.science,
                              title: 'Science Laboratory',
                              description: 'Well-equipped science lab for hands-on experiments and scientific discovery.',
                            ),
                            const SizedBox(height: 16),
                            _FacilityCard(
                              icon: Icons.library_books,
                              title: 'Library',
                              description: 'Extensive collection of books and digital resources to support learning.',
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

class _FacilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FacilityCard({
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
            Icon(icon, size: 48, color: theme.colorScheme.primary),
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


