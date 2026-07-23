# Story 19 – App Polish

## Objective

Premium experience.

## AI Prompt

```text
Improve UI.

Consistent spacing

Modern cards

Rounded corners

Smooth animations

Page transitions

Material 3

Consistent icons

Premium look and feel.

No unnecessary animations.
```

## Acceptance Criteria

- A visual pass across all screens normalizes spacing, card styling, and
  corner radius to the values defined in `core/theme` — no per-screen
  one-off values
- Page transitions (via go_router) are consistent and subtle across the
  whole app, not just some routes
- Icon usage is consistent (single icon set/style) across all screens
- Animations are limited to purposeful transitions (navigation, button
  press feedback, refresh indicators) — no decorative/looping animations
  added
- No functional behavior changes — this story is visual polish only
