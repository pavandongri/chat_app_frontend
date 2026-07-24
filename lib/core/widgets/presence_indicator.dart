import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small colored dot for online (green) / offline (grey) status — shared by
/// Friends List and Chat Screen so presence rendering isn't duplicated per
/// screen (Story 15).
class PresenceDot extends StatelessWidget {
  const PresenceDot({
    super.key,
    required this.isOnline,
    this.size = 12,
    this.borderColor,
  });

  final bool isOnline;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline
            ? AppColors.onlineIndicator
            : AppColors.offlineIndicator,
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }
}

/// "Online" or "Last seen `<relative time>`" — the text companion to
/// [PresenceDot]. `lastSeen` is only ever a snapshot from the last fetch,
/// never live (per `coding-standards.md`'s manual-refresh-only rule).
class PresenceStatusText extends StatelessWidget {
  const PresenceStatusText({
    super.key,
    required this.isOnline,
    required this.lastSeen,
    this.style,
  });

  final bool isOnline;
  final DateTime? lastSeen;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = style ?? Theme.of(context).textTheme.bodySmall;

    return Text(
      isOnline ? 'Online' : _offlineLabel(),
      overflow: TextOverflow.ellipsis,
      style: baseStyle?.copyWith(
        color: isOnline
            ? AppColors.onlineIndicator
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _offlineLabel() {
    final seen = lastSeen;
    if (seen == null) return 'Offline';
    return 'Last seen ${_relativeTime(seen)}';
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}/${time.year}';
  }
}
