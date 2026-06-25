import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_provider.dart';

/// Provider for the top performing group (by avg steps per member).
final topPerformingGroupProvider = StreamProvider<GroupEntity?>((ref) {
  final dataSource = ref.watch(leaderboardDataSourceProvider);
  return dataSource.getTopGroupsStream(limit: 1).map((groups) => groups.isNotEmpty ? groups.first : null);
});

/// Provider for the top consistent performer (#1 on consistency leaderboard).
final topConsistentPerformerProvider = StreamProvider<LeaderboardEntry?>((ref) {
  final dataSource = ref.watch(leaderboardDataSourceProvider);
  return dataSource.getConsistencyLeaderboardStream(limit: 1).map((entries) => entries.isNotEmpty ? entries.first : null);
});

/// Provider for the user's rank change (positive = improved, negative = dropped).
/// Compares yesterday's rank vs today's rank using step data.
final userRankChangeProvider = FutureProvider<int>((ref) async {
  final userState = ref.watch(currentUserProvider);
  final user = userState.valueOrNull;
  if (user == null) return 0;

  try {
    final firestore = FirebaseFirestore.instance;

    // Get today's rank (how many users have better consistency)
    final todayQuery = await firestore
        .collection(FirestorePaths.users)
        .where(FirestorePaths.fieldStarRating, isGreaterThan: user.starRating)
        .count()
        .get();

    final todayRank = (todayQuery.count ?? 0) + 1;

    // Use stored rank for comparison
    final previousRank = user.currentRank;

    if (previousRank == 0) return 0; // No previous data

    // Positive means rank improved (went from 5 to 3 = +2 improvement)
    return previousRank - todayRank;
  } catch (_) {
    return 0;
  }
});
