import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/domain/entities/friend_request_entity.dart';

/// Firestore data source for friends system operations.
class FriendsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FriendsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Send a friend request: add toUid to sender's sent list,
  /// and fromUid to receiver's received list.
  Future<void> sendFriendRequest(String fromUid, String toUid) async {
    final batch = _firestore.batch();

    final fromRef = _firestore.collection(FirestorePaths.users).doc(fromUid);
    final toRef = _firestore.collection(FirestorePaths.users).doc(toUid);

    batch.update(fromRef, {
      FirestorePaths.fieldFriendRequestsSent: FieldValue.arrayUnion([toUid]),
    });
    batch.update(toRef, {
      FirestorePaths.fieldFriendRequestsReceived: FieldValue.arrayUnion([fromUid]),
    });

    await batch.commit();
  }

  /// Accept a friend request: move from requests to friends for both users.
  Future<void> acceptFriendRequest(String fromUid, String toUid) async {
    final batch = _firestore.batch();

    final fromRef = _firestore.collection(FirestorePaths.users).doc(fromUid);
    final toRef = _firestore.collection(FirestorePaths.users).doc(toUid);

    // Remove from request lists
    batch.update(fromRef, {
      FirestorePaths.fieldFriendRequestsSent: FieldValue.arrayRemove([toUid]),
      FirestorePaths.fieldFriendUids: FieldValue.arrayUnion([toUid]),
    });
    batch.update(toRef, {
      FirestorePaths.fieldFriendRequestsReceived: FieldValue.arrayRemove([fromUid]),
      FirestorePaths.fieldFriendUids: FieldValue.arrayUnion([fromUid]),
    });

    await batch.commit();
  }

  /// Reject a friend request: remove from both request lists.
  Future<void> rejectFriendRequest(String fromUid, String toUid) async {
    final batch = _firestore.batch();

    final fromRef = _firestore.collection(FirestorePaths.users).doc(fromUid);
    final toRef = _firestore.collection(FirestorePaths.users).doc(toUid);

    batch.update(fromRef, {
      FirestorePaths.fieldFriendRequestsSent: FieldValue.arrayRemove([toUid]),
    });
    batch.update(toRef, {
      FirestorePaths.fieldFriendRequestsReceived: FieldValue.arrayRemove([fromUid]),
    });

    await batch.commit();
  }

  /// Remove a friend from both users' friend lists.
  Future<void> removeFriend(String uid, String friendUid) async {
    final batch = _firestore.batch();

    final userRef = _firestore.collection(FirestorePaths.users).doc(uid);
    final friendRef = _firestore.collection(FirestorePaths.users).doc(friendUid);

    batch.update(userRef, {
      FirestorePaths.fieldFriendUids: FieldValue.arrayRemove([friendUid]),
    });
    batch.update(friendRef, {
      FirestorePaths.fieldFriendUids: FieldValue.arrayRemove([uid]),
    });

    await batch.commit();
  }

  /// Fetch the friends list with user details.
  Future<List<FriendEntity>> getFriendsList(String uid) async {
    final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!userDoc.exists) return [];

    final friendUids = List<String>.from(
      userDoc.data()?[FirestorePaths.fieldFriendUids] ?? [],
    );

    if (friendUids.isEmpty) return [];

    return _fetchUserEntities(friendUids, isFriend: true);
  }

  /// Get incoming friend requests with sender details.
  Future<List<FriendRequestEntity>> getPendingRequests(String uid) async {
    final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!userDoc.exists) return [];

    final requestUids = List<String>.from(
      userDoc.data()?[FirestorePaths.fieldFriendRequestsReceived] ?? [],
    );

    if (requestUids.isEmpty) return [];

    final List<FriendRequestEntity> requests = [];
    for (final fromUid in requestUids) {
      final fromDoc = await _firestore.collection(FirestorePaths.users).doc(fromUid).get();
      if (!fromDoc.exists) continue;

      final data = fromDoc.data()!;
      requests.add(FriendRequestEntity(
        fromUid: fromUid,
        toUid: uid,
        fromName: data[FirestorePaths.fieldName] ?? '',
        fromProfileImage: data[FirestorePaths.fieldProfileImage] ?? '',
        timestamp: DateTime.now(),
      ));
    }

    return requests;
  }

  /// Get sent friend requests with receiver details.
  Future<List<FriendRequestEntity>> getSentRequests(String uid) async {
    final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!userDoc.exists) return [];

    final sentUids = List<String>.from(
      userDoc.data()?[FirestorePaths.fieldFriendRequestsSent] ?? [],
    );

    if (sentUids.isEmpty) return [];

    final List<FriendRequestEntity> requests = [];
    for (final toUid in sentUids) {
      final toDoc = await _firestore.collection(FirestorePaths.users).doc(toUid).get();
      if (!toDoc.exists) continue;

      final data = toDoc.data()!;
      requests.add(FriendRequestEntity(
        fromUid: uid,
        toUid: toUid,
        toName: data[FirestorePaths.fieldName] ?? '',
        toProfileImage: data[FirestorePaths.fieldProfileImage] ?? '',
        timestamp: DateTime.now(),
      ));
    }

    return requests;
  }

  /// Search users by name (case-insensitive prefix search).
  Future<List<FriendEntity>> searchUsers(String query, String currentUid) async {
    if (query.trim().isEmpty) return [];

    // Firestore doesn't support case-insensitive search natively.
    // We use a range query on the name field for prefix matching.
    final lowerQuery = query.toLowerCase();
    final upperBound = '${lowerQuery.substring(0, lowerQuery.length - 1)}${String.fromCharCode(lowerQuery.codeUnitAt(lowerQuery.length - 1) + 1)}';

    final queryResult = await _firestore
        .collection(FirestorePaths.users)
        .orderBy(FirestorePaths.fieldName)
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    // Get current user's data to check friend/request status
    final currentUserDoc = await _firestore.collection(FirestorePaths.users).doc(currentUid).get();
    final currentUserData = currentUserDoc.data() ?? {};
    final friendUids = List<String>.from(currentUserData[FirestorePaths.fieldFriendUids] ?? []);
    final sentRequests = List<String>.from(currentUserData[FirestorePaths.fieldFriendRequestsSent] ?? []);
    final receivedRequests = List<String>.from(currentUserData[FirestorePaths.fieldFriendRequestsReceived] ?? []);

    return queryResult.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) {
      final data = doc.data();
      return FriendEntity(
        uid: doc.id,
        name: data[FirestorePaths.fieldName] ?? '',
        profileImage: data[FirestorePaths.fieldProfileImage] ?? '',
        totalSteps: data[FirestorePaths.fieldTotalSteps] ?? 0,
        consistencyScore: (data[FirestorePaths.fieldConsistencyScore] as num?)?.toDouble() ?? 0.0,
        currentStreak: data[FirestorePaths.fieldCurrentStreak] ?? 0,
        isFriend: friendUids.contains(doc.id),
        requestPending: sentRequests.contains(doc.id),
        requestReceived: receivedRequests.contains(doc.id),
      );
    }).toList();
  }

  /// Get friends leaderboard sorted by consistency score.
  Future<List<FriendEntity>> getFriendsLeaderboard(String uid) async {
    final friends = await getFriendsList(uid);

    // Also include the current user
    final userDoc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      friends.add(FriendEntity(
        uid: uid,
        name: data[FirestorePaths.fieldName] ?? '',
        profileImage: data[FirestorePaths.fieldProfileImage] ?? '',
        totalSteps: data[FirestorePaths.fieldTotalSteps] ?? 0,
        consistencyScore: (data[FirestorePaths.fieldConsistencyScore] as num?)?.toDouble() ?? 0.0,
        currentStreak: data[FirestorePaths.fieldCurrentStreak] ?? 0,
        isFriend: true,
      ));
    }

    // Sort by consistency score descending
    friends.sort((a, b) => b.consistencyScore.compareTo(a.consistencyScore));
    return friends;
  }

  /// Generate a referral code from uid (first 8 chars uppercase).
  Future<String> generateReferralCode(String uid) async {
    final code = uid.substring(0, 8).toUpperCase();

    // Save to user doc
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      FirestorePaths.fieldReferralCode: code,
    });

    return code;
  }

  /// Apply a referral code — find user with that code and set referredBy.
  Future<bool> applyReferralCode(String uid, String code) async {
    // Find user with this referral code
    final query = await _firestore
        .collection(FirestorePaths.users)
        .where(FirestorePaths.fieldReferralCode, isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final referrerUid = query.docs.first.id;
    if (referrerUid == uid) return false; // Can't refer yourself

    // Set referredBy on current user
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      FirestorePaths.fieldReferredBy: referrerUid,
    });

    // Also add each other as friends automatically
    await acceptFriendRequest(referrerUid, uid);

    return true;
  }

  /// Helper: fetch user entities from a list of UIDs.
  Future<List<FriendEntity>> _fetchUserEntities(
    List<String> uids, {
    bool isFriend = false,
  }) async {
    final List<FriendEntity> entities = [];

    for (final uid in uids) {
      try {
        final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
        if (!doc.exists) continue;

        final data = doc.data()!;
        entities.add(FriendEntity(
          uid: uid,
          name: data[FirestorePaths.fieldName] ?? '',
          profileImage: data[FirestorePaths.fieldProfileImage] ?? '',
          totalSteps: data[FirestorePaths.fieldTotalSteps] ?? 0,
          consistencyScore: (data[FirestorePaths.fieldConsistencyScore] as num?)?.toDouble() ?? 0.0,
          starRating: (data[FirestorePaths.fieldStarRating] as num?)?.toDouble() ?? 0.0,
          currentStreak: data[FirestorePaths.fieldCurrentStreak] ?? 0,
          isFriend: isFriend,
        ));
      } catch (_) {
        continue;
      }
    }

    return entities;
  }

  /// Get the list of users who have contributed stars to the current user's referral bag.
  Future<List<Map<String, dynamic>>> getReferralContributors(String uid) async {
    final querySnapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('referral_stars_given')
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    List<Map<String, dynamic>> contributors = [];

    // Need to fetch user details for each contributor
    final userIds = querySnapshot.docs.map((d) => d.id).toList();

    for (var i = 0; i < userIds.length; i += 10) {
      final chunk = userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10);
      final usersQuery = await _firestore
          .collection(FirestorePaths.users)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final userDoc in usersQuery.docs) {
        final userId = userDoc.id;
        final referralDoc = querySnapshot.docs.firstWhere((d) => d.id == userId);
        final starsGiven = (referralDoc.data()[FirestorePaths.fieldStarsGivenCount] as int?) ?? 0;
        final lastUpdated = (referralDoc.data()['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now();

        contributors.add({
          'uid': userId,
          'name': userDoc.data()[FirestorePaths.fieldName] ?? 'Unknown User',
          'profileImage': userDoc.data()[FirestorePaths.fieldProfileImage] ?? '',
          'starsGiven': starsGiven,
          'lastUpdated': lastUpdated,
        });
      }
    }

    return contributors;
  }
}
