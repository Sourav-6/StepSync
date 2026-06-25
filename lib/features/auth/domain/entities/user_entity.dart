import 'package:flutter/foundation.dart';

/// Domain entity representing a user in the system.
/// This is the clean architecture domain layer representation.
@immutable
class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool phoneVerified;
  final String profileImage;
  final int totalSteps;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int currentRank;
  final int dailyGoal;
  final String? fcmToken;
  final double consistencyScore;
  final List<String> friendUids;
  final List<String> friendRequestsSent;
  final List<String> friendRequestsReceived;
  final String referralCode;
  final String? referredBy;
  final double starRating;
  final int referralBagStars;
  final double weeklyAvgStarRating;
  final double monthlyAvgStarRating;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.phoneVerified = false,
    this.profileImage = '',
    this.totalSteps = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.lastLogin,
    this.currentRank = 0,
    this.dailyGoal = 10000,
    this.fcmToken,
    this.consistencyScore = 1.0,
    this.friendUids = const [],
    this.friendRequestsSent = const [],
    this.friendRequestsReceived = const [],
    this.referralCode = '',
    this.referredBy,
    this.starRating = 0.0,
    this.referralBagStars = 0,
    this.weeklyAvgStarRating = 0.0,
    this.monthlyAvgStarRating = 0.0,
  });

  /// Create a copy with updated fields.
  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    bool? phoneVerified,
    String? profileImage,
    int? totalSteps,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? currentRank,
    int? dailyGoal,
    String? fcmToken,
    double? consistencyScore,
    List<String>? friendUids,
    List<String>? friendRequestsSent,
    List<String>? friendRequestsReceived,
    String? referralCode,
    String? referredBy,
    double? starRating,
    int? referralBagStars,
    double? weeklyAvgStarRating,
    double? monthlyAvgStarRating,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      profileImage: profileImage ?? this.profileImage,
      totalSteps: totalSteps ?? this.totalSteps,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      currentRank: currentRank ?? this.currentRank,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      fcmToken: fcmToken ?? this.fcmToken,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      friendUids: friendUids ?? this.friendUids,
      friendRequestsSent: friendRequestsSent ?? this.friendRequestsSent,
      friendRequestsReceived: friendRequestsReceived ?? this.friendRequestsReceived,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      starRating: starRating ?? this.starRating,
      referralBagStars: referralBagStars ?? this.referralBagStars,
      weeklyAvgStarRating: weeklyAvgStarRating ?? this.weeklyAvgStarRating,
      monthlyAvgStarRating: monthlyAvgStarRating ?? this.monthlyAvgStarRating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserEntity(uid: $uid, name: $name, email: $email)';
}
