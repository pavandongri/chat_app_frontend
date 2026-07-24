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
import 'route_names.dart';

const _authRoutes = {
  RouteNames.login,
  RouteNames.signup,
  RouteNames.verifyOtp,
  RouteNames.forgotPassword,
  RouteNames.resetPassword,
};

/// Central route table. Auth state drives navigation entirely through this
/// `redirect` — no per-widget `if (!loggedIn) ...` checks anywhere.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authSession = ref.watch(authControllerProvider);

  return GoRouter(
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
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (context, state) =>
            VerifyOtpScreen(email: state.uri.queryParameters['email']),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) =>
            ResetPasswordScreen(email: state.uri.queryParameters['email']),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) =>
            EditProfileScreen(user: state.extra as User),
      ),
      GoRoute(
        path: RouteNames.searchFriends,
        builder: (context, state) => const SearchFriendsScreen(),
      ),
      GoRoute(
        path: RouteNames.friendRequests,
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: RouteNames.friendsList,
        builder: (context, state) => const FriendsListScreen(),
      ),
      GoRoute(
        path: RouteNames.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: RouteNames.chat,
        builder: (context, state) => ChatScreen(friend: state.extra as Friend),
      ),
    ],
  );
});
