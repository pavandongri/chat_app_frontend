# Story 14 – Delete Message

## Objective

Delete own messages.

## AI Prompt

```text
Long press message.

Delete option.

Confirmation dialog.

Remove message after successful API.

Handle errors.
```

## Acceptance Criteria

- The long-press bottom sheet from Story 13 includes a Delete option on
  the current user's own messages only
- Delete shows a confirmation dialog (reusable `core/widgets` dialog)
  before calling the backend
- The message is removed from the UI only after the backend confirms
  deletion (hard delete, per `project-context.md`) — not optimistically
  before the call resolves
- No "undo delete" or soft-delete/history affordance is built
- Errors during deletion surface via shared error/snackbar widgets and
  leave the message in place
