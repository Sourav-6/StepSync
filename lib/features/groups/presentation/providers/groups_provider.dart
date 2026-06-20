import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/groups/domain/repositories/groups_repository.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepositoryImpl();
});

final discoverGroupsProvider = FutureProvider<List<GroupEntity>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  return await repo.getAllDiscoverableGroups();
});

final userGroupsProvider = FutureProvider<List<GroupEntity>>((ref) async {
  final repo = ref.watch(groupsRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return await repo.getUserGroups(user.uid);
});

final groupDetailsProvider = FutureProvider.family<GroupEntity?, String>((ref, groupId) async {
  final repo = ref.watch(groupsRepositoryProvider);
  return await repo.getGroup(groupId);
});

class GroupActionNotifier extends StateNotifier<AsyncValue<void>> {
  final GroupsRepository _repository;

  GroupActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required String creatorUid,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createGroup(
        name: name,
        description: description,
        isPublic: isPublic,
        creatorUid: creatorUid,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinPublicGroup(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.joinPublicGroup(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> leaveGroup(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.leaveGroup(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> inviteUser(String groupId, String targetUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.inviteUserToGroup(groupId, targetUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptInvite(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptInvite(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> promoteToAdmin(String groupId, String targetUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.promoteToAdmin(groupId, targetUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> demoteAdmin(String groupId, String targetUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.demoteAdmin(groupId, targetUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> requestToJoinPrivateGroup(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.requestToJoinPrivateGroup(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptJoinRequest(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptJoinRequest(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectJoinRequest(String groupId, String uid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.rejectJoinRequest(groupId, uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGroupVisibility(String groupId, bool isPublic) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateGroupVisibility(groupId, isPublic);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final groupActionProvider = StateNotifierProvider<GroupActionNotifier, AsyncValue<void>>((ref) {
  return GroupActionNotifier(ref.watch(groupsRepositoryProvider));
});
