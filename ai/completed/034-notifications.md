# Story 34 – Notifications (Local + FCM Push)

## Objective

Notify the user of a new message with a sound, and let tapping that
notification open the sender's Chat Screen — whether the app was open, in
the background, or fully killed. Local notifications piggyback on the
existing WebSocket connection (Story 33); FCM push covers the case where
the socket isn't open, backed by the backend's new push layer
(`../backend/ai/completed/019-push-notifications.md`).

This is a **Phase 5** addition. `project-context.md` explicitly listed
"Push notifications" under "What NOT to Build" — this story supersedes
that line (see the accompanying project-context.md update). Every existing
screen, domain rule, and refresh affordance is unchanged; this is strictly
additive, same pattern Story 33 used for WebSockets.

## AI Prompt

```text
Add `firebase_core`, `firebase_messaging`, and `flutter_local_notifications`
to pubspec.yaml.

New `lib/firebase_options.dart`: a `DefaultFirebaseOptions` class exposing
`currentPlatform` (switches on `defaultTargetPlatform`) with placeholder
`FirebaseOptions` for `android`/`ios` — real values come from running
`flutterfire configure` against an actual Firebase project (a manual setup
step outside this story's scope, since it requires the developer's own
Firebase account).

New `lib/core/services/local_notification_service.dart`: wraps
`flutter_local_notifications`. `initialize()` sets up Android/iOS
initialization settings and creates a `messages` Android notification
channel (`Importance.high`, sound on). Exposes `show({required title, body,
payload})` (payload is the sender's friend id) and a settable
`onNotificationTap` callback invoked with the tapped notification's
payload.

New `lib/core/services/push_notification_service.dart`: wraps
`firebase_messaging`. A top-level `firebaseMessagingBackgroundHandler`
function (annotated `@pragma('vm:entry-point')`, required for a killed-app
background isolate) — it's a no-op since FCM's own `notification` payload
already puts the entry in the system tray. The service class exposes
`requestPermission()`, `getToken()`, `onTokenRefresh`, `deleteToken()`,
`onForegroundMessage` (`FirebaseMessaging.onMessage`),
`onMessageOpenedApp`, and `getInitialMessage()`.

New `lib/repositories/device_repository.dart`: `registerToken({token,
platform})` -> `POST /devices/register`, `unregisterToken(token)` -> `DELETE
/devices/register`, following the existing repository pattern (Dio via
`ResponseParser`/`AppException`).

Add `Future<Friend> getFriend(String friendId)` to `FriendsRepository` ->
`GET /friends/:id` — resolves a bare friend id (all a notification payload
carries) into the `Friend` object `ChatScreen`'s route needs.

New `lib/routes/navigator_key.dart`: a `GlobalKey<NavigatorState>
rootNavigatorKey`, passed to `GoRouter`'s `navigatorKey` in `app_router.dart`
— lets a notification tap navigate with no `BuildContext` available (app
was backgrounded/killed).

New `lib/providers/notification_provider.dart`:
`localNotificationServiceProvider`, `pushNotificationServiceProvider`,
`deviceRepositoryProvider`, and a `NotificationController` (kept alive for
the app session, mirroring `RealtimeController`):

- `initialize()` — sets up `LocalNotificationService`, wires
  `onNotificationTap` to a private `_openChat(friendId)`, subscribes to
  `onForegroundMessage`/`onMessageOpenedApp`, and checks `getInitialMessage()`
  once for a cold start caused by tapping a push. Safe to call regardless of
  auth state — it only wires handlers.
- A foreground FCM message shows a local notification via
  `LocalNotificationService.show` (skipped if `chatControllerProvider` for
  that `data.senderId` already `exists` — that conversation is on screen).
- `notifyLocalMessage({friendId, friendName, messageText})` — called by
  `RealtimeController` (see below) for the socket-driven path.
- `_openChat(friendId)` — no-op if logged out; otherwise fetches the
  `Friend` via `FriendsRepository.getFriend`, then
  `GoRouter.of(rootNavigatorKey.currentState!.context).push(RouteNames.chat,
  extra: friend)`.
- `registerForPush()` — requests permission, gets the FCM token, registers
  it via `DeviceRepository`, and re-registers on `onTokenRefresh`.
- `unregisterForPush()` — unregisters the current token via
  `DeviceRepository`.

In `RealtimeController._onMessageNew` (`realtime_provider.dart`): when the
incoming message is addressed to me and its `ChatController` isn't
currently open (mirrors the existing "only append if the chat is open"
check), call `NotificationController.notifyLocalMessage` — look up the
sender's name from `friendsListControllerProvider`'s cached list (fallback
"New message" if not loaded/found).

In `main.dart`: wrap `Firebase.initializeApp(options:
DefaultFirebaseOptions.currentPlatform)` in try/catch (log and continue —
a missing/placeholder Firebase config must never crash startup; local
notifications still work without it) and register
`FirebaseMessaging.onBackgroundMessage` right after. In `ChatApp.build`,
call `ref.read(notificationControllerProvider).initialize()` once, and add
`registerForPush()`/`unregisterForPush()` calls alongside the existing
`RealtimeController.connect()`/`disconnect()` in the auth-state
`ref.listen`.

Android: add `android.permission.POST_NOTIFICATIONS` to
`AndroidManifest.xml` (required on API 33+ for any notification). Enable
`isCoreLibraryDesugaringEnabled` in `android/app/build.gradle.kts`'s
`compileOptions` and add the `coreLibraryDesugaring` dependency —
`flutter_local_notifications` needs it below API 26.

iOS: add `UIBackgroundModes` (`remote-notification`) to `Info.plist`. Adding
the Push Notifications capability/entitlement itself is a manual Xcode step
(Signing & Capabilities > + Capability > Push Notifications) — out of scope
for this story since it edits the Xcode project file.

Do not add a `Timer.periodic`/polling fallback for notifications — the
local path rides the existing Story 33 socket, the push path is FCM only,
per `coding-standards.md`'s manual-refresh/no-ad-hoc-polling rule.
```

## Acceptance Criteria

- Two devices/sessions, App A backgrounded (socket still alive) or with a
  different chat open: App B sends a message -> App A shows a system
  notification with sound within ~1s, without needing the app to be in the
  foreground
- The same message arriving while App A already has that exact
  conversation open on screen does **not** show a notification (it's
  already visible live, per the existing `_onMessageNew` append behavior)
- Tapping that local notification opens the sender's Chat Screen, whether
  the app was foregrounded, backgrounded, or the notification was tapped
  from the notification shade with the app process still alive
- With App A's socket disconnected (e.g. process killed) and at least one
  registered FCM token, App B's message results in a system push
  notification with sound; tapping it launches the app directly into the
  sender's Chat Screen (cold start), and does the same from a background
  tap (app process alive, not connected)
- A push and a local notification for the same message are never both
  shown (backend only pushes when the receiver's socket isn't connected;
  see the backend story's acceptance criteria)
- Logging out stops future local/push notifications from that device
  (socket disconnects per Story 33; FCM token is unregistered) until
  logging back in
- A device/emulator with `firebase_options.dart` left at its placeholder
  values: the app still starts, logs in, and uses local (socket-driven)
  notifications normally — no crash, no broken unrelated screen
- `flutter analyze` passes with no new warnings
