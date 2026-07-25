# Story 25 – Friend Requests Tab Redesign

## Objective

Redesign the Friend Requests tab with premium cards and a beautiful empty
state.

## AI Prompt

```text
Redesign the Friend Requests tab content using the Story 22 premium card
and empty-state widgets.

Each incoming request card shows:

- Profile picture
- Name
- Accept button
- Reject button

Requirements

- Accept/Reject call the existing friend request repository/provider logic
  unchanged (Story 8) — this is a visual redesign only
- Show a loading indicator on the specific card being actioned, not a
  full-screen blocker
- If there are no incoming requests, show the Story 22 upgraded empty
  state with a friendly message and subtle entrance animation
- No hardcoded colors/spacing — theme tokens only
```

## Acceptance Criteria

- Incoming friend requests render as premium cards with avatar, name,
  Accept, and Reject actions
- Accept/Reject behavior (API calls, state updates) is unchanged from
  Story 8 — only the visual presentation changes
- Empty state (zero incoming requests) uses the Story 22 shared empty-state
  widget
- Per-card loading state while accept/reject is in flight, not a full-screen
  spinner
- Correct in both light and dark theme
