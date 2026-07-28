import 'package:firebase_messaging/firebase_messaging.dart';

/// Must be a top-level (or static) function — the platform invokes this in
/// its own background isolate when a push arrives while the app is fully
/// backgrounded/killed. FCM's own `notification` payload already puts the
/// system tray entry up before this runs, so there's nothing to do here;
/// the tap itself is handled by `onMessageOpenedApp`/`getInitialMessage`
/// once the app resumes.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Thin wrapper around `firebase_messaging` — the only place any provider
/// touches `FirebaseMessaging.instance` directly.
class PushNotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<void> deleteToken() => _messaging.deleteToken();

  /// A push that arrives while the app is in the foreground never shows a
  /// system notification on its own — the caller shows a local one via
  /// `LocalNotificationService` in response to this.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// The user tapped a push while the app was backgrounded (not killed).
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Non-null exactly once, immediately after a cold start caused by
  /// tapping a push (app was fully killed).
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}
