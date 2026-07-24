import 'friend.dart';
import 'message_status.dart';

/// One row in the Chat List: a friend paired with their latest message.
/// The backend has no conversations-list endpoint, so `ChatRepository`
/// populates this with deterministic mock previews layered on the real
/// friend list — see `ChatRepository` for why this stays mock permanently.
class Conversation {
  const Conversation({
    required this.friend,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageFromMe,
    required this.status,
    required this.unreadCount,
  });

  final Friend friend;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool lastMessageFromMe;
  final MessageStatus status;
  final int unreadCount;
}
