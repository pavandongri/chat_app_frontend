# Story 22 – Premium Reusable Component Library

## Objective

Build the reusable premium building blocks (glass cards, gradient buttons,
elegant loading/empty states) in `core/widgets` that every later Phase 2
story will consume, so the redesign doesn't duplicate UI code screen by
screen.

## AI Prompt

```text
Extend core/widgets with premium, reusable components built on top of the
Story 21 theme tokens. Do not hardcode any color, shadow, or gradient value
inline — pull from AppColors/AppRadius/theme tokens.

Add or upgrade:

- GlassCard: glassmorphism container (blur + translucent surface + soft
  shadow + rounded corners), replacing ad-hoc Container/Card usage
- Gradient variant for AppButton (subtle brand gradient, still respects
  loading/disabled states already supported)
- Premium list tile base widget (avatar + title + subtitle + trailing +
  tap ripple) that Chats/Friend Requests/Friend Search tabs can build on
- Upgraded EmptyStateWidget with a subtle entrance animation and
  illustration/icon slot
- Upgraded loading widgets (skeleton_loader, small_spinner) with smoother,
  purposeful animation — no decorative looping animations
- Unread-count badge widget (for Chats tab)

Requirements

- Material 3
- Every new/updated widget works correctly in both light and dark theme
- Reuse existing widgets where they already do the job (AppButton,
  AppTextField, AppDialog, AppSnackbar) — extend them, don't fork them
- No business logic in these widgets — presentation only
```

## Acceptance Criteria

- `core/widgets` gains the components above (or upgrades to existing ones),
  all theme-driven with zero hardcoded colors/shadows/gradients
- Existing usages of AppButton/EmptyStateWidget/loading widgets continue to
  work unchanged (backward compatible extension, not a breaking rewrite)
- Every new/updated widget renders correctly in both light and dark theme
- No feature screen is touched in this story — this is a components-only
  story; consumption happens in Stories 23–29
