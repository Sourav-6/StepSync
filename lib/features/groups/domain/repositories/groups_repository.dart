import 'package:step_sync/features/groups/domain/entities/group_entity.dart';

abstract class GroupsRepository {
  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required String creatorUid,
  });

  Future<GroupEntity?> getGroup(String groupId);

  Future<void> updateGroup(GroupEntity group);

  Future<void> deleteGroup(String groupId);

  Future<List<GroupEntity>> getAllDiscoverableGroups();

  Future<List<GroupEntity>> getUserGroups(String uid);

  Future<void> joinPublicGroup(String groupId, String uid);

  Future<void> leaveGroup(String groupId, String uid);

  Future<void> inviteUserToGroup(String groupId, String targetUid);

  Future<void> acceptInvite(String groupId, String uid);

  Future<void> rejectInvite(String groupId, String uid);

  Future<void> promoteToAdmin(String groupId, String targetUid);

  Future<void> demoteAdmin(String groupId, String targetUid);

  Future<void> requestToJoinPrivateGroup(String groupId, String uid);

  Future<void> acceptJoinRequest(String groupId, String uid);

  Future<void> rejectJoinRequest(String groupId, String uid);

  Future<void> updateGroupVisibility(String groupId, bool isPublic);

  Future<List<Map<String, dynamic>>> searchUsersForInvite(String query);
}
