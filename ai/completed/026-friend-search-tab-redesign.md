# Story 26 – Friend Search Tab Redesign

## Objective

Redesign the Friend Search tab with a top search bar and premium user cards
below it.

## AI Prompt

```text
Redesign the Friend Search tab content using the Story 22 premium list
tile/card widgets.

Layout

- Top: search bar (existing search-friends provider/logic), filters the
  list instantly/responsively as the user types
- Below: list of users who are not already friends

Each user card shows:

- Profile picture
- Name
- Username (if available)
- Mutual friends count (optional, only if the data is already available
  from the existing API — do not add a new backend call for this)
- Send Friend Request button, which reflects pending/sent state after
  tapping (disabled + "Requested" label) instead of allowing duplicate
  requests

Requirements

- Reuses existing search-friends provider/repository logic (Story 7)
  unchanged — visual redesign only
- Empty state (no results / no users to show) uses the Story 22 empty
  state widget
- No hardcoded colors/spacing — theme tokens only
```

## Acceptance Criteria

- Search bar sits above the results list and filters instantly as the user
  types, using existing search logic (no new backend calls)
- Each result card shows avatar, name, username (if available), and a Send
  Friend Request button
- After sending a request, the button reflects a pending/sent state and
  prevents duplicate sends
- Mutual friends count is shown only if already available from existing
  data — no new API integration added in this story
- Empty state uses the Story 22 shared widget
- Correct in both light and dark theme
