import 'package:flutter/foundation.dart';

/// Domain entity representing a leaderboard entry.
@immutable
class LeaderboardEntry {
  final String uid;
  final String name;
  final String profileImage;
  final int steps;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.profileImage = '',
    required this.steps,
    required this.rank,
  });
}
