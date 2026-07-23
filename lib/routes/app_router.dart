import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/verify_otp_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
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
      if (!isLoggedIn && !_authRoutes.contains(location)) return RouteNames.login;
      if (isLoggedIn && _authRoutes.contains(location)) return RouteNames.home;
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
        builder: (context, state) => const _PlaceholderHomeScreen(),
      ),
    ],
  );
});

class _PlaceholderHomeScreen extends ConsumerWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: const Center(child: Text('Project foundation ready.')),
    );
  }
}
