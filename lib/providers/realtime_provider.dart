import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/socket_client.dart';
import '../models/message.dart';
import 'auth_provider.dart';
import 'chat_provider.dart';
import 'core_providers.dart';

final socketClientProvider = Provider<SocketClient>(
  (ref) => SocketClient(ref.watch(secureStorageServiceProvider)),
);

/// Live presence pushed over the socket (Story 33), keyed by friend id.
/// Screens read this as an override on top of whatever fetched `Friend`
/// snapshot they already have — a friend with no entry here just keeps
/// showing that snapshot (Story 15's fetch-based behavior, unchanged).
typedef PresenceInfo = ({bool isOnline, DateTime? lastSeen});

final presenceOverridesProvider = StateProvider<Map<String, PresenceInfo>>(
  (ref) => const {},
);

/// Whether the given friend is currently typing to the current user.
/// Auto-cleared ~5s after the last `typing:start` as a safety net in case
/// a `typing:stop` is lost.
final typingStatusProvider = StateProvider.family<bool, String>(
  (ref, friendId) => false,
);

/// Owns the WebSocket connection lifecycle and fans incoming events out to
/// the providers/controllers that react to them — the single place any
/// provider reacts to push events (Story 33). Constructed once and kept
/// alive for the app's session (not autoDispose); `main.dart` drives
/// `connect`/`disconnect` off auth state.
class RealtimeController {
  RealtimeController(this._ref) {
    _ref.read(socketClientProvider).events.listen(_handleEvent);
  }

  final Ref _ref;
  final Map<String, Timer> _typingTimers = {};

  void connect() => _ref.read(socketClientProvider).connect();

  void disconnect() {
    _ref.read(socketClientProvider).disconnect();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _ref.read(presenceOverridesProvider.notifier).state = const {};
  }

  String? get _myUserId => _ref.read(authControllerProvider).valueOrNull?.id;

  void _handleEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    final data = event['data'] as Map<String, dynamic>?;
    if (data == null) return;

    switch (type) {
      case 'message:new':
        _onMessageNew(Message.fromJson(data));
      case 'message:edited':
        _onMessageEdited(Message.fromJson(data));
      case 'message:deleted':
        _onMessageDeleted(
          data['id'] as String,
          data['senderId'] as String,
          data['receiverId'] as String,
        );
      case 'message:seen':
        _onMessageSeen(data['seenBy'] as String);
      case 'presence:update':
        _onPresenceUpdate(
          data['userId'] as String,
          data['isOnline'] as bool,
          data['lastSeen'] == null
              ? null
              : DateTime.parse(data['lastSeen'] as String),
        );
      case 'typing':
        _onTyping(data['from'] as String, data['isTyping'] as bool);
    }
  }

  void _onMessageNew(Message message) {
    final myId = _myUserId;
    if (myId == null) return;
    final otherId = message.senderId == myId
        ? message.receiverId
        : message.senderId;

    final chatProvider = chatControllerProvider(otherId);
    if (_ref.exists(chatProvider)) {
      _ref.read(chatProvider.notifier).appendIncoming(message);
    }
    _ref
        .read(chatListControllerProvider.notifier)
        .applyIncomingMessage(message, currentUserId: myId);
  }

  void _onMessageEdited(Message message) {
    final myId = _myUserId;
    if (myId == null) return;
    final otherId = message.senderId == myId
        ? message.receiverId
        : message.senderId;

    final chatProvider = chatControllerProvider(otherId);
    if (_ref.exists(chatProvider)) {
      _ref.read(chatProvider.notifier).applyEdited(message);
    }
  }

  void _onMessageDeleted(String id, String senderId, String receiverId) {
    final myId = _myUserId;
    if (myId == null) return;
    final otherId = senderId == myId ? receiverId : senderId;

    final chatProvider = chatControllerProvider(otherId);
    if (_ref.exists(chatProvider)) {
      _ref.read(chatProvider.notifier).applyDeleted(id);
    }
  }

  void _onMessageSeen(String seenBy) {
    final myId = _myUserId;
    if (myId == null) return;

    final chatProvider = chatControllerProvider(seenBy);
    if (_ref.exists(chatProvider)) {
      _ref.read(chatProvider.notifier).markSeenByFriend(myId);
    }
  }

  void _onPresenceUpdate(String userId, bool isOnline, DateTime? lastSeen) {
    final overrides = Map<String, PresenceInfo>.of(
      _ref.read(presenceOverridesProvider),
    );
    overrides[userId] = (isOnline: isOnline, lastSeen: lastSeen);
    _ref.read(presenceOverridesProvider.notifier).state = overrides;
  }

  void _onTyping(String from, bool isTyping) {
    _ref.read(typingStatusProvider(from).notifier).state = isTyping;

    _typingTimers[from]?.cancel();
    if (isTyping) {
      _typingTimers[from] = Timer(const Duration(seconds: 5), () {
        _ref.read(typingStatusProvider(from).notifier).state = false;
      });
    } else {
      _typingTimers.remove(from);
    }
  }
}

final realtimeControllerProvider = Provider<RealtimeController>(
  (ref) => RealtimeController(ref),
);
