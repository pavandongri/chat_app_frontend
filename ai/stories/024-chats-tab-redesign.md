# Story 24 – Chats Tab Redesign

## Objective

Redesign the Chats tab (chat list) to WhatsApp-style premium list items,
sorted by recency, with unread badges.

## AI Prompt

```text
Redesign the Chats tab content using the Story 22 premium list tile and
unread-count badge widgets.

Each row shows:

- Profile picture (existing UserAvatar / presence indicator)
- Name
- Last message preview (truncated, single line)
- Timestamp of last message (relative, e.g. "2m", "Yesterday")
- Unread message count badge, shown only when > 0

List is sorted with the friend having the most recent message/activity at
the top.

Requirements

- Tapping a row navigates to the existing Chat Screen (Story 11) for that
  friend — no behavior change to the chat screen itself
- Empty state (no conversations yet) uses the Story 22 upgraded
  EmptyStateWidget with a friendly message
- Loading state uses the Story 22 skeleton loader, not a bare spinner
- Manual refresh only (pull-to-refresh) — no polling/socket, per
  project-context.md
- No hardcoded colors/spacing — theme tokens only
```

## Acceptance Criteria

- Chats tab list matches the spec above: avatar, name, last message,
  timestamp, unread badge
- List order reflects most-recent-activity-first
- Unread badge only appears when unread count > 0 and shows the correct
  count
- Empty and loading states use the Story 22 shared widgets, not one-off
  implementations
- Pull-to-refresh works and no automatic polling/timer is introduced
- Tapping a row opens the correct friend's Chat Screen unchanged
- Correct in both light and dark theme
