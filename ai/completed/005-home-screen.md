# Story 5 – Home Screen

## Objective

Create the application's landing page.

## AI Prompt

```text
Create Home Screen.

Sections

Profile

Search Friends

Friend Requests

Friends List

Logout

Modern dashboard layout.

Material 3.

Responsive.
```

## Acceptance Criteria

- Home Screen is the post-login landing route, reached automatically once
  a valid session exists (via the router's auth `redirect`, per
  `coding-standards.md`)
- Provides clear navigation entry points to Profile, Search Friends,
  Friend Requests, and Friends List (Stories 6–9), each routed through
  `routes/` — no inline `MaterialPageRoute`
- Logout action clears the stored JWT via `flutter_secure_storage`,
  resets any session-scoped providers, and routes back to Login
- Layout uses only reusable widgets from `core/widgets` (AppBar, cards,
  buttons) — no one-off widgets
- Responsive across phone/tablet/portrait/landscape without overflow
- No backend calls yet beyond what Story 4's session/auth state already
  provides — this story is purely the shell/navigation hub
