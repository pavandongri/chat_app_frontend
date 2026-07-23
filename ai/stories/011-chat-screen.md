# Story 11 – Chat Screen

## Objective

Create messaging interface.

## AI Prompt

```text
Create Chat Screen.

Display

Chat Header

Avatar

Online Status

Messages

Input Box

Send Button

Refresh Button

Different bubbles

Incoming

Outgoing

Material 3

Responsive

Smooth scrolling.
```

## Acceptance Criteria

- Header shows the friend's avatar, name, and online/offline indicator
- Message list renders incoming and outgoing messages in visually
  distinct bubbles (alignment, color per `AppColors`/theme — no hardcoded
  colors)
- Input box + Send button let the user compose a message; Send is
  disabled while empty or while a send is in flight
- An explicit Refresh button re-fetches the conversation (manual refresh
  only, consistent with Story 16 — no socket/polling)
- List auto-scrolls to the latest message on open and after sending
  a new one, with smooth scrolling and no jank on long histories
- Responsive across phone/tablet/portrait/landscape
- This story is UI/state only against local/mock messages — real send/
  fetch wiring is Story 12
