import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/domain/entities/friend_request_entity.dart';
import 'package:step_sync/features/friends/domain/entities/referral_contributor_entity.dart';
import 'package:step_sync/features/friends/domain/repositories/friends_repository.dart';

/// Provider for friends repository.
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepositoryImpl();
});

/// Provider for the user's friends list.
final friendsListProvider = FutureProvider<List<FriendEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.getFriendsList(user.uid);
});

/// Provider for pending incoming friend requests.
final pendingRequestsProvider = FutureProvider<List<FriendRequestEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.getPendingRequests(user.uid);
});

/// Provider for sent outgoing friend requests.
final sentRequestsProvider = FutureProvider<List<FriendRequestEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.getSentRequests(user.uid);
});

/// Provider for friends leaderboard.
final friendsLeaderboardProvider = FutureProvider<List<FriendEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.getFriendsLeaderboard(user.uid);
});

/// Provider for user search results.
final userSearchQueryProvider = StateProvider<String>((ref) => '');

final userSearchProvider = FutureProvider<List<FriendEntity>>((ref) async {
  final query = ref.watch(userSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.searchUsers(query, user.uid);
});

/// Provider for the current user's referral code.
final referralCodeProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return '';

  // If user already has a referral code, return it
  if (user.referralCode.isNotEmpty) return user.referralCode;

  // Otherwise generate one
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.generateReferralCode(user.uid);
});

/// Provider for the users who contributed to the referral bag.
final referralBagContributorsProvider = FutureProvider<List<ReferralContributorEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  final repo = ref.watch(friendsRepositoryProvider);
  return await repo.getReferralContributors(user.uid);
});

/// State notifier for friend actions (send/accept/reject/remove).
class FriendActionNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendsRepository _repository;

  FriendActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> sendRequest(String fromUid, String toUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendFriendRequest(fromUid, toUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptRequest(String fromUid, String toUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptFriendRequest(fromUid, toUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectRequest(String fromUid, String toUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.rejectFriendRequest(fromUid, toUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFriend(String uid, String friendUid) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFriend(uid, friendUid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> applyReferral(String uid, String code) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.applyReferralCode(uid, code);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final friendActionProvider =
    StateNotifierProvider<FriendActionNotifier, AsyncValue<void>>((ref) {
  return FriendActionNotifier(ref.watch(friendsRepositoryProvider));
});
