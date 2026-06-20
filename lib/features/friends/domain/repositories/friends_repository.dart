import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/domain/entities/friend_request_entity.dart';

/// Abstract repository interface for friends system.
abstract class FriendsRepository {
  /// Send a friend request from [fromUid] to [toUid].
  Future<void> sendFriendRequest(String fromUid, String toUid);

  /// Accept a friend request from [fromUid] (current user is [toUid]).
  Future<void> acceptFriendRequest(String fromUid, String toUid);

  /// Reject a friend request from [fromUid] (current user is [toUid]).
  Future<void> rejectFriendRequest(String fromUid, String toUid);

  /// Remove a friend relationship between [uid] and [friendUid].
  Future<void> removeFriend(String uid, String friendUid);

  /// Get the list of friends for a user.
  Future<List<FriendEntity>> getFriendsList(String uid);

  /// Get pending incoming friend requests.
  Future<List<FriendRequestEntity>> getPendingRequests(String uid);

  /// Get sent outgoing friend requests.
  Future<List<FriendRequestEntity>> getSentRequests(String uid);

  /// Search users by name query.
  Future<List<FriendEntity>> searchUsers(String query, String currentUid);

  /// Get friends leaderboard sorted by consistency score.
  Future<List<FriendEntity>> getFriendsLeaderboard(String uid);

  /// Generate a unique referral code for a user.
  Future<String> generateReferralCode(String uid);

  /// Apply a referral code.
  Future<bool> applyReferralCode(String uid, String code);
}
