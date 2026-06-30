import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/notifications/data/models/notification_model.dart';
import 'package:step_sync/features/notifications/domain/entities/notification_entity.dart';

final notificationsProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection(FirestorePaths.users)
      .doc(user.uid)
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
  });
});

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

final markNotificationReadProvider = Provider.autoDispose((ref) {
  return (String notificationId) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  };
});
