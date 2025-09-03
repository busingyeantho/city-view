import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    useMaterial3: true,
  );
  final _settings = FirebaseFirestore.instance.collection('settings').doc('theme');

  ThemeData get currentTheme => _currentTheme;

  Future<void> loadTheme() async {
    final snap = await _settings.get();
    final data = snap.data();
    if (data != null) {
      final primary = _parseColor(data['primary']);
      final secondary = _parseColor(data['secondary']);
      final background = _parseColor(data['background']);
      final surface = _parseColor(data['surface']);
      _applyColors(primary: primary ?? Colors.green, secondary: secondary, background: background, surface: surface, notify: false);
    }
    notifyListeners();
    _settings.snapshots().listen((doc) {
      final d = doc.data();
      if (d == null) return;
      final primary = _parseColor(d['primary']);
      final secondary = _parseColor(d['secondary']);
      final background = _parseColor(d['background']);
      final surface = _parseColor(d['surface']);
      _applyColors(primary: primary ?? Colors.green, secondary: secondary, background: background, surface: surface);
    });
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

  void _applyColors({required Color primary, Color? secondary, Color? background, Color? surface, bool notify = true}) {
    final base = ColorScheme.fromSeed(seedColor: primary);
    _currentTheme = ThemeData(
      colorScheme: base.copyWith(
        secondary: secondary ?? base.secondary,
        background: background ?? base.background,
        surface: surface ?? base.surface,
      ),
      useMaterial3: true,
    );
    if (notify) notifyListeners();
  }

  Color? _parseColor(dynamic v) {
    if (v is int) return Color(v);
    return null;
  }
}


