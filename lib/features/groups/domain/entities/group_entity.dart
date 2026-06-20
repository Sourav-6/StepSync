import 'package:flutter/foundation.dart';

@immutable
class GroupEntity {
  final String groupId;
  final String name;
  final String description;
  final bool isPublic;
  final List<String> adminUids;
  final List<String> memberUids;
  final List<String> invitedUids;
  final List<String> pendingRequestUids; // Users who requested to join (private groups)
  final int totalSteps;
  final DateTime createdAt;

  const GroupEntity({
    required this.groupId,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.adminUids,
    required this.memberUids,
    this.invitedUids = const [],
    this.pendingRequestUids = const [],
    this.totalSteps = 0,
    required this.createdAt,
  });

  GroupEntity copyWith({
    String? groupId,
    String? name,
    String? description,
    bool? isPublic,
    List<String>? adminUids,
    List<String>? memberUids,
    List<String>? invitedUids,
    List<String>? pendingRequestUids,
    int? totalSteps,
    DateTime? createdAt,
  }) {
    return GroupEntity(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      adminUids: adminUids ?? this.adminUids,
      memberUids: memberUids ?? this.memberUids,
      invitedUids: invitedUids ?? this.invitedUids,
      pendingRequestUids: pendingRequestUids ?? this.pendingRequestUids,
      totalSteps: totalSteps ?? this.totalSteps,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupEntity && other.groupId == groupId;
  }

  @override
  int get hashCode => groupId.hashCode;
}
