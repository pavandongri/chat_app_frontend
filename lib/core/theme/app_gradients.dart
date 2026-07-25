import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized gradient tokens. Use these instead of constructing a
/// `LinearGradient` with literal colors inline in feature code.
class AppGradients {
  AppGradients._();

  /// Primary brand gradient — headers, hero sections, gradient CTAs.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tealDeep, AppColors.accentGreen],
  );

  /// Full-screen background wash for auth/hero screens. Both ends carry a
  /// visible tint (rather than fading to a flat `colorScheme.surface`) so
  /// the gradient reads as a gradient all the way to the bottom edge of
  /// the screen, not just near the top. Brightness-aware so it stays
  /// gentle in both light and dark theme.
  static LinearGradient background(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colorScheme.primary.withValues(alpha: isDark ? 0.30 : 0.18),
        colorScheme.secondary.withValues(alpha: isDark ? 0.22 : 0.12),
      ],
    );
  }
}
