import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/core/utils/formatters.dart';

class GroupMemberStepData {
  final String uid;
  final String name;
  final String profileImage;
  final int todaySteps;
  final int dailyGoal;

  GroupMemberStepData({
    required this.uid,
    required this.name,
    this.profileImage = '',
    this.todaySteps = 0,
    this.dailyGoal = 10000,
  });
}

final groupMembersStepsProvider = FutureProvider.family<List<GroupMemberStepData>, List<String>>((ref, memberUids) async {
  if (memberUids.isEmpty) return [];

  final firestore = FirebaseFirestore.instance;
  final today = Formatters.formatDateKey(DateTime.now());
  
  List<GroupMemberStepData> memberData = [];

  for (final uid in memberUids) {
    try {
      // 1. Fetch user profile
      final userDoc = await firestore.collection(FirestorePaths.users).doc(uid).get();
      if (!userDoc.exists) continue;
      
      final userData = userDoc.data()!;
      final name = userData[FirestorePaths.fieldName] as String? ?? 'User';
      final profileImage = userData[FirestorePaths.fieldProfileImage] as String? ?? '';
      final dailyGoal = userData[FirestorePaths.fieldDailyGoal] as int? ?? 10000;

      // 2. Fetch today's steps for this user
      final dailyStepDocId = FirestorePaths.dailyStepDocId(uid, today);
      final stepDoc = await firestore.collection(FirestorePaths.dailySteps).doc(dailyStepDocId).get();
      
      int todaySteps = 0;
      if (stepDoc.exists) {
        todaySteps = stepDoc.data()?[FirestorePaths.fieldSteps] as int? ?? 0;
      }

      memberData.add(GroupMemberStepData(
        uid: uid,
        name: name,
        profileImage: profileImage,
        todaySteps: todaySteps,
        dailyGoal: dailyGoal,
      ));
    } catch (e) {
      // Ignore errors for individual users so the rest of the list loads
      continue;
    }
  }

  // Sort by steps descending
  memberData.sort((a, b) => b.todaySteps.compareTo(a.todaySteps));

  return memberData;
});
