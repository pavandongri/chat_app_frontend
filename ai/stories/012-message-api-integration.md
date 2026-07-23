# Story 12 – Message API Integration

## Objective

Integrate messaging backend.

## AI Prompt

```text
Integrate

Fetch Messages

Send Message

Refresh Messages

Mark Delivered

Mark Seen

Handle loading

Pagination

API errors

Repository pattern.
```

## Acceptance Criteria

- `MessageRepository` implements fetch (paginated), send, and manual
  refresh against the real backend; `ChatProvider` exposes their
  `AsyncValue` state to the Chat Screen from Story 11
- Opening a conversation fetches the most recent page; scrolling toward
  older messages loads the next page (pagination), without re-fetching
  already-loaded messages
- Sending a message calls the backend and appends the confirmed message
  to the list; a failed send surfaces an error without silently dropping
  the message
- Messages are marked Delivered/Seen via explicit repository calls tied to
  the message lifecycle (`SENT → DELIVERED → SEEN`, per
  `project-context.md`), triggered on refresh/screen focus — not a
  background timer
- All API errors surface through shared error widgets/snackbars, never as
  an unhandled exception
- No transport other than manual HTTP calls — no sockets, no polling loop
