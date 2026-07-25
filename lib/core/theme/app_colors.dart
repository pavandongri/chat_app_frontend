import 'package:flutter/material.dart';

/// Single source of truth for raw color values. Nothing outside this file
/// (or `app_theme.dart`) should contain a literal `Color(...)`/hex value —
/// everything else consumes `AppColors`/`Theme.of(context)` instead.
class AppColors {
  AppColors._();

  /// WhatsApp's own two signature colors. `seedLight`/`seedDark` drive the
  /// Material 3 tonal palettes via `ColorScheme.fromSeed`; `tealDeep`/
  /// `accentGreen` are the same two colors kept as fixed brand anchors
  /// (not theme-derived tones) for `AppGradients` — using the identical
  /// hex values for both keeps `colorScheme.primary` (links, active nav
  /// icons) and the fixed-gradient button visually consistent.
  static const Color seedLight = Color(0xFF075E54); // WhatsApp deep teal
  static const Color seedDark = Color(0xFF25D366); // WhatsApp light green
  static const Color tealDeep = Color(0xFF075E54); // WhatsApp deep teal
  static const Color accentGreen = Color(0xFF25D366); // WhatsApp light green

  /// Presence dot colors (Story 9/15) — semantic, not part of the Material
  /// color scheme, so kept here rather than derived from `ColorScheme`.
  static const Color onlineIndicator = accentGreen;
  static const Color offlineIndicator = Color(0xFF9E9E9E);

  /// Text/icon color for content painted directly on top of
  /// `AppGradients.primary` (e.g. the gradient `AppButton` variant) — fixed
  /// regardless of theme brightness because the gradient itself doesn't
  /// change with the theme.
  static const Color onGradient = Colors.white;

  /// Chat screen wallpaper (Story: chat background) — a warm parchment
  /// base in light mode and a deep teal-black in dark mode, each paired
  /// with a low-alpha doodle tint so the tiled pattern stays subtle over
  /// message bubbles rather than competing with them.
  static const Color chatWallpaperLight = Color(0xFFE7DFD8);
  static const Color chatWallpaperDark = Color(0xFF0B141A);
  static const Color chatDoodleLight = Color(0x14000000);
  static const Color chatDoodleDark = Color(0x1AFFFFFF);

  static ColorScheme get lightScheme =>
      ColorScheme.fromSeed(seedColor: seedLight, brightness: Brightness.light);

  static ColorScheme get darkScheme =>
      ColorScheme.fromSeed(seedColor: seedDark, brightness: Brightness.dark);
}
