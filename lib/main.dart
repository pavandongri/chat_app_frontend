import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/core_providers.dart';
import 'providers/realtime_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  FlutterError.onError = (details) {
    AppLogger.logError('FlutterError', details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };

  // In release builds, a widget build failure must never surface its raw
  // exception/stack trace — that's the same "stack trace on screen" bug as
  // the network path, just from a different source. Debug builds keep
  // Flutter's default red screen so the actual error stays visible.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const _ProductionErrorScreen();
  }

  // Edge-to-edge: without this, Android paints its own contrast scrim
  // behind the system navigation bar, which shows up as a hard-edged strip
  // of flat color over the bottom of every screen's actual background
  // (most visible against the auth screens' gradient).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ChatApp(),
    ),
  );
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // One WebSocket connection for the whole app session (Story 33) — opened
    // when a session appears, closed on logout. Not gated on any particular
    // screen being open.
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      final isLoggedIn = next.valueOrNull != null;
      final wasLoggedIn = previous?.valueOrNull != null;
      if (isLoggedIn && !wasLoggedIn) {
        ref.read(realtimeControllerProvider).connect();
      } else if (!isLoggedIn && wasLoggedIn) {
        ref.read(realtimeControllerProvider).disconnect();
      }
    });

    return MaterialApp.router(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: child!,
        );
      },
    );
  }
}

/// Last-resort replacement for Flutter's red error screen in release builds.
/// May render above `MaterialApp`'s own `Theme`, so it brings its own
/// `Material` ancestor and sticks to neutral colors instead of `Theme.of`.
class _ProductionErrorScreen extends StatelessWidget {
  const _ProductionErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF1A1A1A),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.white70),
              SizedBox(height: 12),
              Text(
                'Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
