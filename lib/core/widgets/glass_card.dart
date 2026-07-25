import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_glass.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Glassmorphism container — blurred, translucent surface with a soft
/// shadow and rounded corners. Use in place of an ad-hoc `Container`/`Card`
/// wherever the Phase 2 premium look calls for a glass panel (auth screens,
/// profile header, hero sections).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius,
    this.blurSigma = AppGlass.blurMd,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? AppRadius.lgRadius;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.soft(colorScheme),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppGlass.surfaceColor(colorScheme),
              borderRadius: radius,
              border: Border.all(color: AppGlass.borderColor(colorScheme)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
