import 'dart:async';

import 'package:step_sync/features/steps/data/datasources/health_datasource.dart';
import 'package:step_sync/features/steps/data/datasources/steps_local_datasource.dart';
import 'package:step_sync/features/steps/data/datasources/steps_remote_datasource.dart';
import 'package:step_sync/features/steps/data/models/daily_steps_model.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/steps/domain/repositories/steps_repository.dart';

/// Implementation of StepsRepository using Health Connect.
class StepsRepositoryImpl implements StepsRepository {
  final HealthDataSource _healthDataSource;
  final StepsRemoteDataSource _remoteDataSource;
  final StepsLocalDataSource _localDataSource;

  StepsRepositoryImpl({
    HealthDataSource? healthDataSource,
    StepsRemoteDataSource? remoteDataSource,
    StepsLocalDataSource? localDataSource,
  })  : _healthDataSource = healthDataSource ?? HealthDataSource(),
        _remoteDataSource = remoteDataSource ?? StepsRemoteDataSource(),
        _localDataSource = localDataSource ?? StepsLocalDataSource();

  @override
  Future<bool> checkHealthConnectAvailable() async {
    return await _healthDataSource.checkHealthConnectAvailable();
  }

  @override
  Future<void> promptInstallHealthConnect() async {
    await _healthDataSource.promptInstallHealthConnect();
  }

  @override
  Future<bool> checkAndRequestPermissions() async {
    return await _healthDataSource.checkAndRequestPermissions();
  }

  @override
  Future<int> fetchTodaySteps() async {
    return await _healthDataSource.fetchTodaySteps();
  }

  @override
  Future<void> saveDailySteps({
    required String uid,
    required String date,
    required int steps,
  }) async {
    final model = DailyStepsModel.fromSteps(
      uid: uid,
      date: date,
      steps: steps,
    );
    await _remoteDataSource.saveDailySteps(model);
    await _localDataSource.cacheSteps(date, steps);
  }

  @override
  Future<DailyStepsEntity?> getDailySteps(String uid, String date) async {
    return _remoteDataSource.getDailySteps(uid, date);
  }

  @override
  Future<List<DailyStepsEntity>> getStepHistory({
    required String uid,
    required String startDate,
    required String endDate,
  }) async {
    final models = await _remoteDataSource.getStepHistory(
      uid: uid,
      startDate: startDate,
      endDate: endDate,
    );
    return List<DailyStepsEntity>.from(models);
  }

  @override
  Future<List<DailyStepsEntity>> getRecentSteps({
    required String uid,
    int days = 7,
  }) async {
    final models = await _remoteDataSource.getRecentSteps(uid: uid, days: days);
    return List<DailyStepsEntity>.from(models);
  }

  @override
  int getCachedSteps(String date) => _localDataSource.getCachedSteps(date);

  @override
  Future<void> cacheSteps(String date, int steps) async {
    await _localDataSource.cacheSteps(date, steps);
  }

  @override
  int get dailyGoal => _localDataSource.dailyGoal;

  @override
  Future<void> setDailyGoal(int goal) async {
    await _localDataSource.setDailyGoal(goal);
  }

  @override
  void dispose() {
    // Nothing to dispose for Health Connect (it is polled).
  }
}
