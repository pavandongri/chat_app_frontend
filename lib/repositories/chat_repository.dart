import '../models/conversation.dart';
import '../models/message_status.dart';
import 'friends_repository.dart';

/// Mock/local for now — no backend conversations-list endpoint exists, and
/// the only message endpoint (`GET /api/messages/:friendId`) marks messages
/// Seen as a side effect, so it must not be called just to build a preview
/// list. Real message data is wired up in Story 12; this synthesizes a
/// deterministic preview per friend (stable across refreshes since it's
/// seeded by friend id, not by `Random()`) so the UI/layout can be built
/// and reviewed now.
class ChatRepository {
  ChatRepository(this._friendsRepository);

  final FriendsRepository _friendsRepository;

  static const _sampleMessages = [
    'Hey, how are you doing?',
    'Are we still on for later?',
    'That sounds great, thanks!',
    'Can you send me the file when you get a chance?',
    'Haha, no way!',
    'See you soon!',
    'Let me check and get back to you.',
  ];

  Future<List<Conversation>> getConversations() async {
    final friends = await _friendsRepository.getFriends();
    final now = DateTime.now();

    final conversations = <Conversation>[];
    for (final friend in friends) {
      final seed = friend.id.hashCode.abs();
      if (seed % 5 == 0) continue; // some friends have no conversation yet

      final fromMe = seed.isEven;
      conversations.add(
        Conversation(
          friend: friend,
          lastMessage: _sampleMessages[seed % _sampleMessages.length],
          lastMessageAt: now.subtract(Duration(minutes: (seed % 2880) + 1)),
          lastMessageFromMe: fromMe,
          status: MessageStatus.values[seed % MessageStatus.values.length],
          unreadCount: fromMe ? 0 : seed % 4,
        ),
      );
    }

    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return conversations;
  }
}
