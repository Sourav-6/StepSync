import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/steps/data/models/daily_steps_model.dart';

/// Remote data source for step data using Firestore.
class StepsRemoteDataSource {
  final FirebaseFirestore _firestore;

  StepsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save or update daily step data.
  Future<void> saveDailySteps(DailyStepsModel steps) async {
    final docId = FirestorePaths.dailyStepDocId(steps.uid, steps.date);
    await _firestore
        .collection(FirestorePaths.dailySteps)
        .doc(docId)
        .set(steps.toFirestore(), SetOptions(merge: true));

    // Also update user's total steps
    await _updateUserTotalSteps(steps.uid, steps.steps);
  }

  /// Get daily steps for a specific date.
  Future<DailyStepsModel?> getDailySteps(String uid, String date) async {
    final docId = FirestorePaths.dailyStepDocId(uid, date);
    final doc = await _firestore
        .collection(FirestorePaths.dailySteps)
        .doc(docId)
        .get();

    if (!doc.exists) return null;
    return DailyStepsModel.fromFirestore(doc);
  }

  /// Get step history for a date range.
  /// Uses single-field query on uid and filters dates client-side
  /// to avoid requiring a composite Firestore index.
  Future<List<DailyStepsModel>> getStepHistory({
    required String uid,
    required String startDate,
    required String endDate,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .get();

    final results = query.docs
        .map((doc) => DailyStepsModel.fromFirestore(doc))
        .where((step) => step.date.compareTo(startDate) >= 0 && step.date.compareTo(endDate) <= 0)
        .toList();

    // Sort by date descending (newest first)
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  /// Get the last N days of step data.
  /// Uses single-field query on uid and sorts client-side
  /// to avoid requiring a composite Firestore index.
  Future<List<DailyStepsModel>> getRecentSteps({
    required String uid,
    int days = 7,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .get();

    final results = query.docs
        .map((doc) => DailyStepsModel.fromFirestore(doc))
        .toList();

    // Sort by date descending (newest first)
    results.sort((a, b) => b.date.compareTo(a.date));

    // Take only the most recent N days
    return results.take(days).toList();
  }

  /// Update user's total steps and consistency score in the users collection.
  Future<void> _updateUserTotalSteps(String uid, int todaySteps) async {
    // Fetch the user document to get dailyGoal and createdAt
    final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    final dailyGoal = (userDoc.data()?[FirestorePaths.fieldDailyGoal] as int?) ?? 10000;
    final createdAtTimestamp = userDoc.data()?[FirestorePaths.fieldCreatedAt] as Timestamp?;
    final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now().subtract(const Duration(days: 7));

    // Get all daily steps for this user
    final allSteps = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .get();

    int totalSteps = 0;
    double last7DaysConsistencySum = 0.0;
    
    final now = DateTime.now();
    // Normalize today to start of day
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    
    for (final doc in allSteps.docs) {
      final steps = (doc.data()[FirestorePaths.fieldSteps] as int?) ?? 0;
      final dateStr = (doc.data()[FirestorePaths.fieldDate] as String?) ?? '';
      
      totalSteps += steps;
      
      // Calculate consistency for the last 7 days
      if (dateStr.isNotEmpty) {
        try {
          final parts = dateStr.split('-');
          final docDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          
          if (!docDate.isBefore(sevenDaysAgo) && !docDate.isAfter(today)) {
            double dailyScore = steps / dailyGoal.toDouble();
            if (dailyScore > 1.0) dailyScore = 1.0; // Cap at 100% per day
            last7DaysConsistencySum += dailyScore;
          }
        } catch (_) {}
      }
    }

    // Determine the denominator (max 7, or days since account creation)
    int daysSinceCreation = today.difference(DateTime(createdAt.year, createdAt.month, createdAt.day)).inDays + 1;
    int denominator = daysSinceCreation < 7 ? daysSinceCreation : 7;
    if (denominator < 1) denominator = 1;

    double consistencyScore = last7DaysConsistencySum / denominator;
    if (consistencyScore > 1.0) consistencyScore = 1.0;

    final prevTotalSteps = (userDoc.data()?[FirestorePaths.fieldTotalSteps] as int?) ?? 0;
    final diff = totalSteps - prevTotalSteps;

    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      FirestorePaths.fieldTotalSteps: totalSteps,
      FirestorePaths.fieldConsistencyScore: consistencyScore,
    });

    if (diff != 0) {
      final groupsQuery = await _firestore
          .collection(FirestorePaths.groups)
          .where('memberUids', arrayContains: uid)
          .get();
      
      if (groupsQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final groupDoc in groupsQuery.docs) {
          batch.update(groupDoc.reference, {
            'totalSteps': FieldValue.increment(diff),
          });
        }
        await batch.commit();
      }
    }
  }
}
