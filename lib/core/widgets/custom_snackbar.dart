import 'package:flutter/material.dart';

/// Custom snack bar utility for consistent error/success messaging.
class CustomSnackBar {
  CustomSnackBar._();

  /// Show a success snack bar.
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Icons.check_circle_rounded, Colors.green);
  }

  /// Show an error snack bar.
  static void showError(BuildContext context, String message) {
    _show(context, message, Icons.error_rounded, Colors.red);
  }

  /// Show an info snack bar.
  static void showInfo(BuildContext context, String message) {
    _show(context, message, Icons.info_rounded,
        Theme.of(context).colorScheme.primary);
  }

  /// Show a warning snack bar.
  static void showWarning(BuildContext context, String message) {
    _show(context, message, Icons.warning_rounded, Colors.orange);
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
