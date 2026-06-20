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

/// Provider for real-time step count via Health Connect.
final stepCountProvider =
    StateNotifierProvider<StepCountNotifier, AsyncValue<int>>((ref) {
  return StepCountNotifier(ref.watch(stepsRepositoryProvider));
});

class StepCountNotifier extends StateNotifier<AsyncValue<int>> {
  final StepsRepository _repository;
  Timer? _refreshTimer;
  int _lastSyncedSteps = 0;

  StepCountNotifier(this._repository) : super(const AsyncValue.data(0)) {
    // Delay first refresh to ensure the activity is fully in foreground
    // and the permission dialogs can be shown properly.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) refresh();
    });
    // Poll Health Connect every 30 seconds while the app is open
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    try {
      // 1. Check if permissions are granted. If not, don't attempt to fetch yet.
      // We assume the UI (Dashboard) will handle requesting permissions.
      bool authorized = await _repository.checkAndRequestPermissions();
      if (!authorized) {
        if (!mounted) return;
        state = const AsyncValue.data(0);
        return;
      }

      // 2. Fetch today's steps
      final steps = await _repository.fetchTodaySteps();

      if (!mounted) return;
      state = AsyncValue.data(steps);

      // 3. Sync to Firebase if changed significantly or just periodically
      _syncToFirebase(steps);
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> _syncToFirebase(int steps) async {
    if (steps <= 0) return;
    if (steps == _lastSyncedSteps) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = Formatters.formatDateKey(DateTime.now());

    try {
      await _repository.saveDailySteps(
        uid: uid,
        date: today,
        steps: steps,
      );
      await _repository.cacheSteps(today, steps);
      _lastSyncedSteps = steps;
      debugPrint('✅ Steps synced to Firebase: $steps');
    } catch (e) {
      debugPrint('❌ Step sync failed: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

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
