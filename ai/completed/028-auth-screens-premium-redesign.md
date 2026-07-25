# Story 28 – Authentication Screens Premium Redesign

## Objective

Apply the Phase 2 premium visual language (glassmorphism, soft shadows,
gradients, smooth animations) to the existing authentication screens.

## AI Prompt

```text
Redesign the existing authentication screens visually, without changing
their behavior:

- Splash Screen
- Login Screen
- Signup Screen
- Verify OTP Screen
- Forgot Password Screen
- Reset Password Screen

Apply, using Story 21/22 tokens and widgets:

- Glassmorphism card/panel containing the form
- Soft shadows, smooth rounded corners
- Subtle gradient background or accent
- Clean, modern typography and spacing
- Smooth entrance animations (subtle, not decorative/looping)
- Smooth transition between auth screens

Requirements

- Existing validation, loading button states, error messages, and password
  visibility toggle (Story 3) are preserved exactly — visual redesign only
- Existing API integration (Story 4) is untouched
- Reuse core/widgets (AppButton, AppTextField, GlassCard) — no new one-off
  form widgets
- Correct in both light and dark theme
```

## Acceptance Criteria

- All six auth screens visually match the premium design language (glass,
  shadow, gradient, spacing, animation) established in Stories 21–22
- Form validation, loading states, error messages, and password visibility
  toggle behave exactly as before (Story 3/4 behavior unchanged)
- No new backend calls or changes to auth API integration
- Only reusable `core/widgets` components are used
- Correct in both light and dark theme
