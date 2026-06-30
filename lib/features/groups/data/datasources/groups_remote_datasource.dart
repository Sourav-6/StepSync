import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/groups/data/models/group_model.dart';
import 'package:step_sync/core/services/cache_service.dart';

class GroupsRemoteDataSource {
  final FirebaseFirestore _firestore;

  GroupsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createGroup(GroupModel group) async {
    await _firestore
        .collection(FirestorePaths.groups)
        .doc(group.groupId)
        .set(group.toMap());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _firestore.collection(FirestorePaths.groups).doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }

  Future<void> updateGroup(GroupModel group) async {
    await _firestore
        .collection(FirestorePaths.groups)
        .doc(group.groupId)
        .update(group.toMap());
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).delete();
  }

  Future<List<GroupModel>> getAllDiscoverableGroups() async {
    const cacheKey = 'all_discoverable_groups';
    final cachedData = CacheService.getCache(cacheKey, const Duration(minutes: 5));
    if (cachedData != null) {
      return (cachedData as List).map((e) => GroupModel.fromCacheMap(Map<String, dynamic>.from(e))).toList();
    }

    // Return all groups. We'll filter in the UI to show public groups and private groups.
    final query = await _firestore
        .collection(FirestorePaths.groups)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final results = query.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
    
    // Save to cache
    CacheService.setCache(cacheKey, results.map((e) => e.toCacheMap()).toList());
    
    return results;
  }

  Future<List<GroupModel>> getUserGroups(String uid) async {
    final cacheKey = 'user_groups_$uid';
    final cachedData = CacheService.getCache(cacheKey, const Duration(minutes: 5));
    if (cachedData != null) {
      return (cachedData as List).map((e) => GroupModel.fromCacheMap(Map<String, dynamic>.from(e))).toList();
    }

    final query = await _firestore
        .collection(FirestorePaths.groups)
        .where('memberUids', arrayContains: uid)
        .get();

    final results = query.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
    
    // Save to cache
    CacheService.setCache(cacheKey, results.map((e) => e.toCacheMap()).toList());
    
    return results;
  }

  Future<void> joinPublicGroup(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'memberUids': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> leaveGroup(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'memberUids': FieldValue.arrayRemove([uid]),
      'adminUids': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> inviteUserToGroup(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'invitedUids': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> acceptInvite(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'invitedUids': FieldValue.arrayRemove([uid]),
      'memberUids': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> rejectInvite(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'invitedUids': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> promoteToAdmin(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'adminUids': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> demoteAdmin(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'adminUids': FieldValue.arrayRemove([uid])
    });
  }

  Future<void> requestToJoinPrivateGroup(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'pendingRequestUids': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> acceptJoinRequest(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'pendingRequestUids': FieldValue.arrayRemove([uid]),
      'memberUids': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> rejectJoinRequest(String groupId, String uid) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'pendingRequestUids': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> updateGroupVisibility(String groupId, bool isPublic) async {
    await _firestore.collection(FirestorePaths.groups).doc(groupId).update({
      'isPublic': isPublic,
    });
  }

  /// Search users by name for group invitation.
  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    if (query.trim().isEmpty) return [];

    final queryResult = await _firestore
        .collection(FirestorePaths.users)
        .orderBy(FirestorePaths.fieldName)
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return queryResult.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': data[FirestorePaths.fieldName] ?? '',
        'profileImage': data[FirestorePaths.fieldProfileImage] ?? '',
      };
    }).toList();
  }
}
