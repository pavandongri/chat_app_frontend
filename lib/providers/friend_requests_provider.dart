import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend_request.dart';
import 'friends_provider.dart';

class FriendRequestsState {
  const FriendRequestsState({
    required this.incoming,
    required this.outgoing,
    this.pendingIds = const {},
  });

  final List<FriendRequest> incoming;
  final List<FriendRequest> outgoing;

  /// Request ids with an accept/reject/cancel call currently in flight, so
  /// the card can show a per-item spinner instead of a screen-wide one.
  final Set<String> pendingIds;

  FriendRequestsState copyWith({
    List<FriendRequest>? incoming,
    List<FriendRequest>? outgoing,
    Set<String>? pendingIds,
  }) {
    return FriendRequestsState(
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }
}

class FriendRequestsController extends AutoDisposeAsyncNotifier<FriendRequestsState> {
  @override
  Future<FriendRequestsState> build() async {
    final result = await ref.read(friendsRepositoryProvider).getFriendRequests();
    return FriendRequestsState(incoming: result.incoming, outgoing: result.outgoing);
  }

  Future<void> accept(String requestId) => _act(
        requestId,
        action: () => ref.read(friendsRepositoryProvider).acceptRequest(requestId),
        onSuccess: (current) => current.copyWith(
          incoming: current.incoming.where((r) => r.id != requestId).toList(),
        ),
      );

  Future<void> reject(String requestId) => _act(
        requestId,
        action: () => ref.read(friendsRepositoryProvider).rejectRequest(requestId),
        onSuccess: (current) => current.copyWith(
          incoming: current.incoming.where((r) => r.id != requestId).toList(),
        ),
      );

  Future<void> cancel(String requestId) => _act(
        requestId,
        action: () => ref.read(friendsRepositoryProvider).cancelRequest(requestId),
        onSuccess: (current) => current.copyWith(
          outgoing: current.outgoing.where((r) => r.id != requestId).toList(),
        ),
      );

  Future<void> _act(
    String requestId, {
    required Future<void> Function() action,
    required FriendRequestsState Function(FriendRequestsState current) onSuccess,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(pendingIds: {...current.pendingIds, requestId}));
    try {
      await action();
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(
        onSuccess(latest).copyWith(pendingIds: latest.pendingIds.difference({requestId})),
      );
    } catch (e) {
      final latest = state.valueOrNull ?? current;
      state = AsyncValue.data(latest.copyWith(pendingIds: latest.pendingIds.difference({requestId})));
      rethrow;
    }
  }
}

final friendRequestsControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendRequestsController, FriendRequestsState>(
  FriendRequestsController.new,
);
