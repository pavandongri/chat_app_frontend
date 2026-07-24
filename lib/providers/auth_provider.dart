import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'core_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioClientProvider)),
);

/// State is the current session (`null` = logged out) plus every auth
/// action. Screens call the action methods directly and handle their own
/// loading/error UI around the call — this controller only owns the
/// session itself.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final token = await ref.read(secureStorageServiceProvider).readAuthToken();
    if (token == null) return null;

    final cachedJson = ref.read(sharedPreferencesServiceProvider).cachedUserJson;
    if (cachedJson == null) return null;

    return User.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
  }

  Future<User> signup({
    required String username,
    required String name,
    required String gender,
    required String email,
    required String password,
  }) {
    return ref.read(authRepositoryProvider).signup(
          username: username,
          name: name,
          gender: gender,
          email: email,
          password: password,
        );
  }

  Future<void> verifyEmail({required String email, required String otp}) {
    return ref.read(authRepositoryProvider).verifyEmail(email: email, otp: otp);
  }

  Future<void> resendOtp({required String email}) {
    return ref.read(authRepositoryProvider).resendOtp(email: email);
  }

  Future<void> login({required String email, required String password}) async {
    final result = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
        );
    // Login only succeeds server-side for verified accounts, but the login
    // response itself doesn't echo `is_email_verified` — set it explicitly
    // so the cached session reflects reality.
    final user = result.user.copyWith(isEmailVerified: true);
    await _persistSession(user, result.token);
    state = AsyncValue.data(user);
  }

  Future<void> forgotPassword({required String email}) {
    return ref.read(authRepositoryProvider).forgotPassword(email: email);
  }

  Future<void> verifyResetOtp({required String email, required String otp}) {
    return ref.read(authRepositoryProvider).verifyResetOtp(email: email, otp: otp);
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return ref.read(authRepositoryProvider).resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );
  }

  /// Pushes an updated [User] (e.g. from a Profile fetch/edit) into the
  /// session so every screen watching `authControllerProvider` (Home's
  /// header, etc.) reflects it immediately — no separate "current user"
  /// source of truth.
  Future<void> setSessionUser(User user) async {
    state = AsyncValue.data(user);
    await ref.read(sharedPreferencesServiceProvider).setCachedUserJson(jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    try {
      // Best-effort: the JWT is stateless, so a failed/offline logout call
      // must not block clearing the local session.
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Ignored — local session is cleared unconditionally below.
    }
    await ref.read(secureStorageServiceProvider).deleteAuthToken();
    await ref.read(sharedPreferencesServiceProvider).clearCachedUser();
    state = const AsyncValue.data(null);
  }

  Future<void> _persistSession(User user, String token) async {
    await ref.read(secureStorageServiceProvider).writeAuthToken(token);
    await ref
        .read(sharedPreferencesServiceProvider)
        .setCachedUserJson(jsonEncode(user.toJson()));
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
