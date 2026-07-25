class ApiConstants {
  ApiConstants._();

  /// The chat_backend dev server (see its `.env` — `PORT=3000`, routes
  /// mounted under `/api`). Point this at your device/emulator-reachable
  /// host when testing on a real device (e.g. `10.0.2.2` for the Android
  /// emulator instead of `localhost`).
  static const String baseUrl = 'https://dislocate-dried-spiffy.ngrok-free.dev/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String themeMode = 'theme_mode';
  static const String cachedUser = 'cached_user';
}
