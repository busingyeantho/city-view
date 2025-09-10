import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'school_colors.dart';

class ThemeController extends ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;
  final _settings = FirebaseFirestore.instance.collection('settings').doc('theme');

  ThemeData get currentTheme => _currentTheme;

  Future<void> loadTheme() async {
    try {
      final snap = await _settings.get();
      final data = snap.data();
      if (data != null) {
        final primary = _parseColor(data['primary']);
        final secondary = _parseColor(data['secondary']);
        final background = _parseColor(data['background']);
        final surface = _parseColor(data['surface']);
        _applyColors(
          primary: primary ?? SchoolColors.primary,
          secondary: secondary,
          background: background,
          surface: surface,
          notify: false,
        );
      }
      notifyListeners();

      _settings.snapshots().listen((doc) {
        final d = doc.data();
        if (d == null) return;
        final primary = _parseColor(d['primary']);
        final secondary = _parseColor(d['secondary']);
        final background = _parseColor(d['background']);
        final surface = _parseColor(d['surface']);
        _applyColors(
          primary: primary ?? SchoolColors.primary,
          secondary: secondary,
          background: background,
          surface: surface,
        );
      });
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _currentTheme = AppTheme.lightTheme;
      notifyListeners();
    }
  }

  void updateColors({
    required Color primary,
    Color? secondary,
    Color? background,
    Color? surface,
  }) {
    _applyColors(primary: primary, secondary: secondary, background: background, surface: surface);
    _settings.set({
      'primary': primary.value,
      'secondary': secondary?.value,
      'background': background?.value,
      'surface': surface?.value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _applyColors({
    required Color primary,
    Color? secondary,
    Color? background,
    Color? surface,
    bool notify = true,
  }) {
    // Update the color scheme in SchoolColors
    SchoolColors.updateColors(
      primaryColor: primary,
      secondaryColor: secondary,
      backgroundColor: background,
      surfaceColor: surface,
    );

    // Create a new theme with updated colors
    _currentTheme = ThemeData(
      useMaterial3: true,
      colorScheme: SchoolColors.colorScheme,
      textTheme: GoogleFonts.nunitoSansTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: SchoolColors.lightText,
        ),
        backgroundColor: SchoolColors.primary,
        foregroundColor: SchoolColors.lightText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SchoolColors.primary,
          foregroundColor: SchoolColors.lightText,
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SchoolColors.primary,
          side: BorderSide(color: SchoolColors.primary),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
    
    if (notify) notifyListeners();
  }

  Color? _parseColor(dynamic v) {
    if (v is int) return Color(v);
    return null;
  }
}


