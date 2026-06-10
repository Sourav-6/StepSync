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

  /// Update user's total steps in the users collection.
  Future<void> _updateUserTotalSteps(String uid, int todaySteps) async {
    // Get all daily steps for this user to calculate total
    final allSteps = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .get();

    int totalSteps = 0;
    for (final doc in allSteps.docs) {
      totalSteps += (doc.data()[FirestorePaths.fieldSteps] as int?) ?? 0;
    }

    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      FirestorePaths.fieldTotalSteps: totalSteps,
    });
  }
}
