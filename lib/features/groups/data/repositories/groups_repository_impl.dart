import 'package:uuid/uuid.dart';
import 'package:step_sync/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:step_sync/features/groups/data/models/group_model.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/groups/domain/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource _remoteDataSource;

  GroupsRepositoryImpl({GroupsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? GroupsRemoteDataSource();

  @override
  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required String creatorUid,
  }) async {
    final groupId = const Uuid().v4();
    final group = GroupModel(
      groupId: groupId,
      name: name,
      description: description,
      isPublic: isPublic,
      adminUids: [creatorUid],
      memberUids: [creatorUid],
      invitedUids: [],
      pendingRequestUids: [],
      totalSteps: 0,
      createdAt: DateTime.now(),
    );
    await _remoteDataSource.createGroup(group);
  }

  @override
  Future<GroupEntity?> getGroup(String groupId) async {
    return await _remoteDataSource.getGroup(groupId);
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    await _remoteDataSource.updateGroup(GroupModel.fromEntity(group));
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<List<GroupEntity>> getAllDiscoverableGroups() async {
    return await _remoteDataSource.getAllDiscoverableGroups();
  }

  @override
  Future<List<GroupEntity>> getUserGroups(String uid) async {
    return await _remoteDataSource.getUserGroups(uid);
  }

  @override
  Future<void> joinPublicGroup(String groupId, String uid) async {
    await _remoteDataSource.joinPublicGroup(groupId, uid);
  }

  @override
  Future<void> leaveGroup(String groupId, String uid) async {
    await _remoteDataSource.leaveGroup(groupId, uid);
  }

  @override
  Future<void> inviteUserToGroup(String groupId, String targetUid) async {
    await _remoteDataSource.inviteUserToGroup(groupId, targetUid);
  }

  @override
  Future<void> acceptInvite(String groupId, String uid) async {
    await _remoteDataSource.acceptInvite(groupId, uid);
  }

  @override
  Future<void> rejectInvite(String groupId, String uid) async {
    await _remoteDataSource.rejectInvite(groupId, uid);
  }

  @override
  Future<void> promoteToAdmin(String groupId, String targetUid) async {
    await _remoteDataSource.promoteToAdmin(groupId, targetUid);
  }

  @override
  Future<void> demoteAdmin(String groupId, String targetUid) async {
    await _remoteDataSource.demoteAdmin(groupId, targetUid);
  }

  @override
  Future<void> requestToJoinPrivateGroup(String groupId, String uid) async {
    await _remoteDataSource.requestToJoinPrivateGroup(groupId, uid);
  }

  @override
  Future<void> acceptJoinRequest(String groupId, String uid) async {
    await _remoteDataSource.acceptJoinRequest(groupId, uid);
  }

  @override
  Future<void> rejectJoinRequest(String groupId, String uid) async {
    await _remoteDataSource.rejectJoinRequest(groupId, uid);
  }

  @override
  Future<void> updateGroupVisibility(String groupId, bool isPublic) async {
    await _remoteDataSource.updateGroupVisibility(groupId, isPublic);
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsersForInvite(String query) async {
    return await _remoteDataSource.searchUsersByName(query);
  }
}
