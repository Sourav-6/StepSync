import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:step_sync/features/leaderboard/domain/entities/leaderboard_entry.dart';

/// Leaderboard filter types.
enum LeaderboardFilter { today, thisWeek, thisMonth, allTime }

/// Provider for leaderboard data source.
final leaderboardDataSourceProvider = Provider<LeaderboardRemoteDataSource>((ref) {
  return LeaderboardRemoteDataSource();
});

/// Provider for the selected leaderboard filter.
final leaderboardFilterProvider =
    StateProvider<LeaderboardFilter>((ref) => LeaderboardFilter.allTime);

/// Provider for leaderboard data based on filter.
final leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final filter = ref.watch(leaderboardFilterProvider);
  final dataSource = ref.watch(leaderboardDataSourceProvider);

  switch (filter) {
    case LeaderboardFilter.today:
      return dataSource.getTodayLeaderboard();
    case LeaderboardFilter.thisWeek:
      return dataSource.getWeeklyLeaderboard();
    case LeaderboardFilter.thisMonth:
      return dataSource.getMonthlyLeaderboard();
    case LeaderboardFilter.allTime:
      return dataSource.getAllTimeLeaderboard();
  }
});

/// Provider for the current user's exact global rank based on total steps.
/// Uses Firestore's highly efficient count() aggregation query instead of 
/// downloading the entire leaderboard.
final currentUserGlobalRankProvider = FutureProvider<int>((ref) async {
  // Need to import auth provider and firestore, doing it dynamically here for safety
  // but let's just make sure the file has the right imports at the top
  final userState = ref.watch(currentUserProvider);
  final user = userState.valueOrNull;
  
  if (user == null) return 0;

  try {
    // Count how many users have more steps than the current user
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('users')
        .where('totalSteps', isGreaterThan: user.totalSteps)
        .count()
        .get();
        
    // Rank is (number of people with more steps) + 1
    return (query.count ?? 0) + 1;
  } catch (e) {
    return 0; // Fallback
  }
});
