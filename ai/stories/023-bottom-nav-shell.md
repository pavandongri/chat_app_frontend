# Story 23 – Home Shell: Bottom Navigation Redesign

## Objective

Replace the current Home Screen dashboard/hub layout with a WhatsApp-style
4-tab bottom navigation shell: Chats, Friend Requests, Friend Search, and
Profile.

## AI Prompt

```text
Redesign the Home Screen as a bottom-navigation shell with 4 tabs, in this
order:

1. Chats (default tab on entry)
2. Friend Requests
3. Friend Search
4. Profile

Requirements

- Use a BottomNavigationBar (or NavigationBar, Material 3 equivalent)
  styled from the Story 21 theme tokens
- Each tab shows the existing screen's content (chat list, friend requests,
  search friends, profile) embedded in the shell — switching tabs must not
  cause a full navigation push/pop or lose each tab's scroll position
- Preserve state per tab (e.g. IndexedStack or equivalent) so switching
  tabs doesn't refetch/reset in-progress state unnecessarily
- Route through go_router per coding-standards.md — the shell itself is a
  single route; tab switching is in-shell state, not separate routes
- Smooth, subtle tab-switch transition (per coding-standards.md: no
  decorative animation)
- Logout remains reachable from the Profile tab (Story 27), not from the
  shell itself
```

## Acceptance Criteria

- Home route renders a bottom navigation bar with exactly 4 tabs in the
  order: Chats, Friend Requests, Friend Search, Profile
- Chats is the default/landing tab
- Switching tabs preserves each tab's state (no unwanted refetch or lost
  scroll position)
- The shell is a single go_router route; no inline `MaterialPageRoute`
- Existing chat list, friend requests, search friends, and profile screens
  still function exactly as before — this story only changes how they're
  hosted/navigated, not their internal content (that's Stories 24–27)
- Responsive and correct in both light and dark theme
- No backend/behavior changes
