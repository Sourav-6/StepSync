import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';

/// Data model for daily steps with Firestore serialization.
class DailyStepsModel extends DailyStepsEntity {
  const DailyStepsModel({
    required super.uid,
    required super.date,
    required super.steps,
    required super.distance,
    required super.calories,
    super.starRating = 0.0,
    super.timestamp,
  });

  /// Create from Firestore document.
  factory DailyStepsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStepsModel(
      uid: data[FirestorePaths.fieldUid] ?? '',
      date: data[FirestorePaths.fieldDate] ?? '',
      steps: data[FirestorePaths.fieldSteps] ?? 0,
      distance: (data[FirestorePaths.fieldDistance] ?? 0).toDouble(),
      calories: (data[FirestorePaths.fieldCalories] ?? 0).toDouble(),
      starRating: (data[FirestorePaths.fieldStarRating] ?? 0).toDouble(),
      timestamp:
          (data[FirestorePaths.fieldTimestamp] as Timestamp?)?.toDate(),
    );
  }

  /// Create from a Map.
  factory DailyStepsModel.fromMap(Map<String, dynamic> map) {
    return DailyStepsModel(
      uid: map[FirestorePaths.fieldUid] ?? '',
      date: map[FirestorePaths.fieldDate] ?? '',
      steps: map[FirestorePaths.fieldSteps] ?? 0,
      distance: (map[FirestorePaths.fieldDistance] ?? 0).toDouble(),
      calories: (map[FirestorePaths.fieldCalories] ?? 0).toDouble(),
      starRating: (map[FirestorePaths.fieldStarRating] ?? 0).toDouble(),
      timestamp: map[FirestorePaths.fieldTimestamp] != null
          ? DateTime.tryParse(map[FirestorePaths.fieldTimestamp].toString())
          : null,
    );
  }

  /// Convert to Firestore-compatible Map.
  Map<String, dynamic> toFirestore() {
    return {
      FirestorePaths.fieldUid: uid,
      FirestorePaths.fieldDate: date,
      FirestorePaths.fieldSteps: steps,
      FirestorePaths.fieldDistance: distance,
      FirestorePaths.fieldCalories: calories,
      FirestorePaths.fieldStarRating: starRating,
      FirestorePaths.fieldTimestamp: Timestamp.now(),
    };
  }

  /// Convert to a regular Map (e.g. for Hive cache).
  Map<String, dynamic> toMap() {
    return {
      FirestorePaths.fieldUid: uid,
      FirestorePaths.fieldDate: date,
      FirestorePaths.fieldSteps: steps,
      FirestorePaths.fieldDistance: distance,
      FirestorePaths.fieldCalories: calories,
      FirestorePaths.fieldStarRating: starRating,
      FirestorePaths.fieldTimestamp: timestamp?.toIso8601String(),
    };
  }

  /// Create from steps with calculated metrics.
  factory DailyStepsModel.fromSteps({
    required String uid,
    required String date,
    required int steps,
    double starRating = 0.0,
  }) {
    return DailyStepsModel(
      uid: uid,
      date: date,
      steps: steps,
      distance: steps * 0.75 / 1000, // km
      calories: steps * 0.04, // kcal
      starRating: starRating,
      timestamp: DateTime.now(),
    );
  }
}
