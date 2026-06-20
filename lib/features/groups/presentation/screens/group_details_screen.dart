import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/groups/presentation/providers/groups_provider.dart';
import 'package:step_sync/features/groups/presentation/providers/group_members_steps_provider.dart';
import 'package:step_sync/features/achievements/presentation/providers/badges_provider.dart';
import 'package:step_sync/features/achievements/presentation/widgets/achievements_grid.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/core/utils/formatters.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final GroupEntity group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  late bool isPublic;

  @override
  void initState() {
    super.initState();
    isPublic = widget.group.isPublic;
  }

  void _inviteUser() {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite to Group',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Share link button
                      GestureDetector(
                        onTap: () {
                          final link = 'https://stepsync.app/group/${widget.group.groupId}';
                          Share.share('Join my group "${widget.group.name}" on SRP Health! $link');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Share Invite Link',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.3) : AppColors.lightBorder,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search users by name...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 15,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                            suffixIcon: isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (value) async {
                            if (value.trim().length < 2) {
                              setState(() => searchResults = []);
                              return;
                            }
                            setState(() => isSearching = true);
                            try {
                              final repo = ref.read(groupsRepositoryProvider);
                              final results = await repo.searchUsersForInvite(value.trim());
                              // Filter out existing members
                              final groupAsync = ref.read(groupDetailsProvider(widget.group.groupId));
                              final group = groupAsync.valueOrNull;
                              final memberUids = group?.memberUids ?? widget.group.memberUids;
                              setState(() {
                                searchResults = results.where((r) => !memberUids.contains(r['uid'])).toList();
                                isSearching = false;
                              });
                            } catch (_) {
                              setState(() => isSearching = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Search results
                Expanded(
                  child: searchResults.isEmpty
                      ? Center(
                          child: Text(
                            searchController.text.isEmpty
                                ? 'Search for users to invite'
                                : 'No users found',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            final isInvited = widget.group.invitedUids.contains(user['uid']);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder.withValues(alpha: 0.2)
                                      : AppColors.lightBorder.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: (user['profileImage'] as String).isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              user['profileImage'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Text(
                                                  (user['name'] as String).isNotEmpty
                                                      ? (user['name'] as String)[0].toUpperCase()
                                                      : 'U',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              (user['name'] as String).isNotEmpty
                                                  ? (user['name'] as String)[0].toUpperCase()
                                                  : 'U',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user['name'] ?? '',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isInvited
                                        ? null
                                        : () {
                                            ref.read(groupActionProvider.notifier).inviteUser(
                                                  widget.group.groupId,
                                                  user['uid'],
                                                );
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Invite sent to ${user['name']}')),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isInvited ? null : AppColors.primaryGradient,
                                        color: isInvited ? AppColors.darkBorder.withValues(alpha: 0.2) : null,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isInvited ? 'Invited' : 'Invite',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isInvited
                                              ? (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Refresh group details to get latest members
    final groupAsync = ref.watch(groupDetailsProvider(widget.group.groupId));
    final user = ref.watch(currentUserProvider).value;

    return groupAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (group) {
        if (group == null) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }

        final isAdmin = user != null && group.adminUids.contains(user.uid);
        final isMember = user != null && group.memberUids.contains(user.uid);

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _inviteUser,
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Description',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(group.description),
              const SizedBox(height: 24),
              if (isAdmin) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visibility: ${isPublic ? 'Public' : 'Private'}',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isPublic,
                      onChanged: (val) async {
                        setState(() => isPublic = val);
                        await ref.read(groupActionProvider.notifier).updateGroupVisibility(group.groupId, val);
                        ref.refresh(groupDetailsProvider(group.groupId));
                        // For now, we show a snackbar.
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Group is now ${val ? 'Public' : 'Private'}')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (isAdmin && group.pendingRequestUids.isNotEmpty) ...[
                Text(
                  'Pending Requests (${group.pendingRequestUids.length})',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                ...group.pendingRequestUids.map((requestUid) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text('User $requestUid'),
                    subtitle: const Text('Requested to join'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'Accept',
                          onPressed: () async {
                            await ref.read(groupActionProvider.notifier).acceptJoinRequest(group.groupId, requestUid);
                            ref.refresh(groupDetailsProvider(group.groupId));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Reject',
                          onPressed: () async {
                            await ref.read(groupActionProvider.notifier).rejectJoinRequest(group.groupId, requestUid);
                            ref.refresh(groupDetailsProvider(group.groupId));
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
              
              // ─── Group Achievements Section ───
              Consumer(
                builder: (context, ref, child) {
                  final badges = ref.watch(groupBadgesProvider(group));
                  if (badges.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      AchievementsGrid(badges: badges, title: 'Group Achievements'),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              
              Text(
                'Members (${group.memberUids.length})',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ref.watch(groupMembersStepsProvider(group.memberUids)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading members: $e')),
                data: (membersData) {
                  if (membersData.isEmpty) {
                    return const Text('No members found.');
                  }
                  
                  return Column(
                    children: membersData.map((memberData) {
                      final isMemberAdmin = group.adminUids.contains(memberData.uid);
                      final isCurrentUser = memberData.uid == user?.uid;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: memberData.profileImage.isNotEmpty 
                              ? NetworkImage(memberData.profileImage) 
                              : null,
                          child: memberData.profileImage.isEmpty ? Text(memberData.name[0].toUpperCase()) : null,
                        ),
                        title: Text(isCurrentUser ? '${memberData.name} (You)' : memberData.name),
                        subtitle: Text(
                          '${isMemberAdmin ? 'Admin' : 'Member'} • ${Formatters.formatNumber(memberData.todaySteps)} / ${Formatters.formatNumber(memberData.dailyGoal)} steps today'
                        ),
                        trailing: (isAdmin && !isCurrentUser)
                            ? IconButton(
                                icon: Icon(
                                  isMemberAdmin ? Icons.remove_moderator : Icons.admin_panel_settings,
                                  color: isMemberAdmin ? Colors.red : null,
                                ),
                                tooltip: isMemberAdmin ? 'Remove Admin' : 'Make Admin',
                                onPressed: () {
                                  if (isMemberAdmin) {
                                    ref.read(groupActionProvider.notifier).demoteAdmin(
                                          group.groupId,
                                          memberData.uid,
                                        );
                                  } else {
                                    ref.read(groupActionProvider.notifier).promoteToAdmin(
                                          group.groupId,
                                          memberData.uid,
                                        );
                                  }
                                  ref.refresh(groupDetailsProvider(group.groupId));
                                },
                              )
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (isMember)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    if (user != null) {
                      ref.read(groupActionProvider.notifier).leaveGroup(group.groupId, user.uid);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Leave Group', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        );
      },
    );
  }
}
