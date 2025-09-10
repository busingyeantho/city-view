import 'package:flutter/material.dart';

/// City View School's official color palette
class SchoolColors {
  // Primary color - Rich Burgundy/Maroon
  static Color primary = const Color(0xFF9A3F3F);
  
  // Secondary colors in order
  static Color secondary1 = const Color(0xFFC1856D); // Warm Brown
  static Color secondary2 = const Color(0xFFE6CFA9); // Cream/Beige
  static Color secondary3 = const Color(0xFFFBF9D1); // Light Cream/Off-White
  
  // Additional color variations for better contrast and accessibility
  static Color primaryDark = const Color(0xFF7A3232);
  static Color primaryLight = const Color(0xFFB85A5A);
  
  static Color secondary1Dark = const Color(0xFFA66B4F);
  static Color secondary1Light = const Color(0xFFD49F7F);
  
  static Color secondary2Dark = const Color(0xFFD4B88F);
  static Color secondary2Light = const Color(0xFFF2E3C3);
  
  // Neutral colors that complement the palette
  static const Color darkText = Color(0xFF2C2C2C);
  static const Color lightText = Color(0xFFF5F5F5);
  static Color surface = const Color(0xFFFFFEFE);
  static Color background = const Color(0xFFFAFAFA);
  
  // Status colors that work with the palette
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  /// Update the theme colors
  static void updateColors({
    required Color primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    primary = primaryColor;
    primaryDark = _darken(primaryColor, 0.2);
    primaryLight = _lighten(primaryColor, 0.1);
    
    if (secondaryColor != null) {
      secondary1 = secondaryColor;
      secondary1Dark = _darken(secondaryColor, 0.15);
      secondary1Light = _lighten(secondaryColor, 0.1);
    }
    
    if (backgroundColor != null) {
      background = backgroundColor;
    }
    
    if (surfaceColor != null) {
      surface = surfaceColor;
    }
  }
  
  static Color _darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color _lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Get a gradient using school colors
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static LinearGradient get warmGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary1, secondary2],
  );
  
  static LinearGradient get lightGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary2, secondary3],
  );
  
  static LinearGradient get fullGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary1, secondary2, secondary3],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Get color scheme for Material 3
  static ColorScheme get colorScheme => ColorScheme.light(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: secondary1,
        secondaryContainer: secondary1Dark,
        surface: surface,
        background: background,
        error: error,
        onPrimary: lightText,
        onSecondary: darkText,
        onSurface: darkText,
        onBackground: darkText,
        onError: lightText,
        brightness: Brightness.light,
      );
}
