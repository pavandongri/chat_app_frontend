# Coding Standards

These apply to every story in `ai/stories/`. Consistency across stories
matters more than any individual preference — when in doubt, match existing
code in `lib/` over what's written here.

## Layering

- Widgets (screens/components under `features/<feature>/`) never call Dio
  or a repository directly — always go through a Riverpod provider.
- Providers never build widgets and never import Flutter Material widgets —
  they hold state and orchestrate repository calls, exposing
  `AsyncValue`-style state to the UI.
- Repositories (`repositories/`) are the only layer allowed to call Dio.
  If a provider needs a raw HTTP call, that's a signal the call belongs in
  a repository method instead.
- `core/network` owns the single shared `Dio` instance and its
  interceptors; feature repositories consume it, never instantiate their
  own `Dio()`.

## State Management (Riverpod)

- One provider (or a small provider family) per feature concern — do not
  create a single god-provider for the whole app.
- Represent async server state as `AsyncValue<T>` (loading / data / error)
  and let the UI switch on it with the reusable Loading / Empty / Error
  widgets from `core/widgets` — no ad-hoc `bool isLoading` flags scattered
  across widgets.
- Keep providers free of `BuildContext`; pass callbacks/values in instead.
- Dispose/auto-dispose providers tied to a single screen's lifetime
  (`autoDispose`) unless the state must survive navigation (e.g. auth
  session, theme).

## Networking (Dio)

- All requests go through the shared client in `core/network`, configured
  with the backend base URL and JSON content type.
- An interceptor attaches `Authorization: Bearer <token>` from
  `flutter_secure_storage` to every authenticated request; it never reads
  the token ad-hoc inside a repository.
- Parse every response through the shared envelope
  (`{ success, message, data }`) — see
  [../docs/networking.md](../docs/networking.md). Never reach into
  `response.data` in a repository without going through the shared parser.
- Repository methods throw a typed `AppException` (`{ statusCode, message }`)
  on failure; they never let a raw `DioException` escape to a provider.

## Models

- Plain Dart classes with explicit `fromJson`/`toJson`, matching the
  backend's `snake_case` JSON field names (`avatar_url`, `last_seen`,
  `created_at`) mapped explicitly to camelCase Dart fields — no code
  generation library in this stack, so mappings are hand-written and kept
  next to the model.
- Models live in `models/`, one file per resource (`user.dart`,
  `message.dart`, `friend_request.dart`), shared across features.

## Routing (go_router)

- All routes are declared centrally in `routes/` — never construct a
  `MaterialPageRoute` inline inside a feature widget.
- Route names are constants (no magic path strings scattered across
  `context.go(...)` calls).
- Auth-gated routes check session state via a `redirect` on the router,
  not per-widget `if (!loggedIn) ...` checks.

## Theming

- No hardcoded `Color(...)`, raw hex, or literal `TextStyle` font sizes
  inside feature code — always go through `AppColors` / `AppTypography` /
  `Spacing` from `core/theme`. See [../docs/design-system.md](../docs/design-system.md).
- Every screen must render correctly in both light and dark theme.

## Reusable Widgets First

- Before writing a new `ElevatedButton`, `TextField`, `AlertDialog`,
  `SnackBar`, loading spinner, or empty/error placeholder inline in a
  feature screen, check `core/widgets` for the existing reusable version.
  Add to `core/widgets` instead of duplicating.

## Naming

- Files: `snake_case.dart`. Widgets/classes: `PascalCase`. Providers:
  `camelCaseProvider` suffix (`authProvider`, `friendsListProvider`).
- Functions/methods: verbs (`fetchMessages`, `sendMessage`,
  `acceptFriendRequest`), not nouns.
- Feature folders under `features/` are named after the domain
  (`auth`, `profile`, `friends`, `chat`), not the screen
  (`login_screen_folder` is wrong).

## Error / Loading / Empty States

- Every screen that fetches remote data must handle all three states
  (loading, empty, error-with-retry) using the shared widgets from
  `core/widgets` — a screen that only handles the happy path is not done.

## General

- No dead code, no commented-out blocks, no TODOs left in delivered code —
  open a new story instead.
- Prefer `async/await` over `.then()` chains.
- Keep widgets thin — if a `build()` method is doing data-shaping or
  business logic, move it into the provider or a small pure helper
  function instead.
- Don't add abstractions (generic base repository classes, plugin
  systems, config-driven anything) that no current story needs.
- Manual refresh only: never add a `Timer.periodic`, socket, or
  long-polling loop to simulate real-time updates — see Story 16.
