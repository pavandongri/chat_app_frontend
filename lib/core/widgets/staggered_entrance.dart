import 'package:flutter/material.dart';

/// One-time staggered fade + upward-slide entrance for list rows. Plays
/// once when a row first mounts (initial load) — since `initState` only
/// runs once per `Element`, an unrelated parent rebuild (typing in a
/// search field, a silent pull-to-refresh) reuses the same row Elements and
/// does not replay the animation.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Row position within its list — staggers the delay so rows cascade in
  /// rather than all appearing at once. Capped so long lists don't take
  /// forever to finish appearing.
  final int index;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  static const _stagger = Duration(milliseconds: 40);
  static const _maxDelay = Duration(milliseconds: 240);

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = _stagger * widget.index;
    Future.delayed(delay > _maxDelay ? _maxDelay : delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
