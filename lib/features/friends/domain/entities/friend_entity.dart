import 'package:flutter/foundation.dart';

/// Domain entity representing a friend or potential friend.
@immutable
class FriendEntity {
  final String uid;
  final String name;
  final String profileImage;
  final int totalSteps;
  final double consistencyScore;
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
    this.currentStreak = 0,
    this.isFriend = false,
    this.requestPending = false,
    this.requestReceived = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
