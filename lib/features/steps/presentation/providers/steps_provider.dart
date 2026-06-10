import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/steps/data/repositories/steps_repository_impl.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/steps/domain/repositories/steps_repository.dart';

/// Provider for the steps repository.
final stepsRepositoryProvider = Provider<StepsRepository>((ref) {
  final repo = StepsRepositoryImpl();
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// Provider for real-time step count.
final stepCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(stepsRepositoryProvider);
  final today = Formatters.formatDateKey(DateTime.now());
  final cached = repo.getCachedSteps(today);

  // Initialize pedometer with cached steps
  repo.initializePedometer(cachedStepsToday: cached);

  return repo.stepCountStream;
});

/// Provider for pedestrian status.
final pedestrianStatusProvider = StreamProvider<String>((ref) {
  final repo = ref.watch(stepsRepositoryProvider);
  return repo.pedestrianStatusStream;
});

/// Provider for daily goal.
final dailyGoalProvider = StateProvider<int>((ref) {
  final repo = ref.watch(stepsRepositoryProvider);
  return repo.dailyGoal;
});

/// Provider for today's step data.
final todayStepsProvider = Provider<StepData>((ref) {
  final stepCount = ref.watch(stepCountProvider);
  final goal = ref.watch(dailyGoalProvider);

  return stepCount.when(
    data: (steps) => StepData(
      steps: steps,
      goal: goal,
      distance: Formatters.stepsToDistance(steps),
      calories: Formatters.stepsToCalories(steps),
      progress: Formatters.goalProgressFraction(steps, goal),
      progressPercent: Formatters.goalProgress(steps, goal),
    ),
    loading: () => StepData.empty(goal),
    error: (_, __) => StepData.empty(goal),
  );
});

/// Provider that automatically syncs steps to Firebase periodically.
/// This listens to the step count stream and saves to Firestore every 30 seconds
/// or whenever a significant step change is detected.
final stepSyncProvider = Provider<StepSyncService>((ref) {
  final repo = ref.watch(stepsRepositoryProvider);
  final service = StepSyncService(repo);

  // Listen to step count changes and trigger sync
  ref.listen<AsyncValue<int>>(stepCountProvider, (previous, next) {
    next.whenData((steps) {
      service.onStepUpdate(steps);
    });
  });

  ref.onDispose(() => service.dispose());
  return service;
});

/// Service that handles periodic syncing of step data to Firebase.
class StepSyncService {
  final StepsRepository _repository;
  Timer? _syncTimer;
  int _lastSyncedSteps = 0;
  int _currentSteps = 0;
  bool _disposed = false;

  StepSyncService(this._repository) {
    // Sync every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncToFirebase();
    });
  }

  /// Called whenever the pedometer reports a new step count.
  void onStepUpdate(int steps) {
    _currentSteps = steps;

    // Sync immediately if steps changed by 50+ since last sync
    if ((_currentSteps - _lastSyncedSteps).abs() >= 50) {
      _syncToFirebase();
    }
  }

  /// Sync current steps to Firestore and local cache.
  Future<void> _syncToFirebase() async {
    if (_disposed) return;
    if (_currentSteps <= 0) return;
    if (_currentSteps == _lastSyncedSteps) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = Formatters.formatDateKey(DateTime.now());

    try {
      await _repository.saveDailySteps(
        uid: uid,
        date: today,
        steps: _currentSteps,
      );
      await _repository.cacheSteps(today, _currentSteps);
      _lastSyncedSteps = _currentSteps;
      debugPrint('✅ Steps synced to Firebase: $_currentSteps');
    } catch (e) {
      debugPrint('❌ Step sync failed: $e');
    }
  }

  void dispose() {
    _disposed = true;
    // Do a final sync before disposing
    _syncToFirebase();
    _syncTimer?.cancel();
  }
}

/// Provider for recent step history (last 7 days).
final recentStepsProvider =
    FutureProvider.family<List<DailyStepsEntity>, String>((ref, uid) async {
  final repo = ref.watch(stepsRepositoryProvider);
  return repo.getRecentSteps(uid: uid, days: 7);
});

/// Provider for monthly step history.
final monthlyStepsProvider = FutureProvider.family<List<DailyStepsEntity>,
    ({String uid, String startDate, String endDate})>((ref, params) async {
  final repo = ref.watch(stepsRepositoryProvider);
  return repo.getStepHistory(
    uid: params.uid,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Aggregated step data for the dashboard.
class StepData {
  final int steps;
  final int goal;
  final double distance;
  final double calories;
  final double progress; // 0.0 - 1.0
  final int progressPercent; // 0 - 100

  const StepData({
    required this.steps,
    required this.goal,
    required this.distance,
    required this.calories,
    required this.progress,
    required this.progressPercent,
  });

  factory StepData.empty(int goal) => StepData(
        steps: 0,
        goal: goal,
        distance: 0,
        calories: 0,
        progress: 0,
        progressPercent: 0,
      );

  bool get goalReached => steps >= goal;
}
