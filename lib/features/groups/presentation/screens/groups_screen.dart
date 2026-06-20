import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:step_sync/features/groups/presentation/providers/groups_provider.dart';
import 'package:step_sync/features/groups/domain/entities/group_entity.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/groups/presentation/screens/group_details_screen.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              SwitchListTile(
                title: const Text('Public Group'),
                value: isPublic,
                onChanged: (val) => setState(() => isPublic = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(currentUserProvider).value;
                if (user != null && nameController.text.isNotEmpty) {
                  ref.read(groupActionProvider.notifier).createGroup(
                        name: nameController.text,
                        description: descController.text,
                        isPublic: isPublic,
                        creatorUid: user.uid,
                      );
                  ref.refresh(userGroupsProvider);
                  ref.refresh(discoverGroupsProvider);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoverGroupsAsync = ref.watch(discoverGroupsProvider);
    final userGroupsAsync = ref.watch(userGroupsProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Discover'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGroupDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Groups Tab
          userGroupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (groups) => _buildGroupList(groups, isMyGroups: true),
          ),
          // Discover Tab
          discoverGroupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (groups) {
              final user = ref.read(currentUserProvider).value;
              // Filter out groups the user is already a member of
              final discoverableGroups = groups.where((g) => user == null || !g.memberUids.contains(user.uid)).toList();
              return _buildGroupList(discoverableGroups, isMyGroups: false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(List<GroupEntity> groups, {required bool isMyGroups}) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups found.'));
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final user = ref.read(currentUserProvider).value;
        final hasRequested = user != null && group.pendingRequestUids.contains(user.uid);

        Widget trailingWidget;
        if (isMyGroups) {
          trailingWidget = const Icon(Icons.chevron_right);
        } else if (hasRequested) {
          trailingWidget = const OutlinedButton(
            onPressed: null,
            child: Text('Requested'),
          );
        } else {
          trailingWidget = ElevatedButton(
            onPressed: () {
              if (user != null) {
                if (group.isPublic) {
                  ref.read(groupActionProvider.notifier).joinPublicGroup(group.groupId, user.uid);
                } else {
                  ref.read(groupActionProvider.notifier).requestToJoinPrivateGroup(group.groupId, user.uid);
                }
                // Refresh both lists
                ref.refresh(userGroupsProvider);
                ref.refresh(discoverGroupsProvider);
              }
            },
            child: Text(group.isPublic ? 'Join' : 'Request to Join'),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(group.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('${group.memberUids.length} members • ${group.isPublic ? 'Public' : 'Private'}'),
            trailing: trailingWidget,
            onTap: isMyGroups
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailsScreen(group: group),
                      ),
                    );
                  }
                : null,
          ),
        );
      },
    );
  }
}
