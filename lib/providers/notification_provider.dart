import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/local_notification_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/utils/app_logger.dart';
import '../repositories/device_repository.dart';
import '../routes/navigator_key.dart';
import '../routes/route_names.dart';
import 'auth_provider.dart';
import 'chat_provider.dart';
import 'core_providers.dart';
import 'friends_provider.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(dioClientProvider)),
);

/// Owns notification setup/lifecycle: local (socket-driven) notifications,
/// FCM foreground/background/cold-start handling, and turning a tap (either
/// path) into opening that sender's Chat Screen. Constructed once and kept
/// alive for the app's session, mirroring `RealtimeController`.
class NotificationController {
  NotificationController(this._ref);

  final Ref _ref;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;

  /// Sets up local notification display + FCM listeners. Safe to call once
  /// at app start regardless of auth state — this only wires handlers, it
  /// doesn't request permission or register a token (see [registerForPush]
  /// for that, which is gated on being logged in). Kept alive for the whole
  /// app session (not autoDispose), same as `RealtimeController` — these
  /// subscriptions are never meant to be cancelled.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final localService = _ref.read(localNotificationServiceProvider);
    await localService.initialize();
    localService.onNotificationTap = _openChat;

    // Local (socket-driven) notifications work regardless — only the FCM
    // wiring below depends on `Firebase.initializeApp` having succeeded, so
    // a missing/placeholder `firebase_options.dart` must not break the rest
    // of app startup.
    try {
      final push = _ref.read(pushNotificationServiceProvider);
      push.onForegroundMessage.listen(_handleForegroundMessage);
      push.onMessageOpenedApp.listen(_handleOpenedMessage);

      final initialMessage = await push.getInitialMessage();
      if (initialMessage != null) _handleOpenedMessage(initialMessage);
    } catch (e, st) {
      AppLogger.logError('NotificationController', e, st);
    }
  }

  /// A push arrived while the app was open — FCM never surfaces this on its
  /// own, so show a local notification the same way a live socket event
  /// would (skipped if that conversation is already open on screen).
  void _handleForegroundMessage(RemoteMessage message) {
    final senderId = message.data['senderId'] as String?;
    if (senderId == null) return;
    if (_ref.exists(chatControllerProvider(senderId))) return;

    _ref
        .read(localNotificationServiceProvider)
        .show(
          title: message.notification?.title ?? 'New message',
          body: message.notification?.body ?? '',
          payload: senderId,
        );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final senderId = message.data['senderId'] as String?;
    if (senderId != null) _openChat(senderId);
  }

  /// Called by `RealtimeController` when `message:new` arrives over the
  /// already-open socket and the sender's conversation isn't currently on
  /// screen — the in-app/"local" notification path.
  void notifyLocalMessage({
    required String friendId,
    required String friendName,
    required String messageText,
  }) {
    _ref
        .read(localNotificationServiceProvider)
        .show(title: friendName, body: messageText, payload: friendId);
  }

  Future<void> _openChat(String friendId) async {
    if (_ref.read(authControllerProvider).valueOrNull == null) return;

    try {
      final friend = await _ref.read(friendsRepositoryProvider).getFriend(friendId);
      final context = rootNavigatorKey.currentState?.context;
      if (context == null || !context.mounted) return;
      GoRouter.of(context).push(RouteNames.chat, extra: friend);
    } catch (e, st) {
      AppLogger.logError('NotificationController', e, st);
    }
  }

  /// Requests permission and registers this device's FCM token with the
  /// backend — called on login, mirroring `RealtimeController.connect`.
  /// A no-op (not a crash) if Firebase isn't configured.
  Future<void> registerForPush() async {
    try {
      final push = _ref.read(pushNotificationServiceProvider);
      final granted = await push.requestPermission();
      if (!granted) return;

      final token = await push.getToken();
      if (token != null) await _registerToken(token);

      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = push.onTokenRefresh.listen(_registerToken);
    } catch (e, st) {
      AppLogger.logError('NotificationController', e, st);
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _ref
          .read(deviceRepositoryProvider)
          .registerToken(token: token, platform: Platform.isIOS ? 'ios' : 'android');
    } catch (e, st) {
      AppLogger.logError('NotificationController', e, st);
    }
  }

  /// Unregisters this device's token — called on logout, mirroring
  /// `RealtimeController.disconnect`.
  Future<void> unregisterForPush() async {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    try {
      final token = await _ref.read(pushNotificationServiceProvider).getToken();
      if (token != null) {
        await _ref.read(deviceRepositoryProvider).unregisterToken(token);
      }
    } catch (e, st) {
      AppLogger.logError('NotificationController', e, st);
    }
  }
}

final notificationControllerProvider = Provider<NotificationController>(
  (ref) => NotificationController(ref),
);
