# Story 16 – Refresh Mechanism

## Objective

Manual synchronization.

## AI Prompt

```text
Implement Refresh button.

Fetch latest

Messages

Friend List

Friend Requests

Online Status

Show loading indicator.

Disable button while refreshing.
```

## Acceptance Criteria

- A shared refresh action (button and/or pull-to-refresh, consistent per
  screen) re-fetches whichever of messages, friends list, friend
  requests, and online status applies to the current screen, through the
  existing repositories/providers from Stories 9, 12, and 15 — no new
  transport
- The refresh control shows a loading indicator and is disabled/ignores
  repeat taps while a refresh is already in flight
- Refresh failures surface via the shared error/snackbar widgets and
  leave previously loaded data visible (no blank-screen flash on error)
- This story wires refresh consistently across Chat List, Chat Screen,
  Friends List, and Friend Requests — it does not introduce any
  background timer, socket, or polling (manual refresh only, per
  `project-context.md`)
