# Story 8 – Friend Requests

## Objective

Handle incoming and outgoing requests.

## AI Prompt

```text
Create Friend Request Screen.

Sections

Incoming Requests

Outgoing Requests

Incoming

Accept

Reject

Outgoing

Cancel Request

Show avatars.

Modern cards.

Responsive.
```

## Acceptance Criteria

- Screen has two clearly separated sections: Incoming Requests and
  Outgoing Requests, matching the backend's `PENDING` request list split
  by direction (per `project-context.md` domain rules)
- Incoming request cards offer Accept and Reject actions; on success the
  card is removed from the list and (for Accept) the user appears in the
  Friends List (Story 9) on next refresh
- Outgoing request cards offer Cancel; on success the card is removed
  from the Outgoing list
- All actions call the real backend through a repository/provider, with
  per-card loading state while the action is in flight
- Cards show avatar (default if missing) and name; empty/error states use
  shared widgets
- Responsive, modern card layout consistent with the rest of the app
