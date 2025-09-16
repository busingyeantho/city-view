import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget to display error messages with optional retry and copy functionality.
class ErrorDisplay extends StatelessWidget {
  /// The error message to display.
  final String message;
  
  /// The error object (optional).
  final Object? error;
  
  /// The stack trace (optional).
  final StackTrace? stackTrace;
  
  /// Callback when the retry button is pressed.
  final VoidCallback? onRetry;
  
  /// Whether to show a retry button.
  final bool showRetry;
  
  /// Whether to show a button to copy the error details.
  final bool showCopyButton;
  
  /// The alignment of the error content.
  final AlignmentGeometry alignment;

  /// Creates an error display widget.
  const ErrorDisplay({
    Key? key,
    required this.message,
    this.error,
    this.stackTrace,
    this.onRetry,
    this.showRetry = true,
    this.showCopyButton = true,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: alignment,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      message,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              if (error != null) ..._buildErrorDetails(),
              const SizedBox(height: 16.0),
              if (showRetry || showCopyButton)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showCopyButton)
                      TextButton.icon(
                        onPressed: _copyErrorDetails,
                        icon: const Icon(Icons.copy, size: 16.0),
                        label: const Text('Copy Error'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    if (showRetry && onRetry != null) ...[
                      const SizedBox(width: 8.0),
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16.0),
                        label: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildErrorDetails() {
    if (error == null) return [];

    final errorDetails = [
      if (error != null) 'Error: $error',
      if (stackTrace != null) '\n\nStack trace:\n$stackTrace',
    ].join('\n');

    return [
      const SizedBox(height: 12.0),
      SelectableText(
        errorDetails,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.0,
        ),
      ),
    ];
  }

  void _copyErrorDetails() {
    final errorDetails = [
      message,
      if (error != null) '\nError: $error',
      if (stackTrace != null) '\n\nStack trace:\n$stackTrace',
    ].join('');

    Clipboard.setData(ClipboardData(text: errorDetails));
  }
}

/// A full-screen error display widget.
class FullScreenError extends StatelessWidget {
  /// The error message to display.
  final String message;
  
  /// The error object (optional).
  final Object? error;
  
  /// The stack trace (optional).
  final StackTrace? stackTrace;
  
  /// Callback when the retry button is pressed.
  final VoidCallback? onRetry;
  
  /// Whether to show a retry button.
  final bool showRetry;
  
  /// Whether to show a button to copy the error details.
  final bool showDetails;

  /// Creates a full-screen error display.
  const FullScreenError({
    Key? key,
    required this.message,
    this.error,
    this.stackTrace,
    this.onRetry,
    this.showRetry = true,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorDisplay(
        message: message,
        error: error,
        stackTrace: stackTrace,
        onRetry: onRetry,
        showRetry: showRetry,
        showCopyButton: showDetails,
      ),
    );
  }
}
