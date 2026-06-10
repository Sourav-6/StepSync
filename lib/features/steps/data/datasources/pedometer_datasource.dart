import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:permission_handler/permission_handler.dart';

/// Data source wrapping the device pedometer sensor.
class PedometerDataSource {
  StreamSubscription<int>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  final _stepController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  final _pedometer = Pedometer();

  int _initialSteps = 0;
  int _currentSteps = 0;
  bool _initialized = false;
  bool _isAvailable = true;

  /// Stream of today's step count.
  Stream<int> get stepCountStream => _stepController.stream;

  /// Stream of pedestrian status ('walking', 'stopped', 'unknown').
  Stream<String> get pedestrianStatusStream => _statusController.stream;

  /// Whether the pedometer sensor is available.
  bool get isAvailable => _isAvailable;

  /// Current step count for today.
  int get currentSteps => _currentSteps;

  /// Initialize the pedometer and start listening.
  Future<void> initialize({int cachedStepsToday = 0}) async {
    _currentSteps = cachedStepsToday;

    // Check permissions first
    if (await Permission.activityRecognition.request().isGranted) {
      try {
      // Step count stream
      _stepSubscription = _pedometer.stepCountStream().listen(
        (int steps) {
          if (!_initialized) {
            _initialSteps = steps - cachedStepsToday;
            _initialized = true;
          }
          _currentSteps = steps - _initialSteps;
          if (_currentSteps < 0) _currentSteps = 0;
          _stepController.add(_currentSteps);
        },
        onError: (error) {
          debugPrint('❌ Pedometer step error: $error');
          _isAvailable = false;
          _stepController.addError(error);
        },
      );

      // Pedestrian status stream
      _statusSubscription = _pedometer.pedestrianStatusStream().listen(
        (PedestrianStatus status) {
          _statusController.add(status.name);
        },
        onError: (error) {
          debugPrint('❌ Pedometer status error: $error');
          _statusController.add('unknown');
        },
      );
      } catch (e) {
        debugPrint('❌ Pedometer not available: $e');
        _isAvailable = false;
      }
    } else {
      debugPrint('❌ Activity Recognition permission denied');
      _isAvailable = false;
    }
  }

  /// Dispose of subscriptions.
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _stepController.close();
    _statusController.close();
  }
}
