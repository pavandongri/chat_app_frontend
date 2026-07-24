import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Shimmering placeholder block — the building unit for every skeleton
/// loader in the app. Animates between two surface tones so it reads
/// clearly as "loading", not a static grey box.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              colorScheme.surfaceContainerHigh,
              colorScheme.surfaceContainerHighest,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Skeleton for a single avatar + two-line row with a trailing action —
/// the shape shared by Friends List, Chat List, Search Friends, and Friend
/// Requests cards.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key, this.trailingWidth = 64});

  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SkeletonBox(width: 140),
                  SizedBox(height: 8),
                  SkeletonBox(width: 90, height: 12),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SkeletonBox(
              width: trailingWidth,
              height: 32,
              borderRadius: AppRadius.smRadius,
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrollable list of [SkeletonListTile] placeholders — drop-in
/// replacement for a bare spinner on list screens.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 6, this.padding});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => const SkeletonListTile(),
    );
  }
}

/// Skeleton for a centered detail layout (avatar + name + info card) — used
/// by View Profile.
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonBox(
              width: 96,
              height: 96,
              borderRadius: BorderRadius.all(Radius.circular(48)),
            ),
            const SizedBox(height: AppSpacing.md),
            const SkeletonBox(width: 160, height: 18),
            const SizedBox(height: AppSpacing.sm),
            const SkeletonBox(width: 100, height: 14),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonBox(width: 70),
                          SkeletonBox(width: 120),
                        ],
                      ),
                      if (i < 3) const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a message thread — alternating incoming/outgoing bubble
/// shapes — used by Chat Screen.
class SkeletonChatBubbles extends StatelessWidget {
  const SkeletonChatBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    const widths = [180.0, 120.0, 220.0, 90.0, 160.0];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: widths.length,
      itemBuilder: (context, index) {
        final isMine = index.isOdd;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: SkeletonBox(
              width: widths[index],
              height: 40,
              borderRadius: AppRadius.lgRadius,
            ),
          ),
        );
      },
    );
  }
}
