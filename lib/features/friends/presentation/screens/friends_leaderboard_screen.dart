import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/golden_star_badge.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/friends/domain/entities/friend_entity.dart';
import 'package:step_sync/features/friends/presentation/providers/friends_provider.dart';

/// Friends-only leaderboard with podium-style top 3 display.
class FriendsLeaderboardScreen extends ConsumerWidget {
  const FriendsLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leaderboardAsync = ref.watch(friendsLeaderboardProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.friendsLeaderboard,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (friends) {
          if (friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add friends to see your leaderboard!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(friendsLeaderboardProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                // Podium for top 3
                if (friends.length >= 3) ...[
                  _buildPodium(context, friends.take(3).toList(), currentUser?.uid),
                  const SizedBox(height: 24),
                ],

                // Remaining entries
                ...friends.asMap().entries.map((entry) {
                  final index = entry.key;
                  final friend = entry.value;
                  final isCurrentUser = friend.uid == currentUser?.uid;

                  return _buildLeaderboardTile(
                    context,
                    friend,
                    index + 1,
                    isCurrentUser,
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .slideX(begin: 0.03);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<FriendEntity> top3, String? currentUid) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _buildPodiumEntry(context, top3[1], 2, currentUid)),
          const SizedBox(width: 8),
          // 1st place
          Expanded(child: _buildPodiumEntry(context, top3[0], 1, currentUid)),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(child: _buildPodiumEntry(context, top3[2], 3, currentUid)),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildPodiumEntry(
    BuildContext context,
    FriendEntity friend,
    int rank,
    String? currentUid,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentUser = friend.uid == currentUid;
    final color = _getRankColor(rank);
    final height = rank == 1 ? 160.0 : rank == 2 ? 130.0 : 110.0;
    final emoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Container(
          width: rank == 1 ? 56 : 48,
          height: rank == 1 ? 56 : 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: isCurrentUser
                ? Border.all(color: AppColors.primaryBlue, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: friend.profileImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    friend.profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(
                          fontSize: rank == 1 ? 22 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.outfit(
                      fontSize: rank == 1 ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          isCurrentUser ? 'You' : friend.name.split(' ').first,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),

        // Pedestal
        Container(
          height: height - 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: rank == 1 ? 28 : 22)),
                const SizedBox(height: 2),
                Text(
                  '${friend.starRating.toStringAsFixed(1)}★',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    FriendEntity friend,
    int rank,
    bool isCurrentUser,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primaryBlue.withValues(alpha: 0.4)
              : isTopThree
                  ? _getRankColor(rank).withValues(alpha: 0.4)
                  : (isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.2)
                      : AppColors.lightBorder.withValues(alpha: 0.5)),
          width: isCurrentUser || isTopThree ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: isTopThree
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? LinearGradient(colors: [
                      _getRankColor(rank),
                      _getRankColor(rank).withValues(alpha: 0.7),
                    ])
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: friend.profileImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      friend.profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    isCurrentUser ? '${friend.name} (You)' : friend.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GoldenStarBadge(
                  rating: friend.starRating,
                  fontSize: 12,
                  iconSize: 12,
                ),
              ],
            ),
          ),

          // Consistency score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GoldenStarBadge(
                rating: friend.starRating,
                fontSize: 16,
                iconSize: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.goldBadge;
      case 2:
        return AppColors.silverBadge;
      case 3:
        return AppColors.bronzeBadge;
      default:
        return AppColors.primaryBlue;
    }
  }
}
