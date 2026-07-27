import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// The single shared WebSocket connection for live messages, presence, and
/// typing (Story 33). Feature providers consume this via
/// `socketClientProvider` and must never open their own `WebSocketChannel`.
class SocketClient {
  SocketClient(this._secureStorageService);

  final SecureStorageService _secureStorageService;
  final _eventsController = StreamController<Map<String, dynamic>>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _manuallyDisconnected = false;

  static const _maxBackoff = Duration(seconds: 15);

  /// Broadcast stream of decoded JSON frames (`{"type": ..., "data": ...}`).
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  Future<void> connect() async {
    _manuallyDisconnected = false;
    _reconnectTimer?.cancel();

    final token = await _secureStorageService.readAuthToken();
    if (token == null) return;

    try {
      final channel = WebSocketChannel.connect(
        Uri.parse(
          ApiConstants.wsUrl,
        ).replace(queryParameters: {'token': token}),
      );
      await channel.ready;
      _channel = channel;
      _reconnectAttempt = 0;
      _subscription = channel.stream.listen(
        _onData,
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
        cancelOnError: true,
      );
    } catch (e, st) {
      AppLogger.logError('SocketClient', e, st);
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void sendTyping({required String to, required bool isTyping}) {
    _send({'type': isTyping ? 'typing:start' : 'typing:stop', 'to': to});
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  void _onData(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      _eventsController.add(decoded);
    } catch (e, st) {
      AppLogger.logError('SocketClient', e, st);
    }
  }

  void _onDisconnected() {
    _subscription = null;
    _channel = null;
    if (!_manuallyDisconnected) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delaySeconds = (3 << _reconnectAttempt).clamp(
      3,
      _maxBackoff.inSeconds,
    );
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), connect);
  }
}
