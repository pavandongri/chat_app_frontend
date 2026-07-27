class ApiConstants {
  ApiConstants._();

  /// The chat_backend dev server (see its `.env` — `PORT=3000`, routes
  /// mounted under `/api`). Point this at your device/emulator-reachable
  /// host when testing on a real device (e.g. `10.0.2.2` for the Android
  /// emulator instead of `localhost`).

  // static const String baseUrl = 'https://dislocate-dried-spiffy.ngrok-free.dev/api';
  static const String baseUrl = 'https://chat-app-backend-i1kt.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// The WebSocket endpoint (Story 33) — same host as [baseUrl] (so it
  /// works through the same ngrok tunnel), minus the `/api` prefix, at
  /// `/ws`, with `http(s)` swapped for `ws(s)`.
  static String get wsUrl {
    final apiUri = Uri.parse(baseUrl);
    final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    return apiUri.replace(scheme: wsScheme, path: '/ws').toString();
  }
}

class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String themeMode = 'theme_mode';
  static const String cachedUser = 'cached_user';
}
