import 'package:flutter/material.dart';

/// Compact inline progress indicator for buttons and per-item pending
/// states (as opposed to a full-page skeleton/loading state) — shared so
/// screens stop redefining the same
/// `SizedBox(child: CircularProgressIndicator(...))` individually.
class SmallSpinner extends StatelessWidget {
  const SmallSpinner({super.key, this.size = 20, this.strokeWidth = 2});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}
