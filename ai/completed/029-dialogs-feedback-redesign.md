# Story 29 – Dialogs & Feedback Components Redesign

## Objective

Apply the premium visual language app-wide to shared dialogs, snackbars,
and feedback/loading widgets, so every screen (not just auth/home tabs)
picks up the redesign consistently.

## AI Prompt

```text
Redesign the app-wide shared feedback components:

- AppDialog (confirmations, e.g. delete message, logout confirmation)
- AppSnackbar (success/error/info variants)
- Loading widgets (skeleton_loader, small_spinner) wherever still used
  outside the tabs already covered in Stories 24–26
- ErrorWidget (error-with-retry state)

Apply, using Story 21/22 tokens:

- Soft shadows, rounded corners, glass or elevated surface styling for
  dialogs
- Consistent iconography and color coding (success/error/info) sourced
  from AppColors
- Smooth, subtle open/close/appear animations — no decorative looping
  animation

Requirements

- These are shared components — update once in core/widgets, and every
  screen using them (chat, edit/delete message, profile, friends) picks up
  the change automatically
- No behavior change to what triggers a dialog/snackbar/error state, or
  what happens on confirm/cancel
```

## Acceptance Criteria

- AppDialog, AppSnackbar, ErrorWidget, and remaining loading widgets follow
  the Phase 2 premium visual language and theme tokens
- Every existing call site (chat screen delete/edit confirmations, error
  states across features) picks up the new styling without per-screen
  changes
- No change to trigger conditions or confirm/cancel behavior anywhere
  these components are used
- Correct in both light and dark theme
