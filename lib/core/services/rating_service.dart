import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/core/utils/formatters.dart';

class RatingResult {
  final double starRating;
  final Map<String, double> groupRatings;

  RatingResult({required this.starRating, required this.groupRatings});
}

/// Service responsible for calculating the user's 5-star rating.
class RatingService {
  final FirebaseFirestore _firestore;

  RatingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Calculates the 5-star rating based on 4 criteria and returns it along with updated group averages
  Future<RatingResult> calculateRating({
    required String uid,
    required int todaySteps,
    required int dailyGoal,
    required int currentReferralBagStars,
  }) async {
    double totalRating = 0.0;
    
    // ─── Star 1 & 2: Daily Steps ───
    final stepPercentage = (todaySteps / 10000).clamp(0.0, 1.0);
    totalRating += stepPercentage * 2.0;

    // ─── Star 3: Referral Bag ───
    int newReferralBagStars = currentReferralBagStars;
    if (newReferralBagStars > 0) {
      totalRating += 1.0;
      newReferralBagStars -= 1;
    }

    // ─── Star 4: Best 5 of last 7 days ───
    final now = DateTime.now();
    final todayStr = Formatters.formatDateKey(now);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    final last7DaysQuery = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .where(FirestorePaths.fieldDate, isGreaterThanOrEqualTo: Formatters.formatDateKey(sevenDaysAgo))
        .get();

    List<int> recentSteps = [];
    for (final doc in last7DaysQuery.docs) {
      try {
        final steps = (doc.data()[FirestorePaths.fieldSteps] as num?)?.toInt() ?? 0;
        recentSteps.add(steps);
      } catch (_) {}
    }

    if (!last7DaysQuery.docs.any((d) => d.data()[FirestorePaths.fieldDate] == todayStr)) {
      recentSteps.add(todaySteps);
    }

    recentSteps.sort((a, b) => b.compareTo(a));
    
    final best5 = recentSteps.take(5).toList();
    if (best5.isNotEmpty) {
      final sum = best5.fold<int>(0, (prev, element) => prev + element);
      final avg = sum / 5;
      final star4Score = (avg / 10000).clamp(0.0, 1.0);
      totalRating += star4Score;
    }

    // ─── Star 5: Best group avg member rating ───
    double bestGroupAvg = 0.0;
    Map<String, double> groupRatings = {};
    
    final groupsQuery = await _firestore
        .collection(FirestorePaths.groups)
        .where('memberUids', arrayContains: uid)
        .get();

    for (final groupDoc in groupsQuery.docs) {
      final memberUids = List<String>.from(groupDoc.data()['memberUids'] ?? []);
      if (memberUids.isEmpty) continue;

      double groupTotalRating = 0.0;
      int validMembers = 0;

      for (var i = 0; i < memberUids.length; i += 10) {
        final chunk = memberUids.sublist(i, i + 10 > memberUids.length ? memberUids.length : i + 10);
        final membersQuery = await _firestore
            .collection(FirestorePaths.users)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        for (final memberDoc in membersQuery.docs) {
          final memberRating = (memberDoc.data()[FirestorePaths.fieldStarRating] as num?)?.toDouble() ?? 0.0;
          groupTotalRating += memberRating;
          validMembers++;
        }
      }

      if (validMembers > 0) {
        final avgRating = groupTotalRating / validMembers;
        groupRatings[groupDoc.id] = avgRating;
        if (avgRating > bestGroupAvg) {
          bestGroupAvg = avgRating;
        }
      }
    }

    totalRating += (bestGroupAvg / 5.0).clamp(0.0, 1.0);

    if (newReferralBagStars != currentReferralBagStars) {
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        FirestorePaths.fieldReferralBagStars: newReferralBagStars,
      });
    }

    return RatingResult(
      starRating: totalRating.clamp(0.0, 5.0),
      groupRatings: groupRatings,
    );
  }
}
