# Story 27 – Profile Tab Redesign

## Objective

Redesign the Profile tab with a premium look, and host the Logout action
here (moved out of the old home hub, per Story 23).

## AI Prompt

```text
Redesign the Profile tab content as a premium profile page.

Display

- Profile picture (large, hero-style)
- Name
- Username
- Bio (field/UI ready even if backend support is minimal/future-facing —
  do not block on new backend work)
- Email
- Edit Profile button (navigates to existing Edit Profile screen, Story 6)
- Settings button (theme toggle, entry point for future settings)
- Logout button

Requirements

- Use Story 22 glass card styling for the profile header section
- Logout clears the stored JWT via flutter_secure_storage, resets
  session-scoped providers, and routes back to Login — same behavior as
  the old Story 5 logout, just relocated here
- Edit Profile and Settings navigate through routes/ (go_router), no inline
  MaterialPageRoute
- No hardcoded colors/spacing — theme tokens only
```

## Acceptance Criteria

- Profile tab shows avatar, name, username, bio (if present), email, Edit
  Profile, Settings, and Logout
- Logout behavior (session clear, provider reset, route to Login) is
  unchanged from the prior Home Screen implementation, just relocated to
  this tab
- Edit Profile button opens the existing Edit Profile screen unchanged
  (Story 6 behavior preserved)
- Settings exposes at least the existing theme toggle (Story 21/2)
- Correct in both light and dark theme
