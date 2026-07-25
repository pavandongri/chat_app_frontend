import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/small_spinner.dart';
import '../../../core/widgets/staggered_entrance.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/friend_request.dart';
import '../../../providers/friend_requests_provider.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  Future<void> _handle(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on AppException catch (e) {
      if (!context.mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(friendRequestsControllerProvider);
    final notifier = ref.read(friendRequestsControllerProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Friend Requests'),
      body: SafeArea(
        child: MaxWidthBox(
          child: requestsAsync.when(
            loading: () => const SkeletonList(),
            error: (error, _) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(friendRequestsControllerProvider),
            ),
            data: (data) {
              if (data.incoming.isEmpty && data.outgoing.isEmpty) {
                return const EmptyStateWidget(
                  message: 'No pending friend requests.',
                  icon: Icons.mark_email_read_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () => _handle(context, notifier.refresh),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  children: [
                    _SectionHeader(
                      title: 'Incoming',
                      count: data.incoming.length,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (data.incoming.isEmpty)
                      const _SectionEmptyHint(
                        message: 'No one has requested to add you.',
                      )
                    else
                      for (final (index, request) in data.incoming.indexed)
                        StaggeredEntrance(
                          index: index,
                          child: _IncomingRequestCard(
                            request: request,
                            isPending: data.pendingIds.contains(request.id),
                            onAccept: () => _handle(
                              context,
                              () => notifier.accept(request.id),
                            ),
                            onReject: () => _handle(
                              context,
                              () => notifier.reject(request.id),
                            ),
                          ),
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Outgoing',
                      count: data.outgoing.length,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (data.outgoing.isEmpty)
                      const _SectionEmptyHint(
                        message: "You haven't sent any requests.",
                      )
                    else
                      for (final (index, request) in data.outgoing.indexed)
                        StaggeredEntrance(
                          index: data.incoming.length + index,
                          child: _OutgoingRequestCard(
                            request: request,
                            isPending: data.pendingIds.contains(request.id),
                            onCancel: () => _handle(
                              context,
                              () => notifier.cancel(request.id),
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: AppSpacing.sm),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.fullRadius,
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionEmptyHint extends StatelessWidget {
  const _SectionEmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  const _IncomingRequestCard({
    required this.request,
    required this.isPending,
    required this.onAccept,
    required this.onReject,
  });

  final FriendRequest request;
  final bool isPending;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final user = request.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  name: user.name,
                  avatarUrl: user.avatarUrl,
                  radius: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (isPending)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: SmallSpinner(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(label: 'Accept', onPressed: onAccept),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _OutgoingRequestCard extends StatelessWidget {
  const _OutgoingRequestCard({
    required this.request,
    required this.isPending,
    required this.onCancel,
  });

  final FriendRequest request;
  final bool isPending;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final user = request.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            UserAvatar(name: user.name, avatarUrl: user.avatarUrl, radius: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPending)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SmallSpinner(),
              )
            else
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
