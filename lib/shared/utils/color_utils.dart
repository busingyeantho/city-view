import 'package:flutter/material.dart';

Color? parseHexColor(String input) {
  String hex = input.trim().replaceAll('#', '').toUpperCase();
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}

String colorToHex(Color color, {bool leadingHashSign = true, bool alpha = false}) {
  final a = alpha ? color.alpha.toRadixString(16).padLeft(2, '0') : '';
  final r = color.red.toRadixString(16).padLeft(2, '0');
  final g = color.green.toRadixString(16).padLeft(2, '0');
  final b = color.blue.toRadixString(16).padLeft(2, '0');
  return '${leadingHashSign ? '#' : ''}$a$r$g$b'.toUpperCase();
}


