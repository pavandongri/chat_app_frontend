import 'package:flutter/material.dart';

import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/glass_card.dart';

/// Shared layout for every auth screen (Login, Signup, Verify OTP,
/// Forgot/Reset Password): a centered, scroll-safe column capped at a
/// readable width so the same form looks right on phone and tablet alike.
///
/// Premium look (Story 28): a subtle brand-gradient wash behind a
/// transparent app bar, the form itself in a glass panel, and a one-time
/// fade/slide entrance.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBackButton;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: '',
        showBackButton: widget.showBackButton,
        backgroundColor: Colors.transparent,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.background(colorScheme),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // `extendBodyBehindAppBar` lets the gradient run
                        // under the transparent app bar; this reserves the
                        // same height so the title doesn't sit behind the
                        // back button.
                        SizedBox(height: kToolbarHeight),
                        Text(widget.title, style: textTheme.headlineMedium),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(widget.subtitle!, style: textTheme.bodyMedium),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        GlassCard(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
