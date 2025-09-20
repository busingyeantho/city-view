import 'dart:async';
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
      body: SingleChildScrollView(
        child: Column(
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
                              SizedBox(
                                height: isSmallScreen ? 16 : 0,
                                width: isSmallScreen ? 0 : 20,
                              ),
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
          const _SpecialTwoColumnShowcase(),
          const _ConstructionProgressSection(),
          const _DigitalLabShowcase(),
          const _StudentLifeSection(),
        ],
      ),
    ),
    );
  }
}

// New: Two-column section with description and image slider
class _SpecialTwoColumnShowcase extends StatefulWidget {
  const _SpecialTwoColumnShowcase();

  @override
  State<_SpecialTwoColumnShowcase> createState() => _SpecialTwoColumnShowcaseState();
}

class _SpecialTwoColumnShowcaseState extends State<_SpecialTwoColumnShowcase> {
  final GlobalKey _leftKey = GlobalKey();
  double? _leftHeight;

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _leftKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          final h = box.size.height;
          if (_leftHeight == null || (_leftHeight! - h).abs() > 1.0) {
            setState(() => _leftHeight = h);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _scheduleMeasure();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              // Left column content (no Expanded here; wrap later if needed)
              final leftColumn = Column(
                key: _leftKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What Makes Our Community Special',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Beyond facilities, it\'s the people, programs, and daily experiences that shape our learners. Explore a glimpse of life at City View.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BulletPoint(
                    title: 'Games and Sports',
                    subtitle:
                        'Teamwork, fitness, and fair play through vibrant activities.',
                  ),
                  _BulletPoint(
                    title: 'Digital Skilling',
                    subtitle: 'AI literacy and responsible use, professional digital presentation and communication, career-oriented IT, and business technology skills.',
                  ),
                  _BulletPoint(
                    title: 'Healthy Meals & Diet',
                    subtitle:
                        'Balanced nutrition to fuel learning and growth.',
                  ),
                  _BulletPoint(
                    title: 'Dedicated Staff',
                    subtitle:
                        'Caring teachers committed to every learner\'s success.',
                  ),
                  _BulletPoint(
                    title: 'Academic Environment',
                    subtitle:
                        'Structured, supportive, and engaging classrooms.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            () => GoRouter.of(context).go('/contact'),
                        icon: const Icon(Icons.school),
                        label: const Text('Visit Us'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            () => GoRouter.of(context).go('/admissions'),
                        icon: const Icon(Icons.edit_document),
                        label: const Text('Enroll Now'),
                      ),
                    ],
                  ),
                ],
              );

              // Right carousel (no Expanded here; wrap later if needed)
              final rightCarousel = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final aspect = isWide ? (16 / 9) : (4 / 3);
                    final computed = c.maxWidth / aspect;
                    // If we measured left column and we are wide, match heights; otherwise use computed clamp
                    final height = isWide && _leftHeight != null
                        ? _leftHeight!.clamp(280.0, 800.0)
                        : computed.clamp(320.0, 520.0);
                    return SizedBox(
                      height: height,
                      child: _ImageCarousel(
                        images: const [
                          'assets/images/school/SchoolDirector.jpg',
                          'assets/images/school/SchoolDirector,WifeandSon.jpg',
                          'assets/images/school/ConstructionWorkGoingon.jpg',
                          'assets/images/school/SchoolpupilsonAssembly.jpg',
                          'assets/images/school/SchoolDirectorWithPupilsOverWeekend.jpg',
                        ],
                        captions: const [
                          'Leadership — School Director at City View',
                          'Family — School Director with Family',
                          'Campus — Construction Work Ongoing',
                          'Community — Pupils on Assembly',
                          'Weekend — Director with Pupils',
                        ],
                        alignments: const [
                          Alignment.center, // Director portrait
                          Alignment.topCenter, // Family photo: favor heads
                          Alignment.center, // Construction
                          Alignment.center, // Assembly
                          Alignment.center, // Weekend
                        ],
                      ),
                    );
                  },
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: leftColumn),
                    const SizedBox(width: 24, height: 24),
                    Expanded(flex: 6, child: rightCarousel),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rightCarousel,
                    const SizedBox(height: 16),
                    leftColumn,
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String title;
  final String subtitle;
  const _BulletPoint({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  final List<String>? captions;
  final List<Alignment>? alignments; // optional per-image alignment
  const _ImageCarousel({required this.images, this.captions, this.alignments});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _controller;
  int _current = 0;
  bool _didPrecache = false;
  Timer? _autoTimer;
  bool _isPaused = false;
  static const Duration _autoInterval = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoplay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images once to avoid jank on first swipe
    if (!_didPrecache) {
      final mq = MediaQuery.of(context);
      final dpr = mq.devicePixelRatio;
      final logicalWidth = mq.size.width;
      // Choose a reasonable cap for decoded width depending on screen size
      final capWidthPx = (logicalWidth * dpr).clamp(800, 1600).toInt();
      for (final path in widget.images) {
        // Precache a resized variant to reduce initial decode/memory cost
        precacheImage(ResizeImage(AssetImage(path), width: capWidthPx), context);
      }
      _didPrecache = true;
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content = Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) {
            setState(() => _current = i);
            _restartAutoplay();
          },
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, c) {
                final dpr = MediaQuery.of(context).devicePixelRatio;
                final isWide = c.maxWidth > 900;
                // Compute natural target size from layout
                var targetWidthPx = (c.maxWidth * dpr).clamp(300, 4096).toInt();
                var targetHeightPx = (c.maxHeight * dpr).clamp(200, 4096).toInt();
                // Cap aggressively to reduce bandwidth/CPU without noticeable quality loss
                final maxCapW = isWide ? 1800 : 1400;
                final maxCapH = isWide ? 1100 : 900;
                targetWidthPx = targetWidthPx.clamp(300, maxCapW);
                targetHeightPx = targetHeightPx.clamp(200, maxCapH);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.images[index],
                      fit: BoxFit.cover,
                      alignment: widget.alignments != null &&
                              index < widget.alignments!.length
                          ? widget.alignments![index]
                          : Alignment.center,
                      cacheWidth: targetWidthPx,
                      cacheHeight: targetHeightPx,
                      gaplessPlayback: true,
                      // Medium gives a nice balance; can use low on very slow devices
                      filterQuality: FilterQuality.medium,
                    ),
                    // Gradient caption overlay
                    if (widget.captions != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.captions![index],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        // Dots indicator
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final active = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: active ? 20 : 8,
                decoration: BoxDecoration(
                  color: active ? theme.colorScheme.primary : Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),
        // Prev/Next controls
        Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: _NavButton(
            icon: Icons.chevron_left,
            onTap: () {
              final prev = (_current - 1) % widget.images.length;
              _controller.animateToPage(
                prev < 0 ? widget.images.length - 1 : prev,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
              _restartAutoplay();
            },
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: _NavButton(
            icon: Icons.chevron_right,
            onTap: () {
              final next = (_current + 1) % widget.images.length;
              _controller.animateToPage(
                next,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
              _restartAutoplay();
            },
          ),
        ),
      ],
    );

    // Pause on hover (desktop/web) and on touch/drag (mobile)
    return MouseRegion(
      onEnter: (_) => _pauseAutoplay(),
      onExit: (_) => _resumeAutoplay(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pauseAutoplay(),
        onTapUp: (_) => _resumeAutoplay(),
        onTapCancel: _resumeAutoplay,
        onPanDown: (_) => _pauseAutoplay(),
        onPanCancel: _resumeAutoplay,
        onPanEnd: (_) => _resumeAutoplay(),
        child: content,
      ),
    );
  }

  void _startAutoplay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoInterval, (_) => _tick());
  }

  void _restartAutoplay() {
    if (_isPaused) return; // keep paused if user is interacting
    _startAutoplay();
  }

  void _pauseAutoplay() {
    _isPaused = true;
    _autoTimer?.cancel();
  }

  void _resumeAutoplay() {
    if (!_isPaused) return;
    _isPaused = false;
    _startAutoplay();
  }

  void _tick() {
    if (!mounted || _isPaused || widget.images.isEmpty) return;
    final next = (_current + 1) % widget.images.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
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
                    children: List.generate(4, (i) {
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
    switch (i % 4) {
      case 0:
        return SchoolImages.digitalLab(width: 32, height: 32);
      case 1:
        return SchoolImages.sportsActivity(width: 32, height: 32);
      case 2:
        return SchoolImages.healthyMeals(width: 32, height: 32);
      case 3:
        return const Icon(Icons.psychology_alt, size: 32);
      default:
        return const Icon(Icons.school, size: 32);
    }
  }

  String _titleFor(int i) =>
      ['💻 Digital Literacy', '⚽ Sports & Games', '🍎 Healthy Meals', '🧠 Digital Skilling'][i % 4];
  String _descFor(int i) =>
      [
        'Empowering students with modern IT skills, coding, and digital creativity in our state-of-the-art lab.',
        'Team spirit and fitness through comprehensive sports programs and outdoor activities.',
        'Nutritious, balanced diets prepared fresh daily to support learning and healthy growth.',
        'AI literacy and responsible use, professional digital presentation and communication, career-oriented IT, and business technology skills.',
      ][i % 4];
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
                      ? const Row(
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
                          SizedBox(width: 16),
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
                          SizedBox(width: 16),
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
                          SizedBox(width: 16),
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
                      : const Column(
                        children: [
                          ConstructionCard(
                            floor: 'Ground & 1st Floor',
                            status: '✅ Completed',
                            description:
                                'Fully operational classrooms, offices, and facilities',
                            progress: 100,
                            statusColor: Colors.green,
                          ),
                          SizedBox(height: 16),
                          ConstructionCard(
                            floor: '2nd Floor',
                            status: '🔨 In Progress',
                            description:
                                'Advanced classrooms and specialized learning spaces',
                            progress: 85,
                            statusColor: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          ConstructionCard(
                            floor: '3rd Floor',
                            status: '📋 Planning',
                            description:
                                'Future expansion for growing student population',
                            progress: 30,
                            statusColor: Colors.blue,
                          ),
                          SizedBox(height: 16),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 400, // Increased height to better fit the image
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Image.asset(
                        'assets/images/school/CommunityDigitalLab2.png',
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
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
                          padding: const EdgeInsets.all(24.0),
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
