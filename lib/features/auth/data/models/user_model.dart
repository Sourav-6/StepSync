import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';

/// Data model for Firestore serialization/deserialization.
/// Extends UserEntity with JSON conversion capabilities.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.phoneVerified,
    super.profileImage,
    super.totalSteps,
    super.currentStreak,
    super.longestStreak,
    required super.createdAt,
    required super.lastLogin,
    super.currentRank,
    super.dailyGoal,
    super.fcmToken,
    super.consistencyScore,
    super.friendUids,
    super.friendRequestsSent,
    super.friendRequestsReceived,
    super.referralCode,
    super.referredBy,
    super.starRating,
    super.referralBagStars,
  });

  /// Create from Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data[FirestorePaths.fieldName] ?? '',
      email: data[FirestorePaths.fieldEmail] ?? '',
      phone: data[FirestorePaths.fieldPhone] ?? '',
      phoneVerified: data[FirestorePaths.fieldPhoneVerified] ?? false,
      profileImage: data[FirestorePaths.fieldProfileImage] ?? '',
      totalSteps: data[FirestorePaths.fieldTotalSteps] ?? 0,
      currentStreak: data[FirestorePaths.fieldCurrentStreak] ?? 0,
      longestStreak: data[FirestorePaths.fieldLongestStreak] ?? 0,
      createdAt: (data[FirestorePaths.fieldCreatedAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      lastLogin: (data[FirestorePaths.fieldLastLogin] as Timestamp?)?.toDate() ??
          DateTime.now(),
      currentRank: data[FirestorePaths.fieldCurrentRank] ?? 0,
      dailyGoal: data[FirestorePaths.fieldDailyGoal] ?? 10000,
      fcmToken: data[FirestorePaths.fieldFcmToken],
      consistencyScore: (data[FirestorePaths.fieldConsistencyScore] as num?)?.toDouble() ?? 0.0,
      friendUids: List<String>.from(data[FirestorePaths.fieldFriendUids] ?? []),
      friendRequestsSent: List<String>.from(data[FirestorePaths.fieldFriendRequestsSent] ?? []),
      friendRequestsReceived: List<String>.from(data[FirestorePaths.fieldFriendRequestsReceived] ?? []),
      referralCode: data[FirestorePaths.fieldReferralCode] ?? '',
      referredBy: data[FirestorePaths.fieldReferredBy],
      starRating: (data[FirestorePaths.fieldStarRating] as num?)?.toDouble() ?? 0.0,
      referralBagStars: (data[FirestorePaths.fieldReferralBagStars] as num?)?.toInt() ?? 0,
    );
  }

  /// Create from a Map (e.g., from Hive cache).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map[FirestorePaths.fieldName] ?? '',
      email: map[FirestorePaths.fieldEmail] ?? '',
      phone: map[FirestorePaths.fieldPhone] ?? '',
      phoneVerified: map[FirestorePaths.fieldPhoneVerified] ?? false,
      profileImage: map[FirestorePaths.fieldProfileImage] ?? '',
      totalSteps: map[FirestorePaths.fieldTotalSteps] ?? 0,
      currentStreak: map[FirestorePaths.fieldCurrentStreak] ?? 0,
      longestStreak: map[FirestorePaths.fieldLongestStreak] ?? 0,
      createdAt: DateTime.tryParse(map[FirestorePaths.fieldCreatedAt]?.toString() ?? '') ?? DateTime.now(),
      lastLogin: DateTime.tryParse(map[FirestorePaths.fieldLastLogin]?.toString() ?? '') ?? DateTime.now(),
      currentRank: map[FirestorePaths.fieldCurrentRank] ?? 0,
      dailyGoal: map[FirestorePaths.fieldDailyGoal] ?? 10000,
      fcmToken: map[FirestorePaths.fieldFcmToken],
      consistencyScore: (map[FirestorePaths.fieldConsistencyScore] as num?)?.toDouble() ?? 0.0,
      friendUids: List<String>.from(map[FirestorePaths.fieldFriendUids] ?? []),
      friendRequestsSent: List<String>.from(map[FirestorePaths.fieldFriendRequestsSent] ?? []),
      friendRequestsReceived: List<String>.from(map[FirestorePaths.fieldFriendRequestsReceived] ?? []),
      referralCode: map[FirestorePaths.fieldReferralCode] ?? '',
      referredBy: map[FirestorePaths.fieldReferredBy],
      starRating: (map[FirestorePaths.fieldStarRating] as num?)?.toDouble() ?? 0.0,
      referralBagStars: (map[FirestorePaths.fieldReferralBagStars] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to Firestore-compatible Map.
  Map<String, dynamic> toFirestore() {
    return {
      FirestorePaths.fieldName: name,
      FirestorePaths.fieldEmail: email,
      FirestorePaths.fieldPhone: phone,
      FirestorePaths.fieldPhoneVerified: phoneVerified,
      FirestorePaths.fieldProfileImage: profileImage,
      FirestorePaths.fieldTotalSteps: totalSteps,
      FirestorePaths.fieldCurrentStreak: currentStreak,
      FirestorePaths.fieldLongestStreak: longestStreak,
      FirestorePaths.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirestorePaths.fieldLastLogin: Timestamp.fromDate(lastLogin),
      FirestorePaths.fieldCurrentRank: currentRank,
      FirestorePaths.fieldDailyGoal: dailyGoal,
      FirestorePaths.fieldFcmToken: fcmToken,
      FirestorePaths.fieldConsistencyScore: consistencyScore,
      FirestorePaths.fieldFriendUids: friendUids,
      FirestorePaths.fieldFriendRequestsSent: friendRequestsSent,
      FirestorePaths.fieldFriendRequestsReceived: friendRequestsReceived,
      FirestorePaths.fieldReferralCode: referralCode,
      FirestorePaths.fieldReferredBy: referredBy,
      FirestorePaths.fieldStarRating: starRating,
      FirestorePaths.fieldReferralBagStars: referralBagStars,
    };
  }

  /// Convert to a regular Map (e.g., for Hive cache).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      FirestorePaths.fieldName: name,
      FirestorePaths.fieldEmail: email,
      FirestorePaths.fieldPhone: phone,
      FirestorePaths.fieldPhoneVerified: phoneVerified,
      FirestorePaths.fieldProfileImage: profileImage,
      FirestorePaths.fieldTotalSteps: totalSteps,
      FirestorePaths.fieldCurrentStreak: currentStreak,
      FirestorePaths.fieldLongestStreak: longestStreak,
      FirestorePaths.fieldCreatedAt: createdAt.toIso8601String(),
      FirestorePaths.fieldLastLogin: lastLogin.toIso8601String(),
      FirestorePaths.fieldCurrentRank: currentRank,
      FirestorePaths.fieldDailyGoal: dailyGoal,
      FirestorePaths.fieldFcmToken: fcmToken,
      FirestorePaths.fieldConsistencyScore: consistencyScore,
      FirestorePaths.fieldFriendUids: friendUids,
      FirestorePaths.fieldFriendRequestsSent: friendRequestsSent,
      FirestorePaths.fieldFriendRequestsReceived: friendRequestsReceived,
      FirestorePaths.fieldReferralCode: referralCode,
      FirestorePaths.fieldReferredBy: referredBy,
      FirestorePaths.fieldStarRating: starRating,
      FirestorePaths.fieldReferralBagStars: referralBagStars,
    };
  }

  /// Create from a UserEntity (domain → data layer conversion).
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      phoneVerified: entity.phoneVerified,
      profileImage: entity.profileImage,
      totalSteps: entity.totalSteps,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
      currentRank: entity.currentRank,
      dailyGoal: entity.dailyGoal,
      fcmToken: entity.fcmToken,
      consistencyScore: entity.consistencyScore,
      friendUids: entity.friendUids,
      friendRequestsSent: entity.friendRequestsSent,
      friendRequestsReceived: entity.friendRequestsReceived,
      referralCode: entity.referralCode,
      referredBy: entity.referredBy,
      starRating: entity.starRating,
      referralBagStars: entity.referralBagStars,
    );
  }

  factory UserModel.newUser({
    required String uid,
    required String name,
    required String email,
    String phone = '',
    String profileImage = '',
    String? referredBy,
  }) {
    final now = DateTime.now();
    
    // Generate a referral code (e.g., first 3 letters of name + last 4 of uid)
    final sanitizedName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final namePrefix = sanitizedName.length >= 3 
        ? sanitizedName.substring(0, 3).toUpperCase() 
        : (sanitizedName.isNotEmpty ? sanitizedName.toUpperCase().padRight(3, 'X') : 'USR');
    final uidSuffix = uid.length >= 4 ? uid.substring(uid.length - 4).toUpperCase() : '0000';
    final generatedReferralCode = '$namePrefix$uidSuffix';

    return UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      profileImage: profileImage,
      totalSteps: 0,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: now,
      lastLogin: now,
      currentRank: 0,
      dailyGoal: 10000,
      consistencyScore: 0.0,
      starRating: 0.0,
      referralBagStars: 0,
      referralCode: generatedReferralCode,
      referredBy: referredBy,
    );
  }
}
