import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// The app's circular gradient icon mark — the Splash hero badge, and
/// (smaller) the logo lockup atop Login/Signup for a consistent brand
/// presence across entry screens.
class BrandBadge extends StatelessWidget {
  const BrandBadge({
    super.key,
    this.iconSize = 56,
    this.padding = AppSpacing.lg,
  });

  final double iconSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        shape: BoxShape.circle,
        boxShadow: AppShadows.softLarge(colorScheme),
      ),
      child: Icon(
        Icons.chat_bubble_rounded,
        size: iconSize,
        color: AppColors.onGradient,
      ),
    );
  }
}
