# Story 9 – Friends List

## Objective

Display current friends.

## AI Prompt

```text
Create Friends Screen.

Display

Avatar

Name

Online Status

Chat Button

Pull-to-refresh

Search within friends.

Responsive.

Premium cards.
```

## Acceptance Criteria

- Lists all accepted friends with avatar (default if missing), name, and
  an online/offline indicator (green/grey dot per Story 15's convention)
- Each friend card has a Chat button that navigates into the Chat Screen
  (Story 11) for that friend — the only place in the app a chat entry
  point appears, since chat is friends-only (per `project-context.md`)
- Pull-to-refresh re-fetches the friends list and online status from the
  backend (manual refresh only — no polling/sockets, per
  `coding-standards.md`)
- A local search/filter narrows the list by name without an extra network
  call
- Loading, empty ("No friends yet"), and error states use shared widgets
- Responsive, premium card styling consistent with Story 8
