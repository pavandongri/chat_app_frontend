import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/editable_avatar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
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
      appBar: const CustomAppBar(title: 'Profile', showBackButton: false),
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
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.person_outline,
                            label: 'Personal details',
                            onTap: () => context.push(
                              RouteNames.editProfile,
                              extra: user,
                            ),
                          ),
                          const Divider(height: 1, indent: 56),
                          _SettingsRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user.email,
                            trailing: user.isEmailVerified
                                ? Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : Text(
                                    'Unverified',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: const _DarkModeRow(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.logout,
                        label: 'Log out',
                        iconColor: Theme.of(context).colorScheme.error,
                        textColor: Theme.of(context).colorScheme.error,
                        onTap: () => _confirmLogout(context, ref),
                      ),
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

/// Big centered avatar (tap the camera badge to change it) + name/username
/// — the profile screen's hero, matching the reference layout's header.
class _ProfileHeader extends ConsumerStatefulWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _isUploading = false;

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isUploading = true);
    try {
      await ref.read(profileControllerProvider.notifier).uploadAvatar(file);
    } on AppException catch (e) {
      if (mounted) AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = widget.user;
    final bio = user.bio?.trim();

    return Column(
      children: [
        EditableAvatar(
          name: user.name ?? user.username,
          avatarUrl: user.avatarUrl,
          radius: 56,
          isUploading: _isUploading,
          onPickImage: _uploadAvatar,
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
    );
  }
}

class _DarkModeRow extends ConsumerWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return _SettingsRow(
      icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      label: 'Dark Mode',
      trailing: Switch(
        value: isDark,
        onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
      ),
    );
  }
}

/// One grouped-card row: icon + label, an optional trailing value/widget,
/// and a chevron when [onTap] is set — the shared shape for every row
/// inside a settings `GlassCard` group.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: textColor),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
