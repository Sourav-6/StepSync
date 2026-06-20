import 'package:step_sync/core/services/hive_service.dart';

/// Local data source for caching step data using Hive.
class StepsLocalDataSource {
  /// Cache today's step count.
  Future<void> cacheSteps(String date, int steps) async {
    await HiveService.cacheSteps(date, steps);
  }

  /// Get cached step count for a date.
  int getCachedSteps(String date) {
    return HiveService.getCachedSteps(date);
  }

  /// Get last raw sensor steps.
  int? get lastSensorSteps => HiveService.lastSensorSteps;

  /// Get last raw sensor time (milliseconds since epoch).
  int? get lastSensorTime => HiveService.lastSensorTime;

  /// Save last raw sensor data.
  Future<void> saveLastSensorData(int steps, DateTime time) async {
    await HiveService.saveLastSensorData(steps, time.millisecondsSinceEpoch);
  }

  /// Get daily goal from settings.
  int get dailyGoal => HiveService.dailyGoal;

  /// Set daily goal.
  Future<void> setDailyGoal(int goal) async {
    await HiveService.setDailyGoal(goal);
  }
}
