import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, icon: Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, icon: Icons.error_outline, isError: true);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isError ? colorScheme.error : colorScheme.primary;
    final foreground = isError ? colorScheme.onError : colorScheme.onPrimary;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: background,
        content: Row(
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
