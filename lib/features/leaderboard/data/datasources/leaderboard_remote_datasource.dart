import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/leaderboard/data/models/leaderboard_entry_model.dart';

/// Remote data source for leaderboard data using Firestore.
class LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeaderboardRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the global all-time leaderboard.
  Future<List<LeaderboardEntryModel>> getAllTimeLeaderboard({
    int limit = 50,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.users)
        .orderBy(FirestorePaths.fieldTotalSteps, descending: true)
        .limit(limit)
        .get();

    int rank = 1;
    return query.docs.map((doc) {
      final entry = LeaderboardEntryModel.fromFirestore(doc, rank);
      rank++;
      return entry;
    }).toList();
  }

  /// Get today's leaderboard from daily_steps collection.
  Future<List<LeaderboardEntryModel>> getTodayLeaderboard({
    int limit = 50,
  }) async {
    final today = Formatters.formatDateKey(DateTime.now());
    return _getDailyLeaderboard(today, limit: limit);
  }

  /// Get this week's leaderboard (aggregated).
  Future<List<LeaderboardEntryModel>> getWeeklyLeaderboard({
    int limit = 50,
  }) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final dates = List.generate(
      now.weekday,
      (i) => Formatters.formatDateKey(startOfWeek.add(Duration(days: i))),
    );

    return _getAggregatedLeaderboard(dates, limit: limit);
  }

  /// Get this month's leaderboard (aggregated).
  Future<List<LeaderboardEntryModel>> getMonthlyLeaderboard({
    int limit = 50,
  }) async {
    final now = DateTime.now();
    final dates = List.generate(
      now.day,
      (i) => Formatters.formatDateKey(DateTime(now.year, now.month, i + 1)),
    );

    return _getAggregatedLeaderboard(dates, limit: limit);
  }

  /// Get daily leaderboard for a specific date.
  /// Uses single-field query and sorts client-side to avoid composite indexes.
  Future<List<LeaderboardEntryModel>> _getDailyLeaderboard(
    String date, {
    int limit = 50,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldDate, isEqualTo: date)
        .get();

    // Sort by steps descending client-side
    final docs = query.docs.toList()
      ..sort((a, b) {
        final stepsA = (a.data()[FirestorePaths.fieldSteps] as int?) ?? 0;
        final stepsB = (b.data()[FirestorePaths.fieldSteps] as int?) ?? 0;
        return stepsB.compareTo(stepsA);
      });

    // Take top N
    final topDocs = docs.take(limit).toList();

    // Need to fetch user details for each entry
    final List<LeaderboardEntryModel> leaderboard = [];
    int rank = 1;

    for (final doc in topDocs) {
      final uid = doc.data()[FirestorePaths.fieldUid] as String;
      final steps = doc.data()[FirestorePaths.fieldSteps] as int;

      // Fetch user profile
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      
      // If user profile is deleted/inactive, skip them
      if (!userDoc.exists) continue;
      
      final userData = userDoc.data()!;
      
      // Ensure uid is in the map for proper parsing
      if (!userData.containsKey('uid')) {
        userData['uid'] = uid;
      }

      leaderboard.add(LeaderboardEntryModel.fromDailySteps(userData, steps, rank));
      rank++;
    }

    return leaderboard;
  }

  /// Aggregate steps over a list of dates for a leaderboard.
  Future<List<LeaderboardEntryModel>> _getAggregatedLeaderboard(
    List<String> dates, {
    int limit = 50,
  }) async {
    if (dates.isEmpty) return [];

    final Map<String, int> userSteps = {};

    // Firestore 'whereIn' is limited to 10 items, so chunk the dates
    for (var i = 0; i < dates.length; i += 10) {
      final chunk = dates.sublist(i, i + 10 > dates.length ? dates.length : i + 10);
      
      final query = await _firestore
          .collection(FirestorePaths.dailySteps)
          .where(FirestorePaths.fieldDate, whereIn: chunk)
          .get();

      for (final doc in query.docs) {
        final uid = doc.data()[FirestorePaths.fieldUid] as String;
        final steps = doc.data()[FirestorePaths.fieldSteps] as int;
        userSteps[uid] = (userSteps[uid] ?? 0) + steps;
      }
    }

    // Sort by steps
    final sortedEntries = userSteps.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top N
    final topEntries = sortedEntries.take(limit).toList();

    // Fetch user details
    final List<LeaderboardEntryModel> leaderboard = [];
    int rank = 1;

    for (final entry in topEntries) {
      final uid = entry.key;
      final steps = entry.value;

      final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      
      // If user profile is deleted/inactive, skip them
      if (!userDoc.exists) continue;
      
      final userData = userDoc.data()!;
      
      if (!userData.containsKey('uid')) {
        userData['uid'] = uid;
      }
      
      leaderboard.add(LeaderboardEntryModel.fromDailySteps(userData, steps, rank));
      rank++;
    }

    return leaderboard;
  }
}
