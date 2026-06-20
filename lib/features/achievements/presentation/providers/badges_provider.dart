import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/achievements/domain/entities/achievement_badge.dart';
import 'package:step_sync/core/constants/app_colors.dart';

final individualBadgesProvider = Provider<List<AchievementBadge>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];

  return [
    AchievementBadge(
      id: 'first_step',
      title: 'First Step',
      description: 'Took your first steps.',
      icon: Icons.directions_walk_rounded,
      color: AppColors.primaryBlue,
      isUnlocked: user.totalSteps > 0,
    ),
    AchievementBadge(
      id: '10k_club',
      title: '10k Club',
      description: 'Hit 10,000 steps in a day.',
      icon: Icons.speed_rounded,
      color: AppColors.successGreen,
      isUnlocked: user.totalSteps >= 10000, 
    ),
    AchievementBadge(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Achieved a 7-day streak.',
      icon: Icons.whatshot_rounded,
      color: AppColors.errorRed,
      isUnlocked: user.longestStreak >= 7,
    ),
    AchievementBadge(
      id: 'consistency_king',
      title: 'Consistency King',
      description: 'Maintained a 5-star consistency rating.',
      icon: Icons.star_rounded,
      color: AppColors.warningYellow,
      isUnlocked: user.consistencyScore >= 0.9,
    ),
    AchievementBadge(
      id: 'marathoner',
      title: 'Marathoner',
      description: 'Surpassed 50,000 total steps.',
      icon: Icons.emoji_events_rounded,
      color: AppColors.goldBadge,
      isUnlocked: user.totalSteps >= 50000,
    ),
  ];
});

final groupBadgesProvider = Provider.family<List<AchievementBadge>, GroupEntity>((ref, group) {
  return [
    AchievementBadge(
      id: 'squad_assembly',
      title: 'Squad Assembly',
      description: 'Group reached 5 members.',
      icon: Icons.groups_rounded,
      color: AppColors.primaryBlue,
      isUnlocked: group.memberUids.length >= 5,
    ),
    AchievementBadge(
      id: 'group_100k',
      title: '100k Steps Together',
      description: 'Group surpassed 100,000 total steps.',
      icon: Icons.route_rounded,
      color: AppColors.secondaryTeal,
      isUnlocked: group.totalSteps >= 100000,
    ),
    AchievementBadge(
      id: 'million_steps',
      title: '1 Million Steps',
      description: 'Group surpassed 1,000,000 total steps.',
      icon: Icons.emoji_events_rounded,
      color: AppColors.goldBadge,
      isUnlocked: group.totalSteps >= 1000000,
    ),
  ];
});
