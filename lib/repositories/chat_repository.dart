import '../models/conversation.dart';
import 'friends_repository.dart';
import 'message_repository.dart';

/// Combines the real friend list with real conversation summaries
/// (`GET /messages`) into Chat List rows.
class ChatRepository {
  ChatRepository(this._friendsRepository, this._messageRepository);

  final FriendsRepository _friendsRepository;
  final MessageRepository _messageRepository;

  Future<List<Conversation>> getConversations() async {
    final friends = await _friendsRepository.getFriends();
    final summaries = await _messageRepository.getConversationSummaries();
    final friendsById = {for (final friend in friends) friend.id: friend};

    final conversations = <Conversation>[];
    for (final summary in summaries) {
      final friend = friendsById[summary.friendId];
      if (friend == null) continue;
      conversations.add(
        Conversation(
          friend: friend,
          lastMessage: summary.lastMessage,
          unreadCount: summary.unreadCount,
        ),
      );
    }

    conversations.sort(
      (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
    );
    return conversations;
  }
}
