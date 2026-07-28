import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/verify_otp_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/friends/screens/friend_requests_screen.dart';
import '../features/friends/screens/friends_list_screen.dart';
import '../features/friends/screens/search_friends_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../models/friend.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'navigator_key.dart';
import 'route_names.dart';

const _authRoutes = {
  RouteNames.login,
  RouteNames.signup,
  RouteNames.verifyOtp,
  RouteNames.forgotPassword,
  RouteNames.resetPassword,
};

/// One subtle fade + slight upward slide, applied to every route so page
/// transitions are consistent app-wide rather than left to each platform's
/// differing default (per Story 19).
CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Central route table. Auth state drives navigation entirely through this
/// `redirect` — no per-widget `if (!loggedIn) ...` checks anywhere.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authSession = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      // Still restoring the session from secure storage — let Splash own
      // the transition once it resolves.
      if (authSession.isLoading) return null;

      final isLoggedIn = authSession.valueOrNull != null;
      final location = state.matchedLocation;

      if (location == RouteNames.splash) {
        return isLoggedIn ? RouteNames.home : RouteNames.login;
      }
      if (!isLoggedIn && !_authRoutes.contains(location)) {
        return RouteNames.login;
      }
      if (isLoggedIn && _authRoutes.contains(location)) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) =>
            _buildPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => _buildPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.signup,
        pageBuilder: (context, state) =>
            _buildPage(state, const SignupScreen()),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        pageBuilder: (context, state) => _buildPage(
          state,
          VerifyOtpScreen(email: state.uri.queryParameters['email']),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            _buildPage(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        pageBuilder: (context, state) => _buildPage(
          state,
          ResetPasswordScreen(email: state.uri.queryParameters['email']),
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        pageBuilder: (context, state) => _buildPage(state, const HomeScreen()),
      ),
      GoRoute(
        path: RouteNames.profile,
        pageBuilder: (context, state) =>
            _buildPage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        pageBuilder: (context, state) =>
            _buildPage(state, EditProfileScreen(user: state.extra as User)),
      ),
      GoRoute(
        path: RouteNames.searchFriends,
        pageBuilder: (context, state) =>
            _buildPage(state, const SearchFriendsScreen()),
      ),
      GoRoute(
        path: RouteNames.friendRequests,
        pageBuilder: (context, state) =>
            _buildPage(state, const FriendRequestsScreen()),
      ),
      GoRoute(
        path: RouteNames.friendsList,
        pageBuilder: (context, state) =>
            _buildPage(state, const FriendsListScreen()),
      ),
      GoRoute(
        path: RouteNames.chatList,
        pageBuilder: (context, state) =>
            _buildPage(state, const ChatListScreen()),
      ),
      GoRoute(
        path: RouteNames.chat,
        pageBuilder: (context, state) =>
            _buildPage(state, ChatScreen(friend: state.extra as Friend)),
      ),
    ],
  );
});
