import 'package:flutter/foundation.dart';

/// Domain entity representing a leaderboard entry.
@immutable
class LeaderboardEntry {
  final String uid;
  final String name;
  final String profileImage;
  final int steps;
  final int rank;
  final double consistencyScore;
  final double starRating;
  final double weeklyAvgStarRating;
  final double monthlyAvgStarRating;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.profileImage = '',
    required this.steps,
    required this.rank,
    this.consistencyScore = 0.0,
    this.starRating = 0.0,
    this.weeklyAvgStarRating = 0.0,
    this.monthlyAvgStarRating = 0.0,
  });
}
