import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend.dart';
import 'friends_provider.dart';

class FriendsListController extends AutoDisposeAsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() {
    return ref.read(friendsRepositoryProvider).getFriends();
  }

  /// Unlike `ref.refresh(provider.future)`, a failure here never touches
  /// `state` — it propagates straight to the caller, so the previously
  /// loaded list stays visible instead of flashing to the error state.
  Future<void> refresh() async {
    final friends = await ref.read(friendsRepositoryProvider).getFriends();
    state = AsyncValue.data(friends);
  }
}

final friendsListControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendsListController, List<Friend>>(
      FriendsListController.new,
    );
