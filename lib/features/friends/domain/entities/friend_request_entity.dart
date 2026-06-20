import 'package:flutter/foundation.dart';

/// Domain entity representing a friend request.
@immutable
class FriendRequestEntity {
  final String fromUid;
  final String toUid;
  final String fromName;
  final String fromProfileImage;
  final String toName;
  final String toProfileImage;
  final DateTime timestamp;

  const FriendRequestEntity({
    required this.fromUid,
    required this.toUid,
    this.fromName = '',
    this.fromProfileImage = '',
    this.toName = '',
    this.toProfileImage = '',
    required this.timestamp,
  });
}
