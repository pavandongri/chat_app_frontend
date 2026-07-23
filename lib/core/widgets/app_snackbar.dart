import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void _show(BuildContext context, String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
