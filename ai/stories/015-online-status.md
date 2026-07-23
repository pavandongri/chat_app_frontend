# Story 15 – Online Status

## Objective

Display online/offline state.

## AI Prompt

```text
Display

Online

Offline

Last Seen

Update when refresh occurs.

Green indicator for online.

Grey for offline.
```

## Acceptance Criteria

- Friends List (Story 9) and Chat Screen header (Story 11) both show a
  green indicator when a friend is online, grey when offline, derived
  from `last_seen` returned by the backend (per `project-context.md` —
  never pushed/live)
- When offline, a "Last seen <relative time>" label is shown instead of
  just a static grey dot
- Status only updates on an explicit refresh (pull-to-refresh, the
  Story 16 refresh mechanism, or screen focus re-fetch) — no
  `Timer.periodic`, socket, or polling loop anywhere in the
  implementation
- Status rendering is a shared widget/helper reused by both Friends List
  and Chat Screen, not duplicated per screen
