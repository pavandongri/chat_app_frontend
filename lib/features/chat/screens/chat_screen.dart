import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../../core/widgets/presence_indicator.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/small_spinner.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/friend.dart';
import '../../../models/message.dart';
import '../../../models/message_status.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.friend});

  final Friend friend;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _loadOlderThreshold = 200.0;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // reverse: true, so the far end (maxScrollExtent) is the oldest edge —
    // approaching it means the user scrolled toward history.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _loadOlderThreshold) {
      _loadOlder();
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    if (animate) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _loadOlder() async {
    try {
      await ref
          .read(chatControllerProvider(widget.friend.id).notifier)
          .loadOlder();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await ref
          .read(chatControllerProvider(widget.friend.id).notifier)
          .send(text);
      if (!mounted) return;
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  void _onBubbleLongPress(Message message) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openEditSheet(message);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(sheetContext).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmAndDelete(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditSheet(Message message) async {
    final editController = TextEditingController(text: message.message);
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> save() async {
            final text = editController.text.trim();
            if (text.isEmpty || text == message.message) {
              Navigator.of(sheetContext).pop();
              return;
            }
            setSheetState(() => isSaving = true);
            try {
              await ref
                  .read(chatControllerProvider(widget.friend.id).notifier)
                  .editMessage(message.id, text);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            } on AppException catch (e) {
              setSheetState(() => isSaving = false);
              if (mounted) AppSnackBar.showError(context, e.message);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit message',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(controller: editController, label: 'Message'),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Save',
                        isLoading: isSaving,
                        onPressed: save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    editController.dispose();
  }

  Future<void> _confirmAndDelete(Message message) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete message?',
      message:
          'This message will be permanently deleted. This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    try {
      await ref
          .read(chatControllerProvider(widget.friend.id).notifier)
          .deleteMessage(message.id);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      await ref
          .read(chatControllerProvider(widget.friend.id).notifier)
          .refresh();
    } on AppException catch (e) {
      if (mounted) AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatControllerProvider(widget.friend.id));

    return Scaffold(
      appBar: _ChatAppBar(
        friend: widget.friend,
        isRefreshing: _isRefreshing,
        onRefresh: _refresh,
      ),
      body: SafeArea(
        child: chatAsync.when(
          loading: () => const SkeletonChatBubbles(),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(chatControllerProvider(widget.friend.id)),
          ),
          data: _buildConversation,
        ),
      ),
    );
  }

  Widget _buildConversation(ChatState chatState) {
    if (!_didInitialScroll) {
      _didInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToBottom(animate: false),
      );
    }

    final myId = ref.watch(authControllerProvider).valueOrNull?.id;
    final reversedMessages = chatState.messages.reversed.toList();

    return MaxWidthBox(
      maxWidth: 800,
      child: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const EmptyStateWidget(
                    message: 'No messages yet — say hi!',
                    icon: Icons.chat_bubble_outline,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount:
                        reversedMessages.length +
                        (chatState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == reversedMessages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Center(child: SmallSpinner()),
                        );
                      }
                      final message = reversedMessages[index];
                      final isMine = message.senderId == myId;
                      return _MessageBubble(
                        message: message,
                        isMine: isMine,
                        onLongPress: isMine
                            ? () => _onBubbleLongPress(message)
                            : null,
                      );
                    },
                  ),
          ),
          _MessageInputBar(
            controller: _messageController,
            isSending: chatState.isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.friend,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final Friend friend;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              UserAvatar(
                name: friend.name,
                avatarUrl: friend.avatarUrl,
                radius: 18,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: PresenceDot(isOnline: friend.isOnline, size: 10),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                PresenceStatusText(
                  isOnline: friend.isOnline,
                  lastSeen: friend.lastSeen,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SmallSpinner(),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: onRefresh,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.onLongPress,
  });

  final Message message;
  final bool isMine;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.sizeOf(context).width * 0.75, 420),
          ),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(isMine ? AppRadius.lg : AppRadius.sm),
              bottomRight: Radius.circular(
                isMine ? AppRadius.sm : AppRadius.lg,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.sent
                          ? Icons.check
                          : Icons.done_all,
                      size: 14,
                      color: message.status == MessageStatus.seen
                          ? colorScheme.primary
                          : textColor.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(controller: controller, hint: 'Message'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty && !isSending;
                  return IconButton.filled(
                    onPressed: canSend ? onSend : null,
                    icon: isSending
                        ? const SmallSpinner(size: 18)
                        : const Icon(Icons.send),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
