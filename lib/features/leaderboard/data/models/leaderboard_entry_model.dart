import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';

/// Data model for leaderboard entry with Firestore serialization.
class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.uid,
    required super.name,
    super.profileImage,
    required super.steps,
    required super.rank,
  });

  /// Create from a Firestore user document (all-time leaderboard).
  factory LeaderboardEntryModel.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntryModel(
      uid: doc.id,
      name: data[FirestorePaths.fieldName] ?? '',
      profileImage: data[FirestorePaths.fieldProfileImage] ?? '',
      steps: data[FirestorePaths.fieldTotalSteps] ?? 0,
      rank: rank,
    );
  }

  /// Create from aggregated daily steps.
  factory LeaderboardEntryModel.fromDailySteps(
    Map<String, dynamic> userData,
    int steps,
    int rank,
  ) {
    return LeaderboardEntryModel(
      uid: userData['uid'] ?? '',
      name: userData[FirestorePaths.fieldName] ?? '',
      profileImage: userData[FirestorePaths.fieldProfileImage] ?? '',
      steps: steps,
      rank: rank,
    );
  }
}
