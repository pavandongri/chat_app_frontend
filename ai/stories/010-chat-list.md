# Story 10 – Chat List

## Objective

Display conversations.

## AI Prompt

```text
Create Chat List.

Display

Avatar

Friend Name

Last Message

Message Status

Unread Count

Timestamp

Search conversations.

Premium UI.
```

## Acceptance Criteria

- Lists existing conversations (one row per friend with at least one
  message), showing avatar, friend name, last message preview, last
  message status (Sent/Delivered/Seen), unread count badge, and relative
  timestamp
- Tapping a row navigates to the Chat Screen (Story 11) for that
  conversation
- A search field filters conversations by friend name, client-side
- Data comes from a `ChatRepository`/provider; list reflects state as of
  the last manual refresh (pull-to-refresh or the global refresh
  mechanism from Story 16) — no live/background updates
- Loading, empty ("No conversations yet — start one from your friends
  list"), and error states use shared widgets
- Responsive, premium UI consistent with Stories 8–9
