import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../repositories/message_repository.dart';
import 'core_providers.dart';
import 'friends_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(
    ref.watch(friendsRepositoryProvider),
    ref.watch(messageRepositoryProvider),
  ),
);

class ChatListController extends AutoDisposeAsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() {
    return ref.read(chatRepositoryProvider).getConversations();
  }

  /// Failure never touches `state`, so the previously loaded list stays
  /// visible instead of flashing to the error state (per Story 16).
  Future<void> refresh() async {
    final conversations = await ref
        .read(chatRepositoryProvider)
        .getConversations();
    state = AsyncValue.data(conversations);
  }

  /// Applies what `ChatController` already learned by loading this
  /// conversation — its true latest message and that the friend's
  /// messages are now seen — without a network round trip.
  /// `GET /messages/:friendId` (which loading a conversation just called)
  /// marks them seen server-side as a side effect, so this is purely
  /// catching the already-loaded local state up to that fact, not
  /// asserting something new. A no-op if this friend has no existing row
  /// (nothing to patch) or the list hasn't loaded yet.
  void markConversationRead({
    required String friendId,
    required Message lastMessage,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.indexWhere((c) => c.friend.id == friendId);
    if (index == -1) return;

    final updated = List<Conversation>.of(current);
    updated[index] = Conversation(
      friend: updated[index].friend,
      lastMessage: lastMessage,
      unreadCount: 0,
    );
    updated.sort(
      (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
    );
    state = AsyncValue.data(updated);
  }
}

final chatListControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChatListController, List<Conversation>>(
      ChatListController.new,
    );

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(dioClientProvider)),
);

const _pageSize = 50;

class ChatState {
  const ChatState({
    required this.messages,
    required this.oldestLoadedPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isSending = false,
  });

  /// Ascending by `createdAt` (oldest first), matching the backend's order
  /// and how the message list renders top-to-bottom.
  final List<Message> messages;

  /// The backend paginates oldest-first with an offset, so "page 1" is the
  /// OLDEST page, not the most recent — this tracks the lowest page number
  /// loaded so far; loading more history means fetching `page - 1`.
  final int oldestLoadedPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSending;

  ChatState copyWith({
    List<Message>? messages,
    int? oldestLoadedPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      oldestLoadedPage: oldestLoadedPage ?? this.oldestLoadedPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// One controller instance per open conversation (keyed by friend id).
class ChatController extends AutoDisposeFamilyAsyncNotifier<ChatState, String> {
  late String _friendId;

  @override
  Future<ChatState> build(String friendId) async {
    _friendId = friendId;
    return _loadMostRecent();
  }

  Future<ChatState> _loadMostRecent() async {
    final repo = ref.read(messageRepositoryProvider);

    // The backend only offers oldest-first, offset-based pages, so the
    // "most recent page" has to be computed from the total count first —
    // probe cheaply (limit: 1), then fetch the real last page.
    final probe = await repo.getConversation(_friendId, page: 1, limit: 1);
    if (probe.total == 0) {
      return const ChatState(messages: [], oldestLoadedPage: 1, hasMore: false);
    }

    final lastPage = (probe.total / _pageSize).ceil();
    final lastPageResult = await repo.getConversation(
      _friendId,
      page: lastPage,
      limit: _pageSize,
    );

    List<Message> messages;
    int oldestLoadedPage;
    bool hasMore;

    // The last page is a short remainder whenever `total` isn't an exact
    // multiple of `_pageSize` (e.g. 151 total / 50 per page -> page 4 has
    // just 1 message) — pull in the previous page too so opening a
    // conversation shows a full `_pageSize` window, not a near-empty one.
    if (lastPageResult.items.length < _pageSize && lastPage > 1) {
      final previousPage = lastPage - 1;
      final previousPageResult = await repo.getConversation(
        _friendId,
        page: previousPage,
        limit: _pageSize,
      );
      messages = [...previousPageResult.items, ...lastPageResult.items];
      oldestLoadedPage = previousPage;
      hasMore = previousPage > 1;
    } else {
      messages = lastPageResult.items;
      oldestLoadedPage = lastPage;
      hasMore = lastPage > 1;
    }

    // This fetch is exactly what just marked the friend's messages seen
    // server-side — reflect that in the Chat List immediately (right as
    // the conversation opens, not when the user later leaves it), reusing
    // the messages already fetched above instead of another API call.
    if (messages.isNotEmpty) {
      ref
          .read(chatListControllerProvider.notifier)
          .markConversationRead(friendId: _friendId, lastMessage: messages.last);
    }

    return ChatState(
      messages: messages,
      oldestLoadedPage: oldestLoadedPage,
      hasMore: hasMore,
    );
  }

  /// Failure never touches `state`, so previously loaded messages stay
  /// visible instead of flashing to the error state (per Story 16).
  Future<void> refresh() async {
    final refreshed = await _loadMostRecent();
    state = AsyncValue.data(refreshed);
  }

  Future<void> loadOlder() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    final previousPage = current.oldestLoadedPage - 1;
    try {
      final result = await ref
          .read(messageRepositoryProvider)
          .getConversation(_friendId, page: previousPage, limit: _pageSize);
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(
        latest.copyWith(
          messages: [...result.items, ...latest.messages],
          oldestLoadedPage: previousPage,
          hasMore: previousPage > 1,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(latest.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  Future<void> send(String text) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(isSending: true));
    try {
      final sent = await ref
          .read(messageRepositoryProvider)
          .sendMessage(receiverId: _friendId, message: text);
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(
        latest.copyWith(messages: [...latest.messages, sent], isSending: false),
      );
      ref
          .read(chatListControllerProvider.notifier)
          .markConversationRead(friendId: _friendId, lastMessage: sent);
    } catch (e) {
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(latest.copyWith(isSending: false));
      rethrow;
    }
  }

  /// Errors are left to propagate to the caller (the edit bottom sheet)
  /// uncaught — on failure the message list is untouched, so the original
  /// bubble content stays intact per Story 13's acceptance criteria.
  Future<void> editMessage(String messageId, String newMessage) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = await ref
        .read(messageRepositoryProvider)
        .editMessage(messageId, newMessage);
    final latest = state.valueOrNull ?? current;
    state = AsyncValue.data(
      latest.copyWith(
        messages: [
          for (final m in latest.messages)
            if (m.id == messageId) updated else m,
        ],
      ),
    );
  }

  /// Removes the message from state only after the backend confirms
  /// deletion (hard delete, not optimistic) — on failure it stays, and the
  /// error propagates uncaught to the caller.
  Future<void> deleteMessage(String messageId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(messageRepositoryProvider).deleteMessage(messageId);
    final latest = state.valueOrNull ?? current;
    state = AsyncValue.data(
      latest.copyWith(
        messages: latest.messages.where((m) => m.id != messageId).toList(),
      ),
    );
  }
}

final chatControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatController, ChatState, String>(
      ChatController.new,
    );
