import 'package:intl/intl.dart';

/// Formatting utilities for numbers, dates, and metrics.
class Formatters {
  Formatters._();

  // ─── Number Formatting ───

  /// Format a number with commas (e.g., 12,345).
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// Format a number compactly (e.g., 12.3K).
  static String formatCompact(int number) {
    return NumberFormat.compact().format(number);
  }

  // ─── Step Metrics ───

  /// Calculate distance in kilometers from steps.
  /// Formula: steps × 0.75 / 1000
  static double stepsToDistance(int steps) {
    return steps * 0.75 / 1000;
  }

  /// Calculate calories burned from steps.
  /// Formula: steps × 0.04
  static double stepsToCalories(int steps) {
    return steps * 0.04;
  }

  /// Format distance (e.g., "6.18 km").
  static String formatDistance(double distanceKm) {
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  /// Format distance short (e.g., "6.18").
  static String formatDistanceShort(double distanceKm) {
    return distanceKm.toStringAsFixed(2);
  }

  /// Format calories (e.g., "330 kcal").
  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }

  /// Format calories short (e.g., "330").
  static String formatCaloriesShort(double calories) {
    return calories.toStringAsFixed(0);
  }

  // ─── Date Formatting ───

  /// Format date as "YYYY-MM-DD" (for Firestore document IDs).
  static String formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date as "Mon, Jan 5" (short display).
  static String formatDateShort(DateTime date) {
    return DateFormat('E, MMM d').format(date);
  }

  /// Format date as "January 5, 2024" (full display).
  static String formatDateFull(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Format date as "Jan 5" (minimal).
  static String formatDateMinimal(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format date as "Monday" (day name).
  static String formatDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Format date as "Mon" (short day name).
  static String formatDayNameShort(DateTime date) {
    return DateFormat('E').format(date);
  }

  /// Format time as "2:30 PM".
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // ─── Percentage ───

  /// Calculate goal progress percentage (0-100, capped at 100).
  static int goalProgress(int steps, int goal) {
    if (goal <= 0) return 0;
    final progress = (steps / goal * 100).round();
    return progress > 100 ? 100 : progress;
  }

  /// Calculate goal progress as a fraction (0.0-1.0).
  static double goalProgressFraction(int steps, int goal) {
    if (goal <= 0) return 0.0;
    final progress = steps / goal;
    return progress > 1.0 ? 1.0 : progress;
  }

  // ─── Greeting ───

  /// Get time-based greeting message.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ─── Motivational Message ───

  /// Get motivational message based on goal progress.
  static String getMotivationalMessage(int steps, int goal) {
    final progress = goalProgressFraction(steps, goal);
    if (progress >= 1.0) return 'Goal achieved! You\'re a champion! 🏆';
    if (progress >= 0.75) return 'So close! Push through! 🎯';
    if (progress >= 0.50) return 'Amazing effort! Almost at your goal! 🔥';
    if (progress >= 0.25) return "You're making progress! Halfway there! 💪";
    return 'Every step counts! Keep moving! 🚶';
  }

  // ─── Rank ───

  /// Format rank (e.g., "#15").
  static String formatRank(int rank) {
    return '#$rank';
  }

  /// Format streak (e.g., "12 Days").
  static String formatStreak(int days) {
    if (days == 1) return '1 Day';
    return '$days Days';
  }
}
