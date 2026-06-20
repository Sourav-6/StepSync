import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.groupId,
    required super.name,
    required super.description,
    required super.isPublic,
    required super.adminUids,
    required super.memberUids,
    super.invitedUids = const [],
    super.pendingRequestUids = const [],
    super.totalSteps = 0,
    required super.createdAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      groupId: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isPublic: data['isPublic'] as bool? ?? true,
      adminUids: List<String>.from(data['adminUids'] ?? []),
      memberUids: List<String>.from(data['memberUids'] ?? []),
      invitedUids: List<String>.from(data['invitedUids'] ?? []),
      pendingRequestUids: List<String>.from(data['pendingRequestUids'] ?? []),
      totalSteps: data['totalSteps'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'adminUids': adminUids,
      'memberUids': memberUids,
      'invitedUids': invitedUids,
      'pendingRequestUids': pendingRequestUids,
      'totalSteps': totalSteps,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      groupId: entity.groupId,
      name: entity.name,
      description: entity.description,
      isPublic: entity.isPublic,
      adminUids: entity.adminUids,
      memberUids: entity.memberUids,
      invitedUids: entity.invitedUids,
      pendingRequestUids: entity.pendingRequestUids,
      totalSteps: entity.totalSteps,
      createdAt: entity.createdAt,
    );
  }
}
