# Story 32 – Chat List Real Data & Larger Message Pages

## Objective

Replace the Chat List's mocked previews with real last-message and
unread-count data from the backend (Story 17,
`../backend/ai/completed/017-conversations-unread-count.md`), and increase
the message page size to 50.

## AI Prompt

```text
Wire ChatRepository to the new GET /messages conversations-list endpoint
instead of synthesizing mock previews.

Replace Conversation's separate lastMessage/lastMessageAt/status fields
with a single `lastMessage: Message` field (reuse the existing Message
model) plus `unreadCount`. Derive "sent by me" for display the same way
ChatScreen already derives it for bubbles (compare senderId to the
current user id in the screen/provider layer), not by baking a
"lastMessageFromMe" flag into the model.

Bump ChatController's page size from 20 to 50 to match the new backend
default.
```

## Acceptance Criteria

- `ChatRepository.getConversations()` calls the real backend endpoint
  (via `MessageRepository`); the mock preview generator is deleted
  entirely, including its now-unneeded seeded-random sample data
- Chat List shows the real last message text, real timestamp, real
  status ticks, and a real unread-count badge per friend — sourced from
  the backend, not synthesized client-side
- The unread badge (`UnreadBadge`) is hidden when `unreadCount == 0` and
  shown otherwise — unchanged behavior from Story 10, now backed by real
  data
- Friends with no exchanged messages still don't appear in the Chat List
  (matches the existing empty/no-conversation behavior)
- `ChatController` requests 50 messages per page (was 20); infinite
  scroll (Story 12) continues to work unchanged against the larger page
  size
- Opening a conversation still marks it seen via the existing
  `GET /messages/:friendId` side effect (backend Story 13); the Chat
  List's unread count updates on the next manual refresh
  (pull-to-refresh or re-entering the tab), consistent with the app's
  manual-refresh-only rule — no auto-refresh-on-navigation is added
- All API errors on this screen continue to surface through the shared
  error/snackbar widgets
