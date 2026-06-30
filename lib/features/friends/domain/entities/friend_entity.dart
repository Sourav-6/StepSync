import 'package:flutter/foundation.dart';

/// Domain entity representing a friend or potential friend.
@immutable
class FriendEntity {
  final String uid;
  final String name;
  final String profileImage;
  final int totalSteps;
  final double consistencyScore;
  final double starRating;
  final int currentStreak;
  final bool isFriend;
  final bool requestPending;
  final bool requestReceived;

  const FriendEntity({
    required this.uid,
    required this.name,
    this.profileImage = '',
    this.totalSteps = 0,
    this.consistencyScore = 0.0,
    this.starRating = 0.0,
    this.currentStreak = 0,
    this.isFriend = false,
    this.requestPending = false,
    this.requestReceived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profileImage': profileImage,
      'totalSteps': totalSteps,
      'consistencyScore': consistencyScore,
      'starRating': starRating,
      'currentStreak': currentStreak,
      'isFriend': isFriend,
      'requestPending': requestPending,
      'requestReceived': requestReceived,
    };
  }

  factory FriendEntity.fromMap(Map<String, dynamic> map) {
    return FriendEntity(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'] ?? '',
      totalSteps: map['totalSteps'] ?? 0,
      consistencyScore: (map['consistencyScore'] as num?)?.toDouble() ?? 0.0,
      starRating: (map['starRating'] as num?)?.toDouble() ?? 0.0,
      currentStreak: map['currentStreak'] ?? 0,
      isFriend: map['isFriend'] ?? false,
      requestPending: map['requestPending'] ?? false,
      requestReceived: map['requestReceived'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
