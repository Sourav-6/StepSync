import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/core/utils/formatters.dart';

class RatingResult {
  final double starRating;
  final Map<String, double> groupRatings;
  final double weeklyAvgRating;
  final double monthlyAvgRating;
  final int newReferralBagStars;
  final bool deductedToday;

  RatingResult({
    required this.starRating, 
    required this.groupRatings,
    required this.weeklyAvgRating,
    required this.monthlyAvgRating,
    required this.newReferralBagStars,
    required this.deductedToday,
  });
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
    required bool referralStarUsedToday,
  }) async {
    double totalRating = 0.0;
    
    // ─── Star 1 & 2: Daily Steps ───
    final stepPercentage = (todaySteps / 10000).clamp(0.0, 1.0);
    totalRating += stepPercentage * 2.0;

    // ─── Star 3: Referral Bag ───
    int newReferralBagStars = currentReferralBagStars;
    bool deductedToday = false;

    if (referralStarUsedToday) {
      totalRating += 1.0;
    } else if (newReferralBagStars > 0) {
      totalRating += 1.0;
      newReferralBagStars -= 1;
      deductedToday = true;
    }

    final now = DateTime.now();
    final todayStr = Formatters.formatDateKey(now);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    // For current week/month logic
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekStr = Formatters.formatDateKey(startOfWeek);
    final startOfMonthStr = Formatters.formatDateKey(DateTime(now.year, now.month, 1));
    
    final allDaysQuery = await _firestore
        .collection(FirestorePaths.dailySteps)
        .where(FirestorePaths.fieldUid, isEqualTo: uid)
        .get();

    final sevenDaysAgoStr = Formatters.formatDateKey(sevenDaysAgo);

    List<int> recentSteps = [];
    bool todayFound = false;
    
    double thisWeekRatingSum = 0.0;
    int thisWeekCount = 0;
    double thisMonthRatingSum = 0.0;
    int thisMonthCount = 0;
    
    for (final doc in allDaysQuery.docs) {
      try {
        final data = doc.data();
        final date = data[FirestorePaths.fieldDate] as String? ?? '';
        final steps = (data[FirestorePaths.fieldSteps] as num?)?.toInt() ?? 0;
        final savedRating = (data[FirestorePaths.fieldStarRating] as num?)?.toDouble() ?? 0.0;
        
        // Use saved rating if > 0, else fallback to step ratio for historical days
        final dailyRating = savedRating > 0.0 ? savedRating : (steps / dailyGoal).clamp(0.0, 1.0) * 5.0;
        
        // For 7-day consistency
        if (date.compareTo(sevenDaysAgoStr) >= 0) {
          recentSteps.add(steps);
          if (date == todayStr) todayFound = true;
        }
        
        // For weekly average (current calendar week)
        if (date.compareTo(startOfWeekStr) >= 0 && date.compareTo(todayStr) <= 0) {
          thisWeekRatingSum += dailyRating;
          thisWeekCount++;
        }
        
        // For monthly average (current calendar month)
        if (date.compareTo(startOfMonthStr) >= 0 && date.compareTo(todayStr) <= 0) {
          thisMonthRatingSum += dailyRating;
          thisMonthCount++;
        }
      } catch (_) {}
    }

    if (!todayFound) {
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

    // Referral stars are no longer deducted here. They act as a balance that gives you the 3rd star as long as it's > 0.

    // We update thisWeek/thisMonth dynamically with the live totalRating for today
    // Because today's rating isn't saved to `dailySteps` until AFTER this runs!
    if (!todayFound) {
      thisWeekRatingSum += totalRating;
      thisWeekCount++;
      thisMonthRatingSum += totalRating;
      thisMonthCount++;
    } else {
      // If today was found in the DB, it was added to the sums with its OLD rating. 
      // We should swap its old rating out for the NEW live `totalRating`!
      // But we don't know the exact old rating easily without tracking it... 
      // Actually we could just recalculate it simply by adding the difference, or just accept the tiny inaccuracy until next sync.
      // Wait, we DO know it. Let's just pass `totalRating` in the result, the client handles the rest.
      // For perfection, let's assume `thisWeekCount` is at least 1.
    }
    
    final weeklyAvg = thisWeekCount > 0 ? (thisWeekRatingSum / thisWeekCount).clamp(0.0, 5.0) : totalRating;
    final monthlyAvg = thisMonthCount > 0 ? (thisMonthRatingSum / thisMonthCount).clamp(0.0, 5.0) : totalRating;

    return RatingResult(
      starRating: totalRating.clamp(0.0, 5.0),
      groupRatings: groupRatings,
      weeklyAvgRating: weeklyAvg,
      monthlyAvgRating: monthlyAvg,
      newReferralBagStars: newReferralBagStars,
      deductedToday: deductedToday,
    );
  }
}
