import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1200)),
      ref.read(authControllerProvider.future),
    ]);
    if (!mounted) return;

    final user = results[1] as User?;
    context.go(user != null ? RouteNames.home : RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_rounded, size: 72, color: colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text('Chat App', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
