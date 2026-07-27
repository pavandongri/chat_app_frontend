# Story 33 – Real-Time Transport (WebSockets)

## Objective

Connect to the backend's new WebSocket layer
(`../backend/ai/completed/018-realtime-websockets.md`) so messages, seen
receipts, presence, and typing show up live instead of only on manual
refresh.

This is a **Phase 4** addition. `coding-standards.md`'s "Manual refresh
only: never add a `Timer.periodic`, socket, or long-polling loop" rule and
`project-context.md`'s online-status/no-real-time domain rules were written
for Phase 1–3 and are superseded by this story (see the accompanying
project-context.md update) — every screen keeps its existing pull-to-
refresh/refresh-button affordance as a fallback, this is additive.

## AI Prompt

```text
Add `web_socket_channel` to pubspec.yaml.

New `lib/core/network/socket_client.dart`: a `SocketClient` wrapping
`WebSocketChannel`, mirroring how `DioClient` owns the single shared `Dio`
instance. Connects to `ws(s)://<host>/ws?token=<jwt>` (derive the ws(s) URL
from `ApiConstants.baseUrl`, reading the token from
`SecureStorageService` — same source `DioClient`'s interceptor already
uses). Exposes:

- `Stream<Map<String, dynamic>> events` — a broadcast stream of decoded
  incoming JSON frames.
- `connect()` / `disconnect()` — disconnect sets a flag so a manual
  disconnect (logout) doesn't trigger auto-reconnect.
- `sendTyping({required String to, required bool isTyping})`.
- Auto-reconnect with capped backoff (e.g. 3s/6s/12s, cap ~15s) whenever
  the socket drops and it wasn't a manual disconnect.

New `lib/providers/realtime_provider.dart`:

- `socketClientProvider` (`Provider<SocketClient>`).
- A `RealtimeController` that subscribes to `socketClientProvider`'s
  `events` once (constructed eagerly, kept alive — not autoDispose) and
  fans each event out by `type`:
  - `message:new` → append to the matching open `ChatController` (only if
    one is already instantiated for that friend — never force-create one)
    and update `ChatListController`'s preview/unread count (fall back to
    `ChatListController.refresh()` if the conversation isn't in its
    current list yet, e.g. a friend's first-ever message).
  - `message:edited` / `message:deleted` → same idea, patch the open
    `ChatController`'s message list in place if present.
  - `message:seen` → mark every message *I* sent to `data.seenBy` as
    `MessageStatus.seen` in the open `ChatController` for that friend, if
    present.
  - `presence:update` → update a small `presenceOverridesProvider` map
    (`Map<String, ({bool isOnline, DateTime? lastSeen})>`) keyed by
    friend id — screens read this as an override on top of whatever
    `Friend`/fetched snapshot they already have, never replacing the
    fetch-based value as the source of truth (still needed for a friend
    the app hasn't seen a live event for yet).
  - `typing` → update `typingStatusProvider` (a
    `StateProvider.family<bool, String>` keyed by the sender's id), with a
    ~5s auto-clear timer as a safety net in case a `typing:stop` is lost.

Wire the connection lifecycle to auth state in `main.dart`'s `ChatApp`
widget via `ref.listen(authControllerProvider, ...)`: connect when a
session appears, disconnect when it's cleared (logout). Don't gate this on
any specific screen being open — one connection for the whole app
session.

In `ChatScreen`: send `typing:start`/`typing:stop` off the message
`TextEditingController` (debounce — stop after ~2s of no keystrokes, or
immediately on send), and show "typing…" in the app bar subtitle (replacing
`PresenceStatusText`) when `typingStatusProvider(friend.id)` is true. Read
`presenceOverridesProvider` for the header's `PresenceDot`/
`PresenceStatusText` instead of only `widget.friend`'s static snapshot.

In `FriendsListScreen`'s list tiles, same override lookup for each friend's
presence dot/text.

Do not add a message-send or typing REST call — sending stays through the
existing REST `ChatController.send`; typing goes out over the socket only.
```

## Acceptance Criteria

- Two devices/sessions in the same conversation: a message sent by one
  appears in the other's open chat screen without a manual refresh or
  pull-to-refresh
- Editing/deleting a message updates the other participant's open chat
  screen live, the same way
- After the recipient opens/refreshes the conversation (marking it seen
  server-side), the sender's open chat screen updates that message's tick
  from sent to seen without a manual refresh
- A friend's presence dot (Friends List and Chat Screen header) flips
  live between online/offline as their socket connects/disconnects —
  without needing pull-to-refresh — for any friend the app has received a
  `presence:update` for; friends with no live event yet keep showing their
  last-fetched status (unchanged Story 15 behavior)
- Typing in the chat screen shows "typing…" in the other participant's
  open chat screen within ~1s, and it clears within ~2–5s of the sender
  stopping (either via `typing:stop` or the 5s safety-net clear)
- No screen's existing pull-to-refresh / refresh-button / re-fetch-on-
  focus behavior is removed — the socket is additive; killing the socket
  connection (e.g. flight mode) leaves every screen exactly as usable as
  it is today via manual refresh
- The socket reconnects automatically (capped backoff) after a dropped
  connection, without user action, and without duplicating messages
  already in a `ChatController`'s state
- Logging out closes the socket; logging back in opens a fresh one — no
  lingering connection tied to a previous session's JWT
- `flutter analyze` passes with no new warnings
