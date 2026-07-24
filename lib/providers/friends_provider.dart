import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/friends_repository.dart';
import 'core_providers.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>(
  (ref) => FriendsRepository(ref.watch(dioClientProvider)),
);
