import 'package:flutter/foundation.dart';

@immutable
class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime timestamp;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.timestamp,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
