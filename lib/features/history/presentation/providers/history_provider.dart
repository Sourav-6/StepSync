import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';

/// History tab filter.
enum HistoryTab { daily, weekly, monthly }

/// Provider for selected history tab.
final historyTabProvider =
    StateProvider<HistoryTab>((ref) => HistoryTab.daily);

/// Provider for weekly history (last 7 days).
final weeklyHistoryProvider =
    FutureProvider.family<List<DailyStepsEntity>, String>((ref, uid) async {
  final repo = ref.watch(stepsRepositoryProvider);
  return repo.getRecentSteps(uid: uid, days: 7);
});

/// Provider for monthly history.
final monthlyHistoryProvider =
    FutureProvider.family<List<DailyStepsEntity>, String>((ref, uid) async {
  final repo = ref.watch(stepsRepositoryProvider);
  final now = DateTime.now();
  final startDate = Formatters.formatDateKey(DateTime(now.year, now.month, 1));
  final endDate = Formatters.formatDateKey(now);
  return repo.getStepHistory(
    uid: uid,
    startDate: startDate,
    endDate: endDate,
  );
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
