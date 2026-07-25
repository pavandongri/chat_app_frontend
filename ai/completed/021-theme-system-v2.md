# Story 21 – WhatsApp-Inspired Theme System v2

## Objective

Evolve the existing centralized theme system (Story 2) into a WhatsApp-inspired
teal/green palette, and extend it with the design tokens the Phase 2 premium
UI needs (elevation/shadow, gradient, and glassmorphism tokens) — without
introducing a second source of truth.

## AI Prompt

```text
Redesign the color system in core/theme to be WhatsApp-inspired (teal/green
primary, with a clear secondary/accent color) while keeping it a single
centralized source of truth.

Update, do not duplicate:

- AppColors: primary/secondary/background/surface/text/border/icon palettes
  for both light and dark themes. Changing one value here must propagate
  everywhere in the app.
- AppTypography, Spacing, AppRadius: reviewed for consistency with the new
  palette, adjusted only if the redesign requires it.

Add new tokens (extend the existing files, do not create a parallel theme
system):

- Elevation/shadow tokens (soft shadow presets for cards/buttons/dialogs)
- Gradient tokens (subtle brand gradients for buttons/headers/hero areas)
- Glassmorphism tokens (blur radius, translucent surface color/opacity for
  both light and dark theme)

Requirements

- Material 3
- Light and dark theme both fully supported
- No hardcoded colors anywhere in feature code — everything routes through
  AppColors/AppTypography/Spacing/AppRadius
- Existing ButtonTheme/InputDecorationTheme/CardTheme/DialogTheme/SnackBarTheme
  updated to use the new palette and tokens, not replaced with one-off styles
- Theme selection continues to persist via SharedPreferences (Story 2
  behavior unchanged)
```

## Acceptance Criteria

- `core/theme` remains the single source of truth; no new/parallel theme
  files are introduced
- New teal/green WhatsApp-inspired palette is applied consistently in both
  light and dark theme
- New elevation, gradient, and glassmorphism tokens exist in `core/theme`
  and are documented well enough (naming) that later stories can consume
  them without guessing values
- Changing a primary color value in one place updates every screen that
  already exists (auth, home, profile, friends, chat)
- No visual regression to existing screens beyond the palette/token change
  itself — layout and functionality untouched
- No hardcoded `Color(...)`/hex/literal `TextStyle` introduced anywhere
