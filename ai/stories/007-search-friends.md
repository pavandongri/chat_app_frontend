# Story 7 – Search Friends

## Objective

Search users by name.

## AI Prompt

```text
Create Search Screen.

Search by name.

Display

Avatar

Name

Username

Friend Request Button

Empty State

Loading State

Error State

API integration.

Responsive UI.
```

## Acceptance Criteria

- Search field queries users by name against the real backend endpoint
  via a `FriendsRepository`/provider (no local mock data)
- Each result row shows avatar (default avatar if missing), name, and
  username, plus a "Send Friend Request" action
- Sending a request calls the backend, then disables/updates that row's
  button state (e.g. to "Requested") without needing a manual refresh
- Loading, empty ("No users found"), and error (with retry) states all
  use the shared widgets from `core/widgets`, per `coding-standards.md`
- A user who is already a friend, or already has a pending outgoing
  request, is reflected correctly in the button state rather than
  offering to send a duplicate request
- Responsive UI, no overflow on small screens
