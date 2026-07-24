import 'friend.dart';
import 'message_status.dart';

/// One row in the Chat List: a friend paired with their latest message.
/// Story 10 has no real message backend to read from yet (that's Story 12),
/// so `ChatRepository` populates this with deterministic mock previews on
/// top of the real friend list.
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
