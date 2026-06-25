import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/domain/entities/friend_request_entity.dart';
import 'package:step_sync/features/friends/presentation/providers/friends_provider.dart';

/// Friends screen with tabs: Friends, Requests, Find.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.friends,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => context.push('/friends/invite'),
            tooltip: AppStrings.inviteFriends,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: isDark
              ? AppColors.textDarkSecondary
              : AppColors.textLightSecondary,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: AppStrings.friends),
            Tab(text: 'Requests'),
            Tab(text: 'Find'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(),
          _buildRequestsTab(),
          _buildFindTab(),
        ],
      ),
    );
  }

  // ─── Friends Tab ───
  Widget _buildFriendsTab() {
    final friendsAsync = ref.watch(friendsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (friends) {
        if (friends.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline_rounded,
            message: AppStrings.noFriendsYet,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(friendsListProvider.future),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: friends.length + 1, // +1 for leaderboard button
            itemBuilder: (context, index) {
              if (index == 0) {
                // Friends Leaderboard banner
                return GestureDetector(
                  onTap: () => context.push('/friends/leaderboard'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.tealGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryTeal.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.friendsLeaderboard,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'See how you rank among friends',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
              }

              final friend = friends[index - 1];
              return _buildFriendTile(friend, index - 1)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideX(begin: 0.03);
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendTile(FriendEntity friend, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(currentUserProvider).value;

    return Dismissible(
      key: ValueKey(friend.uid),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.person_remove_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Friend'),
            content: Text('Remove ${friend.name} from your friends?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        if (user != null) {
          ref.read(friendActionProvider.notifier).removeFriend(user.uid, friend.uid);
          ref.refresh(friendsListProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.2)
                : AppColors.lightBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(friend.name, friend.profileImage, 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.formatNumber(friend.totalSteps)} total steps • 🔥 ${friend.currentStreak} day streak',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 16, color: AppColors.warningYellow),
                const SizedBox(width: 4),
                Text(
                  friend.starRating.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Requests Tab ───
  Widget _buildRequestsTab() {
    final pendingAsync = ref.watch(pendingRequestsProvider);
    final sentAsync = ref.watch(sentRequestsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Received requests
          Text(
            AppStrings.receivedRequests,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (requests) {
              if (requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildEmptyState(
                    icon: Icons.inbox_rounded,
                    message: AppStrings.noPendingRequests,
                    compact: true,
                  ),
                );
              }
              return Column(
                children: requests.asMap().entries.map((entry) {
                  return _buildReceivedRequestTile(entry.value)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * entry.key))
                      .slideX(begin: 0.03);
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Sent requests
          Text(
            AppStrings.sentRequests,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          sentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (requests) {
              if (requests.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.send_rounded,
                  message: 'No sent requests.',
                  compact: true,
                );
              }
              return Column(
                children: requests.asMap().entries.map((entry) {
                  return _buildSentRequestTile(entry.value)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * entry.key))
                      .slideX(begin: 0.03);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestTile(FriendRequestEntity request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(currentUserProvider).value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(request.fromName, request.fromProfileImage, 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fromName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                Text(
                  'Wants to be your friend',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                Icons.check_rounded,
                AppColors.successGreen,
                () {
                  if (user != null) {
                    ref.read(friendActionProvider.notifier)
                        .acceptRequest(request.fromUid, user.uid);
                    ref.refresh(pendingRequestsProvider);
                    ref.refresh(friendsListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.friendRequestAccepted)),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.close_rounded,
                AppColors.errorRed,
                () {
                  if (user != null) {
                    ref.read(friendActionProvider.notifier)
                        .rejectRequest(request.fromUid, user.uid);
                    ref.refresh(pendingRequestsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.friendRequestRejected)),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentRequestTile(FriendRequestEntity request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.2)
              : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(request.toName, request.toProfileImage, 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.toName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                Text(
                  'Request sent',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warningYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppStrings.pending,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warningYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Find Tab ───
  Widget _buildFindTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchResults = ref.watch(userSearchProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.3)
                    : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(userSearchQueryProvider.notifier).state = value;
              },
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchUsers,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        // Search results
        Expanded(
          child: searchResults.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (users) {
              if (_searchController.text.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  message: 'Search for users by name',
                );
              }

              if (users.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.person_off_rounded,
                  message: 'No users found',
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildSearchResultTile(user)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .slideX(begin: 0.03);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultTile(FriendEntity user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.read(currentUserProvider).value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.2)
              : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(user.name, user.profileImage, 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '🔥 ${user.currentStreak} day streak',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildFriendshipButton(user, currentUser?.uid),
        ],
      ),
    );
  }

  Widget _buildFriendshipButton(FriendEntity user, String? currentUid) {
    if (user.isFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Friends',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.successGreen,
          ),
        ),
      );
    }

    if (user.requestPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warningYellow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          AppStrings.pending,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.warningYellow,
          ),
        ),
      );
    }

    if (user.requestReceived) {
      return GestureDetector(
        onTap: () {
          if (currentUid != null) {
            ref.read(friendActionProvider.notifier).acceptRequest(user.uid, currentUid);
            ref.refresh(userSearchProvider);
            ref.refresh(friendsListProvider);
            ref.refresh(pendingRequestsProvider);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.successGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppStrings.accept,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (currentUid != null) {
          ref.read(friendActionProvider.notifier).sendRequest(currentUid, user.uid);
          ref.refresh(userSearchProvider);
          ref.refresh(sentRequestsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.friendRequestSent)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          AppStrings.addFriend,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─── Shared Widgets ───

  Widget _buildAvatar(String name, String imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(name),
              ),
            )
          : _buildInitials(name),
    );
  }

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }


  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    bool compact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 24 : 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 48 : 64,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
