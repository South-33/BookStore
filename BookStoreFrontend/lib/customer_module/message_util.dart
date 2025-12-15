import 'package:flutter/material.dart';

class MessageUtil {
  static void showMessage(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showError(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void showInfo(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: Colors.blue,
    );
  }
}
