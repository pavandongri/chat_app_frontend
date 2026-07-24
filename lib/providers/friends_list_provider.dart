import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend.dart';
import 'friends_provider.dart';

class FriendsListController extends AutoDisposeAsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() {
    return ref.read(friendsRepositoryProvider).getFriends();
  }
}

final friendsListControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendsListController, List<Friend>>(
  FriendsListController.new,
);
