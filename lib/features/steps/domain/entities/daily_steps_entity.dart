import 'package:flutter/foundation.dart';

/// Domain entity representing a daily step record.
@immutable
class DailyStepsEntity {
  final String uid;
  final String date; // "YYYY-MM-DD"
  final int steps;
  final double distance; // in km
  final double calories; // in kcal
  final DateTime? timestamp;

  const DailyStepsEntity({
    required this.uid,
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    this.timestamp,
  });

  DailyStepsEntity copyWith({
    String? uid,
    String? date,
    int? steps,
    double? distance,
    double? calories,
    DateTime? timestamp,
  }) {
    return DailyStepsEntity(
      uid: uid ?? this.uid,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStepsEntity && other.uid == uid && other.date == date;

  @override
  int get hashCode => uid.hashCode ^ date.hashCode;
}
