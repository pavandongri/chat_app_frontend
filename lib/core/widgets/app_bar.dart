import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  /// Overrides the themed app bar background — e.g. `Colors.transparent`
  /// so a screen's own gradient/glass background shows through (Story 28).
  /// Leave unset to keep the standard themed app bar.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: backgroundColor == null ? null : 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
