import 'package:flutter/material.dart';

/// Useful extension methods on BuildContext, String, DateTime, etc.

extension BuildContextX on BuildContext {
  /// Get the current theme.
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if dark mode is active.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Show a snack bar.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show a success snack bar.
  void showSuccessSnackBar(String message) {
    showSnackBar(message, isError: false);
  }

  /// Show an error snack bar.
  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }
}

extension StringX on String {
  /// Capitalize the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Get initials from a full name (e.g., "John Doe" → "JD").
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

extension DateTimeX on DateTime {
  /// Check if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get the start of the day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get the start of the week (Monday).
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Get the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get the number of days in this month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Format as date key "YYYY-MM-DD".
  String get dateKey =>
      '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

extension NumX on num {
  /// Add vertical spacing.
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Add horizontal spacing.
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
