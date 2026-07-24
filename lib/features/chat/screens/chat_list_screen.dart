import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/conversation.dart';
import '../../../models/message_status.dart';
import '../../../providers/chat_provider.dart';
import '../../../routes/route_names.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await ref.read(chatListControllerProvider.notifier).refresh();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(chatListControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Chats'),
      body: SafeArea(
        child: MaxWidthBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: AppTextField(
                  controller: _searchController,
                  label: 'Search conversations',
                  suffixIcon: const Icon(Icons.search),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: conversationsAsync.when(
                  loading: () => const SkeletonList(),
                  error: (error, _) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(chatListControllerProvider),
                  ),
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return const EmptyStateWidget(
                        message:
                            'No conversations yet — start one from your friends list.',
                        icon: Icons.chat_bubble_outline_rounded,
                      );
                    }

                    final filtered = _query.trim().isEmpty
                        ? conversations
                        : conversations
                              .where(
                                (c) => c.friend.name.toLowerCase().contains(
                                  _query.trim().toLowerCase(),
                                ),
                              )
                              .toList();

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: filtered.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              children: const [
                                EmptyStateWidget(
                                  message:
                                      'No conversations match your search.',
                                  icon: Icons.search_off_rounded,
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) =>
                                  _ConversationCard(
                                    conversation: filtered[index],
                                  ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final friend = conversation.friend;
    final hasUnread = conversation.unreadCount > 0;

    return Card(
      child: InkWell(
        borderRadius: AppRadius.lgRadius,
        onTap: () => context.push(RouteNames.chat, extra: friend),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              UserAvatar(
                name: friend.name,
                avatarUrl: friend.avatarUrl,
                radius: 26,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      friend.name,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (conversation.lastMessageFromMe) ...[
                          Icon(
                            _statusIcon(conversation.status),
                            size: 16,
                            color: _statusColor(
                              conversation.status,
                              colorScheme,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: textTheme.bodyMedium?.copyWith(
                              color: hasUnread
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(conversation.lastMessageAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: hasUnread
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.seen:
        return Icons.done_all;
    }
  }

  Color _statusColor(MessageStatus status, ColorScheme colorScheme) {
    return status == MessageStatus.seen
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
  }

  String _formatTimestamp(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.month}/${time.day}';
  }
}
