import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only logging for errors that must never surface to users as raw
/// text. Release builds are silent; use `AppSnackBar`/`AppErrorWidget` with a
/// curated message for what the user actually sees.
class AppLogger {
  AppLogger._();

  static void logError(String context, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(
      error.toString(),
      name: context,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
