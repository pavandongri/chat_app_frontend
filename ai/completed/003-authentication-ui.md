# Story 3 – Authentication UI

## Objective

Build authentication screens.

## AI Prompt

```text
Create

Splash Screen

Login Screen

Signup Screen

Verify OTP Screen

Forgot Password

Reset Password

Requirements

Responsive

Material 3

Premium UI

Proper validation

Loading buttons

Error messages

Password visibility toggle

Modern spacing

Reusable widgets only.
```

## Acceptance Criteria

- All six screens (Splash, Login, Signup, Verify OTP, Forgot Password,
  Reset Password) are implemented and reachable via go_router
- Form validation rejects empty/invalid fields before submission is
  attempted
- Buttons show a loading state and are disabled while a submission is
  pending
- Password fields have a visibility toggle
- Only reusable widgets from `core/widgets` are used (no inline
  one-off buttons/fields/dialogs)
- No backend calls yet — screens work against local/mock state only
