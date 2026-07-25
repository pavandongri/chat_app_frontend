import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/profile_repository.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioClientProvider)),
);

/// Screen-scoped (autoDispose) profile state — the app-wide "current user"
/// still lives in `authControllerProvider`; every successful fetch/update
/// here is pushed back into it so Home's header etc. stay in sync.
class ProfileController extends AutoDisposeAsyncNotifier<User> {
  @override
  Future<User> build() async {
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    await ref.read(authControllerProvider.notifier).setSessionUser(profile);
    return profile;
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    String? avatarUrl,
  }) async {
    final updated = await ref
        .read(profileRepositoryProvider)
        .updateProfile(name: name, gender: gender, avatarUrl: avatarUrl);
    state = AsyncValue.data(updated);
    await ref.read(authControllerProvider.notifier).setSessionUser(updated);
  }

  Future<void> uploadAvatar(File imageFile) async {
    final updated = await ref
        .read(profileRepositoryProvider)
        .uploadAvatar(imageFile);
    state = AsyncValue.data(updated);
    await ref.read(authControllerProvider.notifier).setSessionUser(updated);
  }
}

final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, User>(
      ProfileController.new,
    );
