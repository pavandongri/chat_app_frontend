import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/public_user.dart';
import 'friends_provider.dart';

enum FriendRequestButtonState { none, sending, sent }

class SearchResult {
  const SearchResult({
    required this.user,
    this.buttonState = FriendRequestButtonState.none,
  });

  final PublicUser user;
  final FriendRequestButtonState buttonState;

  SearchResult copyWith({FriendRequestButtonState? buttonState}) =>
      SearchResult(user: user, buttonState: buttonState ?? this.buttonState);
}

/// Screen-scoped search state. Row-level "Requested" status is tracked
/// locally after a successful send so the button updates immediately
/// without re-querying the search endpoint.
class SearchFriendsController
    extends AutoDisposeAsyncNotifier<List<SearchResult>> {
  String _lastQuery = '';

  @override
  Future<List<SearchResult>> build() async => [];

  Future<void> search(String query) async {
    _lastQuery = query.trim();
    if (_lastQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final users = await ref
          .read(friendsRepositoryProvider)
          .searchUsers(_lastQuery);
      return users.map((user) => SearchResult(user: user)).toList();
    });
  }

  Future<void> retry() => search(_lastQuery);

  Future<void> sendRequest(String userId) async {
    _updateButtonState(userId, FriendRequestButtonState.sending);
    try {
      await ref.read(friendsRepositoryProvider).sendFriendRequest(userId);
      _updateButtonState(userId, FriendRequestButtonState.sent);
    } catch (e) {
      _updateButtonState(userId, FriendRequestButtonState.none);
      rethrow;
    }
  }

  void _updateButtonState(String userId, FriendRequestButtonState buttonState) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final result in current)
        if (result.user.id == userId)
          result.copyWith(buttonState: buttonState)
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
