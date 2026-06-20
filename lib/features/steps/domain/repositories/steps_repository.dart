import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';

/// Abstract repository interface for step tracking operations.
abstract class StepsRepository {
  /// Check if Health Connect is available.
  Future<bool> checkHealthConnectAvailable();

  /// Prompt to install Health Connect.
  Future<void> promptInstallHealthConnect();

  /// Check and request Health Connect permissions.
  Future<bool> checkAndRequestPermissions();

  /// Fetch today's steps from Health Connect.
  Future<int> fetchTodaySteps();

  /// Save daily step data to Firestore.
  Future<void> saveDailySteps({
    required String uid,
    required String date,
    required int steps,
  });

  /// Get daily steps for a specific date.
  Future<DailyStepsEntity?> getDailySteps(String uid, String date);

  /// Get step history for a date range.
  Future<List<DailyStepsEntity>> getStepHistory({
    required String uid,
    required String startDate,
    required String endDate,
  });

  /// Get recent N days of step data.
  Future<List<DailyStepsEntity>> getRecentSteps({
    required String uid,
    int days = 7,
  });

  /// Get cached step count for today.
  int getCachedSteps(String date);

  /// Cache step count locally.
  Future<void> cacheSteps(String date, int steps);

  /// Get daily step goal.
  int get dailyGoal;

  /// Set daily step goal.
  Future<void> setDailyGoal(int goal);

  /// Dispose resources.
  void dispose();
}
