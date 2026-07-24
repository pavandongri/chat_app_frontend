import 'package:flutter/material.dart';

/// Centers [child] and caps its width so list/detail content doesn't just
/// stretch edge-to-edge on wide (tablet/landscape) viewports (Story 18).
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
