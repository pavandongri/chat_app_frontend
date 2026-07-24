import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../providers/profile_provider.dart';
import '../../../routes/route_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          if (profileAsync.hasValue)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile',
              onPressed: () => context.push(
                RouteNames.editProfile,
                extra: profileAsync.requireValue,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingWidget(message: 'Loading profile…'),
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
                    UserAvatar(
                      name: user.name ?? user.username,
                      avatarUrl: user.avatarUrl,
                      radius: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.name ?? user.username,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          children: [
                            _ProfileField(label: 'Username', value: user.username),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(label: 'Name', value: user.name ?? '—'),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(
                              label: 'Gender',
                              value: user.gender == null || user.gender!.isEmpty
                                  ? '—'
                                  : user.gender![0].toUpperCase() + user.gender!.substring(1),
                            ),
                            const Divider(height: AppSpacing.lg),
                            _ProfileField(label: 'Email', value: user.email),
                          ],
                        ),
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
            child: Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
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
