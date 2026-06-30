import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.isRead = false,
    required super.timestamp,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return NotificationModel(
        id: doc.id,
        title: '',
        body: '',
        type: 'system',
        timestamp: DateTime.now(),
      );
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      isRead: data['isRead'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
