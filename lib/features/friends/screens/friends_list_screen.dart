import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/friend.dart';
import '../../../providers/friends_list_provider.dart';
import '../../../routes/route_names.dart';

class FriendsListScreen extends ConsumerStatefulWidget {
  const FriendsListScreen({super.key});

  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends ConsumerState<FriendsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsListControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Friends'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: AppTextField(
                controller: _searchController,
                label: 'Search friends',
                suffixIcon: const Icon(Icons.search),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: friendsAsync.when(
                loading: () => const LoadingWidget(message: 'Loading friends…'),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(friendsListControllerProvider),
                ),
                data: (friends) {
                  if (friends.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No friends yet — search for people to add.',
                      icon: Icons.groups_outlined,
                    );
                  }

                  final filtered = _query.trim().isEmpty
                      ? friends
                      : friends
                          .where((f) => f.name.toLowerCase().contains(_query.trim().toLowerCase()))
                          .toList();

                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(friendsListControllerProvider.future),
                    child: filtered.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            children: const [
                              EmptyStateWidget(
                                message: 'No friends match your search.',
                                icon: Icons.search_off_rounded,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) => _FriendCard(friend: filtered[index]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Stack(
              children: [
                UserAvatar(name: friend.name, avatarUrl: friend.avatarUrl, radius: 24),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: friend.isOnline ? AppColors.onlineIndicator : AppColors.offlineIndicator,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friend.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    friend.isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: friend.isOnline ? AppColors.onlineIndicator : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: () => context.push(RouteNames.chat, extra: friend),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
