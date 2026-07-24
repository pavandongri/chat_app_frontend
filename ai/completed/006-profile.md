# Story 6 – Profile

## Objective

Profile management.

## AI Prompt

```text
Create

View Profile

Edit Profile

Allow editing

Name

Gender

Avatar

If avatar missing

Show default avatar.

Use reusable form widgets.

Responsive layout.
```

## Acceptance Criteria

- View Profile screen displays the logged-in user's name, gender, avatar,
  and username (read-only)
- Edit Profile screen allows changing name, gender, and avatar, using only
  reusable form widgets (TextFields, Buttons, Dialogs) from `core/widgets`
- Avatar upload/selection falls back to a default avatar asset whenever no
  avatar is set — never a broken image or blank space
- Edit submission goes through a `ProfileRepository`/`ProfileProvider`
  pair (per `coding-standards.md` layering) and surfaces loading/error
  states via the shared widgets
- Successful edits update the profile shown across the app (e.g. Home
  Screen header) without requiring a manual app restart
- Responsive across phone/tablet/portrait/landscape
