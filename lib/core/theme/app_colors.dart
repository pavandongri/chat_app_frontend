import 'package:flutter/material.dart';

/// Single source of truth for raw color values. Nothing outside this file
/// (or `app_theme.dart`) should contain a literal `Color(...)`/hex value —
/// everything else consumes `AppColors`/`Theme.of(context)` instead.
class AppColors {
  AppColors._();

  static const Color seedLight = Color(0xFF3F51B5);
  static const Color seedDark = Color(0xFF7986CB);

  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: seedLight,
        brightness: Brightness.light,
      );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: seedDark,
        brightness: Brightness.dark,
      );
}
