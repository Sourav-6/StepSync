import 'package:flutter/foundation.dart';

@immutable
class ReferralContributorEntity {
  final String uid;
  final String name;
  final String profileImage;
  final int starsGiven;
  final DateTime lastUpdated;

  const ReferralContributorEntity({
    required this.uid,
    required this.name,
    required this.profileImage,
    required this.starsGiven,
    required this.lastUpdated,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReferralContributorEntity &&
        other.uid == uid &&
        other.starsGiven == starsGiven;
  }

  @override
  int get hashCode => uid.hashCode ^ starsGiven.hashCode;
}
