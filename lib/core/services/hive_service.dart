import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing Hive local storage.
/// Used for caching step data, user preferences, and offline support.
class HiveService {
  HiveService._();

  // ─── Box Names ───
  static const String userBox = 'user_box';
  static const String stepsBox = 'steps_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';

  /// Get the cache box.
  static Box get cache => Hive.box(cacheBox);

  // ─── Settings Keys ───
  static const String keyDarkMode = 'dark_mode';
  static const String keyDailyGoal = 'daily_goal';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSyncDate = 'last_sync_date';
  static const String keyLastSensorSteps = 'last_sensor_steps';
  static const String keyLastSensorTime = 'last_sensor_time';

  static bool _initialized = false;

  /// Initialize Hive and open all required boxes.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox(userBox),
        Hive.openBox(stepsBox),
        Hive.openBox(settingsBox),
        Hive.openBox(cacheBox),
      ]);
      _initialized = true;
      debugPrint('✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('❌ Hive initialization failed: $e');
      rethrow;
    }
  }

  // ─── Settings Helpers ───

  /// Get the settings box.
  static Box get settings => Hive.box(settingsBox);

  /// Check if dark mode is enabled.
  static bool get isDarkMode => settings.get(keyDarkMode, defaultValue: true);

  /// Set dark mode preference.
  static Future<void> setDarkMode(bool value) =>
      settings.put(keyDarkMode, value);

  /// Get the daily step goal.
  static int get dailyGoal =>
      settings.get(keyDailyGoal, defaultValue: 10000);

  /// Set the daily step goal.
  static Future<void> setDailyGoal(int value) =>
      settings.put(keyDailyGoal, value);

  /// Check if notifications are enabled.
  static bool get notificationsEnabled =>
      settings.get(keyNotifications, defaultValue: true);

  /// Set notifications preference.
  static Future<void> setNotifications(bool value) =>
      settings.put(keyNotifications, value);

  /// Check if onboarding is complete.
  static bool get onboardingComplete =>
      settings.get(keyOnboardingComplete, defaultValue: false);

  /// Mark onboarding as complete.
  static Future<void> setOnboardingComplete() =>
      settings.put(keyOnboardingComplete, true);

  // ─── Steps Cache ───

  /// Get the steps box.
  static Box get steps => Hive.box(stepsBox);

  /// Cache today's step count locally.
  static Future<void> cacheSteps(String date, int stepCount) =>
      steps.put(date, stepCount);

  /// Get cached step count for a date.
  static int getCachedSteps(String date) =>
      steps.get(date, defaultValue: 0);

  /// Get last raw sensor steps.
  static int? get lastSensorSteps => steps.get(keyLastSensorSteps) as int?;

  /// Get last raw sensor time (milliseconds since epoch).
  static int? get lastSensorTime => steps.get(keyLastSensorTime) as int?;

  /// Save last raw sensor steps and timestamp.
  static Future<void> saveLastSensorData(int stepsVal, int timeMs) async {
    await steps.put(keyLastSensorSteps, stepsVal);
    await steps.put(keyLastSensorTime, timeMs);
  }

  // ─── User Cache ───

  /// Get the user box.
  static Box get user => Hive.box(userBox);

  /// Cache user data locally.
  static Future<void> cacheUserData(Map<String, dynamic> data) =>
      user.putAll(data);

  /// Get cached user data.
  static Map<String, dynamic>? getCachedUserData() {
    final box = Hive.box(userBox);
    if (box.isEmpty) return null;
    return Map<String, dynamic>.from(box.toMap());
  }

  /// Clear all cached data (on logout).
  static Future<void> clearAll() async {
    await Hive.box(userBox).clear();
    await Hive.box(stepsBox).clear();
    await Hive.box(cacheBox).clear();
    // Settings are preserved across sessions
  }
}
