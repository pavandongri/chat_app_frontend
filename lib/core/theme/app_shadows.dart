import 'package:flutter/material.dart';

/// Centralized soft-shadow tokens. Use these instead of a literal
/// `BoxShadow`/`elevation` value in feature code, so shadow depth stays
/// consistent across cards, dialogs, and glass surfaces.
class AppShadows {
  AppShadows._();

  /// Material `elevation` values for widgets that take one directly
  /// (Card, Dialog) rather than a raw `BoxShadow` list.
  static const double elevationSm = 1;
  static const double elevationMd = 3;
  static const double elevationLg = 6;

  /// Raw `BoxShadow` presets for custom-decorated containers (e.g. the
  /// glass surfaces from Story 22), brightness-aware since shadows read
  /// very differently on light vs. dark backgrounds.
  static List<BoxShadow> soft(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> softLarge(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
