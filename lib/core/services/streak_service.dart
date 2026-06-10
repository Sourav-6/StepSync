import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';

/// Service to handle streak calculations and related achievements.
class StreakService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  static const String _lastStreakCheckKey = 'last_streak_check_date';

  StreakService({
    FirebaseFirestore? firestore,
    required SharedPreferences prefs,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs;

  /// Check and update user's streak on app open.
  /// Returns the updated (currentStreak, longestStreak).
  Future<({int current, int longest})> checkAndUpdateStreak({
    required String uid,
    required int dailyGoal,
  }) async {
    final now = DateTime.now();
    final todayStr = _getDateString(now);
    
    // Check if we already processed streaks today to avoid redundant reads
    final lastCheck = _prefs.getString(_lastStreakCheckKey);
    // Even if checked, we need to return the current values, so we must fetch.
    // However, if we're just checking to reset, we might skip the logic below,
    // but the function needs to return a record.

    try {
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      if (!userDoc.exists) return (current: 0, longest: 0);

      final userData = userDoc.data()!;
      int currentStreak = userData[FirestorePaths.fieldCurrentStreak] ?? 0;
      int longestStreak = userData[FirestorePaths.fieldLongestStreak] ?? 0;
      final Timestamp? lastLoginTs = userData[FirestorePaths.fieldLastLogin] as Timestamp?;
      
      final lastLoginDate = lastLoginTs?.toDate() ?? DateTime.now().subtract(const Duration(days: 1));
      
      // Calculate days difference (ignoring time)
      final lastLoginDay = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
      final todayDay = DateTime(now.year, now.month, now.day);
      final daysDifference = todayDay.difference(lastLoginDay).inDays;

      bool streakBroken = false;

      if (daysDifference == 1) {
        // Logged in yesterday. Did they hit their goal yesterday?
        final yesterdayStr = _getDateString(now.subtract(const Duration(days: 1)));
        final yesterdayDocId = FirestorePaths.dailyStepDocId(uid, yesterdayStr);
        
        final yesterdayDoc = await _firestore
            .collection(FirestorePaths.dailySteps)
            .doc(yesterdayDocId)
            .get();

        if (yesterdayDoc.exists) {
          final yesterdaySteps = yesterdayDoc.data()![FirestorePaths.fieldSteps] as int? ?? 0;
          if (yesterdaySteps >= dailyGoal) {
            // Goal hit yesterday. Streak continues.
          } else {
            streakBroken = true;
          }
        } else {
          streakBroken = true;
        }
      } else if (daysDifference > 1) {
        streakBroken = true;
      }

      if (streakBroken) {
        currentStreak = 0;
        await _firestore.collection(FirestorePaths.users).doc(uid).update({
          FirestorePaths.fieldCurrentStreak: 0,
        });
      }

      await _prefs.setString(_lastStreakCheckKey, todayStr);

      return (current: currentStreak, longest: longestStreak);
    } catch (e) {
      debugPrint('Error checking streaks: $e');
      return (current: 0, longest: 0);
    }
  }

  /// Increment streak when daily goal is achieved.
  Future<void> incrementStreak(String uid) async {
    final now = DateTime.now();
    final todayStr = _getDateString(now);
    final goalReachedKey = 'goal_reached_$todayStr';
    
    if (_prefs.getBool(goalReachedKey) == true) {
      return;
    }

    try {
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      int currentStreak = (userData[FirestorePaths.fieldCurrentStreak] ?? 0) + 1;
      int longestStreak = userData[FirestorePaths.fieldLongestStreak] ?? 0;

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        FirestorePaths.fieldCurrentStreak: currentStreak,
        FirestorePaths.fieldLongestStreak: longestStreak,
      });

      await _prefs.setBool(goalReachedKey, true);

      await checkStreakAchievements(uid, currentStreak);

    } catch (e) {
      debugPrint('Error incrementing streak: $e');
    }
  }

  /// Check and award achievements based on streak length.
  Future<void> checkStreakAchievements(String uid, int streakLength) async {
    final milestones = {3: '3-Day Streak 🔥', 7: '7-Day Streak ⚡', 30: '30-Day Streak 🏅', 100: '100-Day Streak 🏆'};
    if (milestones.containsKey(streakLength)) {
      await awardAchievement(
        uid, 
        'streak_$streakLength', 
        milestones[streakLength]!, 
        'Maintained a $streakLength-day walking streak!'
      );
    }
  }

  /// Helper to award an achievement to a user.
  Future<void> awardAchievement(String uid, String id, String title, String description) async {
    final achievementId = '${uid}_$id';
    final docRef = _firestore
        .collection(FirestorePaths.userAchievements(uid))
        .doc(achievementId); // We can just use the flat path since we might use subcollections
        
    final docSnap = await docRef.get();
    
    if (!docSnap.exists) {
      // Actually we'll use a subcollection inside users
      final userAchievementRef = _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection('achievements')
          .doc(id);
          
      final snap = await userAchievementRef.get();
      if (!snap.exists) {
        await userAchievementRef.set({
          FirestorePaths.fieldUid: uid,
          FirestorePaths.fieldType: 'streak',
          FirestorePaths.fieldTitle: title,
          FirestorePaths.fieldDescription: description,
          FirestorePaths.fieldEarnedAt: FieldValue.serverTimestamp(),
          FirestorePaths.fieldIcon: 'streak_$id', // simplified
        });
      }
    }
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
