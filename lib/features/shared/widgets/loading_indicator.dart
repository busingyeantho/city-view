import 'package:flutter/material.dart';

/// A customizable loading indicator widget that can be used throughout the app.
/// 
/// This widget provides a consistent loading experience with optional customization
/// of size and color.
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator.
  final double size;

  /// The color of the loading indicator.
  final Color? color;

  /// The stroke width of the circular progress indicator.
  final double strokeWidth;

  /// Creates a loading indicator with optional customization.
  /// 
  /// [size] The width and height of the loading indicator (defaults to 24.0).
  /// [color] The color of the loading indicator (defaults to primary color).
  /// [strokeWidth] The width of the circular progress indicator (defaults to 2.0).
  const LoadingIndicator({
    Key? key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).colorScheme.primary,
                )
              : null,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// A full-screen loading indicator that can be used to indicate loading states
/// that block the entire screen.
class FullScreenLoading extends StatelessWidget {
  /// The message to display below the loading indicator.
  final String? message;

  /// The color of the loading indicator.
  final Color? color;

  /// Creates a full-screen loading indicator.
  const FullScreenLoading({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(color: color, size: 32.0, strokeWidth: 3.0),
            if (message != null) ...[  
              const SizedBox(height: 16.0),
              Text(
                message!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
