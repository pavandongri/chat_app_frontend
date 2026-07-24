import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../repositories/chat_repository.dart';
import 'friends_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(friendsRepositoryProvider)),
);

class ChatListController extends AutoDisposeAsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() {
    return ref.read(chatRepositoryProvider).getConversations();
  }
}

final chatListControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChatListController, List<Conversation>>(
  ChatListController.new,
);
