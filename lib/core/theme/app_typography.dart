import 'package:flutter/material.dart';

/// Centralized text styles, derived from the Material 3 type scale but
/// bound to the current [ColorScheme] so text always follows the active
/// light/dark theme.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021(platform: TargetPlatform.android).black
        .apply(
          displayColor: colorScheme.onSurface,
          bodyColor: colorScheme.onSurface,
        );

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: colorScheme.onSurface),
      bodyMedium: base.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
