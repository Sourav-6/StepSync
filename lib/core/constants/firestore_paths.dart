/// Firestore collection and document path constants.
class FirestorePaths {
  FirestorePaths._();

  // ─── Collection Names ───
  static const String users = 'users';
  static const String dailySteps = 'daily_steps';
  static const String leaderboards = 'leaderboards';
  static const String achievements = 'achievements';
  static const String notifications = 'notifications';
  static const String groups = 'groups';
  static const String friendRequests = 'friend_requests';

  // ─── User Document Fields ───
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldPhoneVerified = 'phoneVerified';
  static const String fieldProfileImage = 'profileImage';
  static const String fieldTotalSteps = 'totalSteps';
  static const String fieldCurrentStreak = 'currentStreak';
  static const String fieldLongestStreak = 'longestStreak';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldLastLogin = 'lastLogin';
  static const String fieldCurrentRank = 'currentRank';
  static const String fieldDailyGoal = 'dailyGoal';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldConsistencyScore = 'consistencyScore';
  static const String fieldFriendUids = 'friendUids';
  static const String fieldFriendRequestsSent = 'friendRequestsSent';
  static const String fieldFriendRequestsReceived = 'friendRequestsReceived';
  static const String fieldReferralCode = 'referralCode';
  static const String fieldReferredBy = 'referredBy';

  // ─── Daily Steps Fields ───
  static const String fieldUid = 'uid';
  static const String fieldDate = 'date';
  static const String fieldSteps = 'steps';
  static const String fieldDistance = 'distance';
  static const String fieldCalories = 'calories';
  static const String fieldTimestamp = 'timestamp';

  // ─── Achievement Fields ───
  static const String fieldType = 'type';
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldEarnedAt = 'earnedAt';
  static const String fieldIcon = 'icon';

  // ─── Helper Methods ───

  /// Get the document path for a user.
  static String userDoc(String uid) => '$users/$uid';

  /// Get the document ID for a daily step entry.
  /// Format: uid_YYYY-MM-DD
  static String dailyStepDocId(String uid, String date) => '${uid}_$date';

  /// Get the document path for a daily step entry.
  static String dailyStepDoc(String uid, String date) =>
      '$dailySteps/${dailyStepDocId(uid, date)}';

  /// Get the path for user achievements sub-collection.
  static String userAchievements(String uid) => '$users/$uid/$achievements';
}
