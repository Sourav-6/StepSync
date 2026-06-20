import 'package:step_sync/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/domain/entities/friend_request_entity.dart';
import 'package:step_sync/features/friends/domain/repositories/friends_repository.dart';

/// Implementation of [FriendsRepository] that delegates to [FriendsRemoteDataSource].
class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _remoteDataSource;

  FriendsRepositoryImpl({FriendsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FriendsRemoteDataSource();

  @override
  Future<void> sendFriendRequest(String fromUid, String toUid) async {
    await _remoteDataSource.sendFriendRequest(fromUid, toUid);
  }

  @override
  Future<void> acceptFriendRequest(String fromUid, String toUid) async {
    await _remoteDataSource.acceptFriendRequest(fromUid, toUid);
  }

  @override
  Future<void> rejectFriendRequest(String fromUid, String toUid) async {
    await _remoteDataSource.rejectFriendRequest(fromUid, toUid);
  }

  @override
  Future<void> removeFriend(String uid, String friendUid) async {
    await _remoteDataSource.removeFriend(uid, friendUid);
  }

  @override
  Future<List<FriendEntity>> getFriendsList(String uid) async {
    return await _remoteDataSource.getFriendsList(uid);
  }

  @override
  Future<List<FriendRequestEntity>> getPendingRequests(String uid) async {
    return await _remoteDataSource.getPendingRequests(uid);
  }

  @override
  Future<List<FriendRequestEntity>> getSentRequests(String uid) async {
    return await _remoteDataSource.getSentRequests(uid);
  }

  @override
  Future<List<FriendEntity>> searchUsers(String query, String currentUid) async {
    return await _remoteDataSource.searchUsers(query, currentUid);
  }

  @override
  Future<List<FriendEntity>> getFriendsLeaderboard(String uid) async {
    return await _remoteDataSource.getFriendsLeaderboard(uid);
  }

  @override
  Future<String> generateReferralCode(String uid) async {
    return await _remoteDataSource.generateReferralCode(uid);
  }

  @override
  Future<bool> applyReferralCode(String uid, String code) async {
    return await _remoteDataSource.applyReferralCode(uid, code);
  }
}
