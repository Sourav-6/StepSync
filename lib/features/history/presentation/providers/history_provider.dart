import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';

/// History tab filter.
enum HistoryTab { daily, weekly, monthly }

/// Provider for selected history tab.
final historyTabProvider = StateProvider<HistoryTab>((ref) => HistoryTab.daily);

/// Track the currently viewed month (defaults to current month).
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Track the currently viewed week (Monday of that week).
final selectedWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // Find the Monday of the current week
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
});

/// Fetch up to 4 months of data to minimize reads, and cache it.
final cachedHistoryProvider = FutureProvider.family<List<DailyStepsEntity>, String>((ref, uid) async {
  final repo = ref.watch(stepsRepositoryProvider);
  
  // Keep alive to cache the data in memory for this session
  ref.keepAlive();
  
  final now = DateTime.now();
  // Fetch from 3 months ago (so total 4 months: current + 3 previous)
  final startDate = DateTime(now.year, now.month - 3, 1);
  final endStr = Formatters.formatDateKey(now);
  final startStr = Formatters.formatDateKey(startDate);
  
  return repo.getStepHistory(
    uid: uid,
    startDate: startStr,
    endDate: endStr,
  );
});

/// Filtered data for the specific selected month.
final selectedMonthHistoryProvider = Provider.family<List<DailyStepsEntity>, String>((ref, uid) {
  final allData = ref.watch(cachedHistoryProvider(uid)).value ?? [];
  final selectedMonth = ref.watch(selectedMonthProvider);
  
  return allData.where((d) {
    try {
      final parts = d.date.split('-');
      final dDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      return dDate.year == selectedMonth.year && dDate.month == selectedMonth.month;
    } catch (_) {
      return false;
    }
  }).toList();
});

/// Filtered data for the specific selected week (Mon - Sun).
final selectedWeekHistoryProvider = Provider.family<List<DailyStepsEntity>, String>((ref, uid) {
  final allData = ref.watch(cachedHistoryProvider(uid)).value ?? [];
  final selectedWeek = ref.watch(selectedWeekProvider);
  final endOfWeek = selectedWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
  
  return allData.where((d) {
    try {
      final parts = d.date.split('-');
      final dDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return !dDate.isBefore(selectedWeek) && !dDate.isAfter(endOfWeek);
    } catch (_) {
      return false;
    }
  }).toList();
});

/// Computed weekly stats.
class WeeklyStats {
  final int totalSteps;
  final double avgSteps;
  final double totalDistance;
  final double totalCalories;
  final int bestDay;
  final List<DailyStepsEntity> days;

  WeeklyStats({
    required this.totalSteps,
    required this.avgSteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.bestDay,
    required this.days,
  });

  factory WeeklyStats.fromDays(List<DailyStepsEntity> days) {
    final totalSteps = days.fold<int>(0, (sum, d) => sum + d.steps);
    final bestDay = days.isEmpty
        ? 0
        : days.reduce((a, b) => a.steps > b.steps ? a : b).steps;
    return WeeklyStats(
      totalSteps: totalSteps,
      avgSteps: days.isEmpty ? 0 : totalSteps / days.length,
      totalDistance: days.fold<double>(0, (sum, d) => sum + d.distance),
      totalCalories: days.fold<double>(0, (sum, d) => sum + d.calories),
      bestDay: bestDay,
      days: days,
    );
  }
}

/// Computed monthly stats.
class MonthlyStats {
  final int totalSteps;
  final double avgDailySteps;
  final double totalDistance;
  final double totalCalories;
  final int activeDays;
  final List<DailyStepsEntity> days;

  MonthlyStats({
    required this.totalSteps,
    required this.avgDailySteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.activeDays,
    required this.days,
  });

  factory MonthlyStats.fromDays(List<DailyStepsEntity> days) {
    final totalSteps = days.fold<int>(0, (sum, d) => sum + d.steps);
    final activeDays = days.where((d) => d.steps > 0).length;
    return MonthlyStats(
      totalSteps: totalSteps,
      avgDailySteps: activeDays > 0 ? totalSteps / activeDays : 0,
      totalDistance: days.fold<double>(0, (sum, d) => sum + d.distance),
      totalCalories: days.fold<double>(0, (sum, d) => sum + d.calories),
      activeDays: activeDays,
      days: days,
    );
  }
}
