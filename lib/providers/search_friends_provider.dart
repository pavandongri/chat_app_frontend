import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/public_user.dart';
import 'friends_provider.dart';

enum FriendRequestButtonState { none, sending, sent, cancelling }

class SearchResult {
  const SearchResult({
    required this.user,
    this.buttonState = FriendRequestButtonState.none,
    this.requestId,
  });

  final PublicUser user;
  final FriendRequestButtonState buttonState;

  /// Id of the outgoing pending request tied to this user, if any — needed
  /// to cancel it. Set from `user.friendRequestId` on load, or after a
  /// successful `sendRequest`.
  final String? requestId;
}

/// Screen-scoped search state. Row-level "Requested" status is tracked
/// locally after a successful send so the button updates immediately
/// without re-querying the search endpoint.
class SearchFriendsController
    extends AutoDisposeAsyncNotifier<List<SearchResult>> {
  String _lastQuery = '';

  /// With no query yet typed, load default suggestions (any non-friend
  /// user) instead of leaving the screen blank until the user searches.
  @override
  Future<List<SearchResult>> build() => _fetch('');

  Future<void> search(String query) async {
    _lastQuery = query.trim();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(_lastQuery));
  }

  Future<void> retry() => search(_lastQuery);

  Future<List<SearchResult>> _fetch(String query) async {
    final users = await ref.read(friendsRepositoryProvider).searchUsers(query);
    return users
        .map(
          (user) => SearchResult(
            user: user,
            buttonState: user.friendRequestId != null
                ? FriendRequestButtonState.sent
                : FriendRequestButtonState.none,
            requestId: user.friendRequestId,
          ),
        )
        .toList();
  }

  Future<void> sendRequest(String userId) async {
    _updateResult(userId, buttonState: FriendRequestButtonState.sending);
    try {
      final requestId = await ref
          .read(friendsRepositoryProvider)
          .sendFriendRequest(userId);
      _updateResult(
        userId,
        buttonState: FriendRequestButtonState.sent,
        requestId: requestId,
      );
    } catch (e) {
      _updateResult(userId, buttonState: FriendRequestButtonState.none);
      rethrow;
    }
  }

  Future<void> cancelRequest(String userId) async {
    String? requestId;
    for (final result in state.valueOrNull ?? const <SearchResult>[]) {
      if (result.user.id == userId) {
        requestId = result.requestId;
        break;
      }
    }
    if (requestId == null) return;

    _updateResult(userId, buttonState: FriendRequestButtonState.cancelling);
    try {
      await ref.read(friendsRepositoryProvider).cancelRequest(requestId);
      _updateResult(
        userId,
        buttonState: FriendRequestButtonState.none,
        clearRequestId: true,
      );
    } catch (e) {
      _updateResult(userId, buttonState: FriendRequestButtonState.sent);
      rethrow;
    }
  }

  void _updateResult(
    String userId, {
    required FriendRequestButtonState buttonState,
    String? requestId,
    bool clearRequestId = false,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final result in current)
        if (result.user.id == userId)
          SearchResult(
            user: result.user,
            buttonState: buttonState,
            requestId: clearRequestId ? null : (requestId ?? result.requestId),
          )
        else
          result,
    ]);
  }
}

final searchFriendsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SearchFriendsController,
      List<SearchResult>
    >(SearchFriendsController.new);
