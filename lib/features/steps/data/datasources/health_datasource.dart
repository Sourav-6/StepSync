import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

/// Data source wrapping Google Health Connect for step counts.
/// 
/// This reads step data that Google Fit, Samsung Health, and other apps
/// have already written to Health Connect — giving you the same accurate
/// count those apps display.
class HealthDataSource {
  final Health _health = Health();
  bool _configured = false;
  bool _permissionsGranted = false;

  /// Ensures Health is configured before any API call.
  Future<void> _ensureConfigured() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
      debugPrint('✅ Health plugin configured');
    }
  }

  /// Check if Health Connect is available on this device.
  Future<bool> checkHealthConnectAvailable() async {
    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('📱 Health Connect SDK status: $status');

      if (status == HealthConnectSdkStatus.sdkAvailable) {
        return true;
      }

      // On Android 14+, Health Connect is a system module (always available).
      // On Android 13 and below, the user needs to install it.
      return status != null &&
          status != HealthConnectSdkStatus.sdkUnavailable;
    } catch (e) {
      debugPrint('❌ Error checking Health Connect availability: $e');
      // If we can't check, assume it's available and let the permission
      // request handle any errors.
      return true;
    }
  }

  /// Request to install Health Connect from Play Store.
  Future<void> promptInstallHealthConnect() async {
    try {
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint('❌ Error prompting Health Connect install: $e');
    }
  }

  /// Request the Android ACTIVITY_RECOGNITION runtime permission.
  /// This is required before Health Connect can share step data.
  Future<bool> _requestActivityRecognition() async {
    try {
      final status = await Permission.activityRecognition.status;
      debugPrint('🏃 Activity Recognition permission status: $status');

      if (status.isGranted) return true;

      final result = await Permission.activityRecognition.request();
      debugPrint('🏃 Activity Recognition permission result: $result');
      return result.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting ACTIVITY_RECOGNITION: $e');
      return false;
    }
  }

  /// Check permissions and request if needed.
  /// Returns true if we have read access to step data.
  Future<bool> checkAndRequestPermissions() async {
    // If already granted in this session, skip the check.
    if (_permissionsGranted) return true;

    try {
      await _ensureConfigured();

      // Step 1: Ensure ACTIVITY_RECOGNITION runtime permission.
      final activityGranted = await _requestActivityRecognition();
      if (!activityGranted) {
        debugPrint('⚠️ ACTIVITY_RECOGNITION permission denied');
        return false;
      }

      final types = [HealthDataType.STEPS];
      final permissions = [HealthDataAccess.READ];

      // Step 2: Check if Health Connect permissions are already granted.
      bool? hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      debugPrint('🔑 Has Health Connect permissions: $hasPermissions');

      if (hasPermissions == true) {
        _permissionsGranted = true;
        return true;
      }

      // Step 3: Request Health Connect permissions.
      bool authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      debugPrint('🔑 Health Connect authorization result: $authorized');

      if (authorized) {
        _permissionsGranted = true;
      }
      return authorized;
    } catch (e) {
      debugPrint('❌ Error checking/requesting Health Connect permissions: $e');
      return false;
    }
  }

  /// Fetch total steps for today from Health Connect.
  /// This returns the same data that Google Fit / Samsung Health display.
  Future<int> fetchTodaySteps() async {
    try {
      await _ensureConfigured();

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      debugPrint('👟 Steps from Health Connect: ${steps ?? 0}');
      return steps ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to fetch steps from Health Connect: $e');
      return 0;
    }
  }
}
