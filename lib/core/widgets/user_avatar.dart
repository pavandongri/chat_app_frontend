import 'package:flutter/material.dart';

/// Shared avatar: shows the remote [avatarUrl] when present, always with an
/// initials fallback underneath so a slow, broken, or missing image never
/// leaves a blank space.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
  });

  final String name;
  final String? avatarUrl;
  final double radius;

  String get _initials {
    final source = name.trim();
    if (source.isEmpty) return '?';
    final letters = source
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = avatarUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundImage: hasUrl ? NetworkImage(url) : null,
      onForegroundImageError: hasUrl ? (_, _) {} : null,
      child: Text(
        _initials,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}
