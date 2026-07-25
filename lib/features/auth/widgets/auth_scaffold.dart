import 'package:flutter/material.dart';

import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/glass_card.dart';

/// Shared layout for every auth screen (Login, Signup, Verify OTP,
/// Forgot/Reset Password): a centered, scroll-safe column capped at a
/// readable width so the same form looks right on phone and tablet alike.
///
/// Premium look (Story 28, refined per user feedback): a brand-gradient
/// wash with soft decorative color blobs behind a transparent app bar, the
/// form itself in a glass panel, and a staggered one-time entrance.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.showBackButton = true,
    this.showLogo = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBackButton;

  /// Shows the brand badge above the title and centers the title/subtitle
  /// — used on Login/Signup, the two screens that open the auth flow.
  final bool showLogo;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = Tween(
    begin: 0.8,
    end: 1.0,
  ).animate(_logoFade);

  late final Animation<double> _headerFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
  );

  late final Animation<double> _cardFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );
  late final Animation<Offset> _cardSlide = Tween(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_cardFade);

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
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.background(colorScheme),
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -60,
            child: _BackgroundBlob(color: colorScheme.primary, size: 220),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: _BackgroundBlob(color: colorScheme.secondary, size: 260),
          ),
          // `Stack` sizes itself to fit its *non-positioned* children when
          // the incoming constraints allow it — since Login's form is
          // short enough to not need scrolling, an un-`Positioned` SafeArea
          // here let the whole Stack (gradient included) shrink to hug
          // that short content, exposing the Scaffold's own flat
          // background below it. Wrapping this in `Positioned.fill` too
          // removes the only non-positioned child, forcing the Stack to
          // fill the full screen unconditionally.
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // `extendBodyBehindAppBar` lets the background run
                        // under the transparent app bar; this reserves the
                        // same height so content doesn't sit behind the back
                        // button.
                        const SizedBox(height: kToolbarHeight),
                        if (widget.showLogo) ...[
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: const Center(
                                child: BrandBadge(
                                  iconSize: 32,
                                  padding: AppSpacing.md,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        FadeTransition(
                          opacity: _headerFade,
                          child: Column(
                            crossAxisAlignment: widget.showLogo
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: textTheme.headlineMedium,
                                textAlign: widget.showLogo
                                    ? TextAlign.center
                                    : TextAlign.start,
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.subtitle!,
                                  style: textTheme.bodyMedium,
                                  textAlign: widget.showLogo
                                      ? TextAlign.center
                                      : TextAlign.start,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: GlassCard(child: widget.child),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft, static (non-animated) glow — purely decorative depth behind the
/// glass card, cheap to render (a radial gradient, no blur filter needed).
class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
