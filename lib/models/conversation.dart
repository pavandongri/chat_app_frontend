import 'friend.dart';
import 'message.dart';

/// One row in the Chat List: a friend paired with their latest message and
/// how many of that friend's messages are still unread.
class Conversation {
  const Conversation({
    required this.friend,
    required this.lastMessage,
    required this.unreadCount,
  });

  final Friend friend;
  final Message lastMessage;
  final int unreadCount;
}

/// The `GET /messages` (list mode) wire format, before `ChatRepository`
/// pairs each entry with its friend's data.
class ConversationSummary {
  const ConversationSummary({
    required this.friendId,
    required this.lastMessage,
    required this.unreadCount,
  });

  final String friendId;
  final Message lastMessage;
  final int unreadCount;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      friendId: json['friendId'] as String,
      lastMessage: Message.fromJson(
        json['lastMessage'] as Map<String, dynamic>,
      ),
      unreadCount: json['unreadCount'] as int,
    );
  }
}
