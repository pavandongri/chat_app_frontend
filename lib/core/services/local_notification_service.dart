import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/app_logger.dart';

/// Shows a system notification (with sound) for an incoming message — both
/// the "local" path (live over the already-open WebSocket, Story 33) and as
/// the foreground handler for FCM pushes (Story 19 on the backend) route
/// through this one place. Tapping any of them invokes [onNotificationTap]
/// with the payload string passed to [show] (the sender's friend id).
class LocalNotificationService {
  static const _channelId = 'messages';
  static const _channelName = 'Messages';
  static const _channelDescription = 'New message notifications';

  final _plugin = FlutterLocalNotificationsPlugin();
  int _nextId = 0;

  /// Set by `NotificationController` once it's ready to resolve a payload
  /// (a friend id) into a screen to navigate to.
  void Function(String friendId)? onNotificationTap;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onNotificationTap?.call(payload);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> show({
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      await _plugin.show(
        _nextId++,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(presentSound: true),
        ),
        payload: payload,
      );
    } catch (e, st) {
      AppLogger.logError('LocalNotificationService', e, st);
    }
  }
}
