import 'package:flutter/material.dart';

/// Centralized glassmorphism tokens: blur strength and translucent surface
/// styling for glass panels (Story 22's `GlassCard`, auth screens, etc.).
/// Brightness-aware so glass reads correctly in both themes.
class AppGlass {
  AppGlass._();

  static const double blurSm = 8;
  static const double blurMd = 16;
  static const double blurLg = 24;

  /// Translucent surface fill for a glass panel.
  static Color surfaceColor(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return colorScheme.surface.withValues(alpha: isDark ? 0.55 : 0.65);
  }

  /// Hairline border that gives a glass panel definition against its
  /// background.
  static Color borderColor(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return colorScheme.onSurface.withValues(alpha: isDark ? 0.12 : 0.08);
  }
}
