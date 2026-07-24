import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../routes/route_names.dart';

/// Post-login landing route. Purely a shell/navigation hub — no backend
/// calls beyond the session state Story 4 already provides.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _destinations = [
    _HomeDestination(
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Chats',
      route: RouteNames.chatList,
    ),
    _HomeDestination(
      icon: Icons.person_outline_rounded,
      label: 'Profile',
      route: RouteNames.profile,
    ),
    _HomeDestination(
      icon: Icons.person_search_rounded,
      label: 'Search Friends',
      route: RouteNames.searchFriends,
    ),
    _HomeDestination(
      icon: Icons.mark_email_unread_outlined,
      label: 'Friend Requests',
      route: RouteNames.friendRequests,
    ),
    _HomeDestination(
      icon: Icons.groups_outlined,
      label: 'Friends List',
      route: RouteNames.friendsList,
    ),
  ];

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Log out?',
      message: "You'll need to log in again to keep chatting.",
      confirmLabel: 'Log out',
    );
    if (confirmed) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chat App',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GreetingHeader(user: user),
                  const SizedBox(height: AppSpacing.xl),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _destinations.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.05,
                        ),
                    itemBuilder: (context, index) => _AnimatedEntrance(
                      delay: Duration(milliseconds: 60 * index),
                      child: _DestinationCard(
                        destination: _destinations[index],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AnimatedEntrance(
                    delay: Duration(milliseconds: 60 * _destinations.length),
                    child: _LogoutCard(
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeDestination {
  const _HomeDestination({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = user?.name ?? user?.username ?? 'there';

    return Row(
      children: [
        UserAvatar(name: displayName, avatarUrl: user?.avatarUrl, radius: 32),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: textTheme.bodyMedium),
              Text(
                displayName,
                style: textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});

  final _HomeDestination destination;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: () => context.push(destination.route),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  destination.icon,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                destination.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: colorScheme.onErrorContainer),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log out',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle staggered fade+slide reveal for dashboard cards, driven by
/// implicit animations only — no extra animation dependency needed.
class _AnimatedEntrance extends StatefulWidget {
  const _AnimatedEntrance({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
