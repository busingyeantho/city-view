import 'package:flutter/material.dart';
import '../../core/theme/school_colors.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// A reusable widget for displaying school-branded images
/// with consistent styling and fallback handling
class SchoolImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SchoolImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );

    if (placeholder != null) {
      imageWidget = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget();
        },
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}

/// Custom painted widgets for school images with animations
class SchoolImagePainter extends StatefulWidget {
  final double? width;
  final double? height;
  final SchoolImageType type;
  final bool enableAnimation;
  final Duration animationDuration;

  const SchoolImagePainter({
    super.key,
    this.width,
    this.height,
    required this.type,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<SchoolImagePainter> createState() => _SchoolImagePainterState();
}

class _SchoolImagePainterState extends State<SchoolImagePainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.enableAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width ?? 200, widget.height ?? 200),
          painter: _SchoolImageCustomPainter(
            widget.type,
            animationValue: widget.enableAnimation ? _animation.value : 1.0,
          ),
        );
      },
    );
  }
}

enum SchoolImageType {
  heroBackground,
  digitalLab,
  schoolLogo,
  studentsLearning,
  sportsActivity,
  healthyMeals,
}

class _SchoolImageCustomPainter extends CustomPainter {
  final SchoolImageType type;
  final double animationValue;

  _SchoolImageCustomPainter(this.type, {this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    switch (type) {
      case SchoolImageType.heroBackground:
        _paintHeroBackground(canvas, size, paint);
        break;
      case SchoolImageType.digitalLab:
        _paintDigitalLab(canvas, size, paint);
        break;
      case SchoolImageType.schoolLogo:
        _paintSchoolLogo(canvas, size, paint);
        break;
      case SchoolImageType.studentsLearning:
        _paintStudentsLearning(canvas, size, paint);
        break;
      case SchoolImageType.sportsActivity:
        _paintSportsActivity(canvas, size, paint);
        break;
      case SchoolImageType.healthyMeals:
        _paintHealthyMeals(canvas, size, paint);
        break;
    }
  }

  void _paintHeroBackground(Canvas canvas, Size size, Paint paint) {
    // Draw background image
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = null;
    paint.color = SchoolColors.primary;
    canvas.drawRect(rect, paint);

    // Note: For a real image, you'll need to modify the SchoolImage widget
    // to properly handle image assets. The current implementation only supports
    // vector drawings and gradients.

    // For now, we'll keep the animated building
    paint.color = SchoolColors.secondary3.withOpacity(animationValue);
    final buildingRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3 + (1 - animationValue) * 100,
      size.width * 0.6,
      size.height * 0.5,
    );
    canvas.drawRect(buildingRect, paint);

    // Animated building details (windows appear with delay)
    paint.color = SchoolColors.primaryDark.withOpacity(0.4 * animationValue);
    for (int i = 0; i < 4; i++) {
      final windowAnimation = (animationValue - i * 0.2).clamp(0.0, 1.0);
      if (windowAnimation > 0) {
        final windowRect = Rect.fromLTWH(
          size.width * 0.25 + i * size.width * 0.12,
          size.height * 0.4,
          size.width * 0.08,
          size.height * 0.15,
        );
        canvas.drawRect(windowRect, paint);
      }
    }

    // Animated title (fades in from top)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'City View School',
        style: TextStyle(
          color: SchoolColors.lightText.withOpacity(animationValue),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width * 0.5 - textPainter.width / 2,
        size.height * 0.1 - (1 - animationValue) * 50,
      ),
    );
  }

  void _paintDigitalLab(Canvas canvas, Size size, Paint paint) async {
    // Draw the background image
    final image = await loadAsset(
      'assets/images/school/CommunityDigitalLab2.png',
    );
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Use a Paint object with the image shader
    paint.shader = ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity()
          .scaled(size.width / imageSize.width, size.height / imageSize.height)
          .storage,
    );

    // Draw the image
    canvas.drawRect(imageRect, paint);

    // Reset shader for any other drawing
    paint.shader = null;

    // Add a semi-transparent overlay for better text readability
    paint.color = Colors.black.withOpacity(0.3 * animationValue);
    canvas.drawRect(imageRect, paint);
  }

  void _paintSchoolLogo(Canvas canvas, Size size, Paint paint) {
    // Background circle using school colors
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    final gradient = SchoolColors.primaryGradient;
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    canvas.drawCircle(center, radius, paint);

    // School building
    paint.shader = null;
    paint.color = SchoolColors.secondary3;
    final buildingRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.3,
    );
    canvas.drawRect(buildingRect, paint);

    // Title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'CITY VIEW\nSCHOOL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.8),
    );
  }

  void _paintStudentsLearning(Canvas canvas, Size size, Paint paint) {
    // Background using school colors
    paint.color = SchoolColors.secondary3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Students (simplified circles)
    paint.color = SchoolColors.primary;
    for (int i = 0; i < 5; i++) {
      final studentCenter = Offset(
        size.width * 0.2 + i * size.width * 0.15,
        size.height * 0.5,
      );
      canvas.drawCircle(studentCenter, size.width * 0.05, paint);
    }

    // Title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Active Learning Environment',
        style: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.1),
    );
  }

  void _paintSportsActivity(Canvas canvas, Size size, Paint paint) {
    // Background using school colors
    paint.color = SchoolColors.secondary1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Field lines
    paint.color = SchoolColors.secondary3;
    paint.strokeWidth = 3;
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );

    // Students
    paint.color = SchoolColors.primary;
    for (int i = 0; i < 4; i++) {
      final studentCenter = Offset(
        size.width * 0.2 + i * size.width * 0.2,
        size.height * 0.6,
      );
      canvas.drawCircle(studentCenter, size.width * 0.04, paint);
    }

    // Title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Sports & Physical Education',
        style: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.1),
    );
  }

  void _paintHealthyMeals(Canvas canvas, Size size, Paint paint) {
    // Background using school colors
    paint.color = SchoolColors.secondary3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Food items
    paint.color = SchoolColors.secondary1;
    for (int i = 0; i < 5; i++) {
      final foodCenter = Offset(
        size.width * 0.2 + i * size.width * 0.15,
        size.height * 0.3,
      );
      canvas.drawCircle(foodCenter, size.width * 0.05, paint);
    }

    // Title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Healthy Meals & Nutrition',
        style: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<ui.Image> loadAsset(String asset) async {
  final ByteData data = await rootBundle.load(asset);
  final ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

/// Predefined school image widgets for common use cases
class SchoolImages {
  static Widget heroBackground({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget image = SchoolImagePainter(
      width: width,
      height: height,
      type: SchoolImageType.heroBackground,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  static Widget digitalLab({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget image = SchoolImagePainter(
      width: width,
      height: height,
      type: SchoolImageType.digitalLab,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  static Widget schoolLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
  }) {
    Widget image = Image.asset(
      'assets/images/school/CityView.jpeg',
      width: width,
      height: height,
      fit: fit,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    } else {
      // Apply circular clip by default for the badge
      image = ClipOval(child: image);
    }

    return image;
  }

  static Widget studentsLearning({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget image = SchoolImagePainter(
      width: width,
      height: height,
      type: SchoolImageType.studentsLearning,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  static Widget sportsActivity({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget image = SchoolImagePainter(
      width: width,
      height: height,
      type: SchoolImageType.sportsActivity,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  static Widget healthyMeals({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget image = SchoolImagePainter(
      width: width,
      height: height,
      type: SchoolImageType.healthyMeals,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }
}
