# Project Context

This file is the entry point for any AI assistant (or engineer) picking up
work on this frontend. Read this first, then the relevant story in
`ai/stories/`.

## What This Is

The Flutter client for a production-grade 1:1 chat application. It talks to
the backend described in `../backend/ai/project-context.md`. Phase 1 (this
roadmap) covers auth, friends, and text messaging with **manual refresh** —
no WebSockets, no real-time push, no background sockets. Phase 1 is
complete (Stories 1–20).

Phase 2 is a **UI/UX redesign** layered on top of the completed Phase 1
functionality — see [ui-ux-redesign.md](ui-ux-redesign.md) for the source
brief and Stories 21–31 in `ai/implementation-plan.md` for the ordered
breakdown. Phase 2 introduces a WhatsApp-inspired premium visual language
(centralized theme system, glassmorphism/soft shadows/gradients, a 4-tab
bottom navigation home shell) but is **visual/UX only** — it must not alter
any domain rule below, any backend contract, or anything under "What NOT to
Build."

## Tech Stack

- Flutter, Material 3
- Riverpod (state management)
- go_router (navigation)
- Dio (networking)
- flutter_secure_storage (JWT persistence)
- SharedPreferences (non-sensitive local prefs, e.g. theme)
- Responsive UI, production-grade architecture

## Architecture

Feature-first + layered. Full detail in
[../docs/architecture.md](../docs/architecture.md). Short version:

```
Screen (Widget) → Provider (Riverpod) → Repository → Dio → Backend REST API
```

## Core Domain Rules

These mirror the backend's domain rules — the UI must not contradict them:

- A user must verify their email (via OTP) before they can log in.
- Two users can chat **only if they are friends** (an accepted friend
  request exists). The UI never offers a chat entry point for non-friends.
- Friend requests move through `PENDING → ACCEPTED | REJECTED | CANCELLED`;
  the UI shows separate Incoming/Outgoing sections (Story 8).
- Messages move through `SENT → DELIVERED → SEEN`; the UI reflects this per
  bubble (Story 12).
- Online status is derived from `last_seen`, not pushed — the UI only ever
  learns about it via an explicit refresh (Story 15/16), never a live
  socket.
- Messages are hard-deleted and edits overwrite in place — the UI must not
  build any "edit history" or "undo delete" affordance.
- There is no real-time transport anywhere in this phase. Every screen that
  shows server data needs an explicit, user-triggered way to refresh it
  (pull-to-refresh, a refresh button, or re-fetch on screen focus).

## How Work Is Organized

- `ai/implementation-plan.md` — the ordered list of stories and their
  dependencies.
- `ai/stories/0XX-*.md` — one file per story, each self-contained enough to
  hand to an AI coding assistant as a single task.
- `ai/completed/` — once a story is fully implemented, reviewed, and
  merged, move its file here (unchanged) so it's clear what's shipped vs.
  what's pending. Do not delete story files.
- `ai/coding-standards.md` — conventions every story's implementation must
  follow, so output stays consistent across many separate AI/dev sessions.

## What NOT to Build (Phase 1)

- WebSockets, SSE, or any real-time/push transport
- Group chats
- Media/file messages (text only)
- Push notifications
- Message edit history or delete/undo history
- Offline-first sync / local database caching beyond simple in-memory state
- Any platform target beyond Android + iOS (no web/desktop build targets)

## Reference Docs

- [UI/UX Redesign Brief (Phase 2)](ui-ux-redesign.md)
- [Architecture](../docs/architecture.md)
- [Networking](../docs/networking.md)
- [Design System](../docs/design-system.md)
- Backend contract: [../backend/docs/api-guidelines.md](../backend/docs/api-guidelines.md),
  [../backend/docs/database.md](../backend/docs/database.md)
