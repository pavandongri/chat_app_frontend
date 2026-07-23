# Story 13 – Edit Message

## Objective

Allow editing own messages.

## AI Prompt

```text
Long press message.

Show bottom sheet.

Edit

Save

Cancel

Update message instantly.

No edit history.
```

## Acceptance Criteria

- Long-pressing a message bubble the current user sent opens a bottom
  sheet with Edit/Cancel (no edit option on friends' messages)
- Edit opens the message text in an editable field pre-filled with the
  current content; Save calls the backend to update it in place
- On success, the bubble updates immediately in the UI — no app restart
  or manual refresh required
- No edit history, "edited" indicator persistence, or undo affordance is
  built (per `project-context.md`: edits overwrite in place)
- Errors during save surface via the shared error/snackbar widgets and
  leave the original message content intact
