import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../routes/route_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Log out?',
      message: "You'll need to log in again to keep chatting.",
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (confirmed) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const SkeletonDetail(),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(profileControllerProvider),
          ),
          data: (user) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    _ProfileHeader(user: user),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          children: [
                            _ProfileField(
                              label: 'Username',
                              value: user.username,
                            ),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(
                              label: 'Name',
                              value: user.name ?? '—',
                            ),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(
                              label: 'Gender',
                              value: user.gender == null || user.gender!.isEmpty
                                  ? '—'
                                  : user.gender![0].toUpperCase() +
                                        user.gender!.substring(1),
                            ),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(label: 'Email', value: user.email),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Edit Profile',
                      onPressed: () =>
                          context.push(RouteNames.editProfile, extra: user),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SettingsCard(),
                    const SizedBox(height: AppSpacing.md),
                    _LogoutButton(
                      onPressed: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large hero-style header — glassmorphism per Story 22/21.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bio = user.bio?.trim();

    return GlassCard(
      child: Column(
        children: [
          UserAvatar(
            name: user.name ?? user.username,
            avatarUrl: user.avatarUrl,
            radius: 56,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.name ?? user.username,
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('@${user.username}', style: textTheme.bodyMedium),
          if (bio != null && bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(bio, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// "Settings" entry point (Story 27) — currently just the theme toggle;
/// more rows land here as future settings stories are added.
class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Card(
      child: SwitchListTile(
        secondary: Icon(
          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        ),
        title: const Text('Dark Mode'),
        value: isDark,
        onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Log out'),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
