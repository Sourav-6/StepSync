import 'package:step_sync/core/services/hive_service.dart';
import 'package:step_sync/features/auth/data/models/user_model.dart';

/// Local data source for caching user data using Hive.
class AuthLocalDataSource {
  /// Cache user data locally.
  Future<void> cacheUser(UserModel user) async {
    await HiveService.cacheUserData(user.toMap());
  }

  /// Get cached user data.
  UserModel? getCachedUser() {
    final data = HiveService.getCachedUserData();
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  /// Clear cached user data.
  Future<void> clearCache() async {
    await HiveService.clearAll();
  }

  /// Check if onboarding is complete.
  bool get isOnboardingComplete => HiveService.onboardingComplete;

  /// Mark onboarding as complete.
  Future<void> setOnboardingComplete() async {
    await HiveService.setOnboardingComplete();
  }
}
