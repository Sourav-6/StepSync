import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/golden_star_badge.dart';
import 'package:step_sync/features/achievements/presentation/providers/badges_provider.dart';
import 'package:step_sync/features/achievements/presentation/widgets/achievements_grid.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:step_sync/core/widgets/clay_card.dart';

/// User profile screen showing stats, streaks, and actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(currentUserProvider);
    final globalRankAsync = ref.watch(currentUserGlobalRankProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profile,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              children: [
                // ─── Profile Header ───
                Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: AppDimensions.avatarXl,
                          height: AppDimensions.avatarXl,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: user.profileImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    user.profileImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildInitials(user.name),
                                  ),
                                )
                              : _buildInitials(user.name),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => context.push('/edit-profile'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryTeal,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryTeal
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user.name,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                    ),

                    if (user.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phone,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Rank and Star Rating badges
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClayCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: AppColors.primaryBlue.withValues(alpha: 0.8),
                          borderRadius: 20,
                          child: Text(
                            'Rank ${globalRankAsync.valueOrNull != null ? Formatters.formatRank(globalRankAsync.value!) : "..."}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GoldenStarBadge(
                          rating: user.starRating,
                          fontSize: 14,
                          iconSize: 14,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Referral Code
                    if (user.referralCode.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          // In a real app, copy to clipboard here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Referral code copied!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.5),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Code: ${user.referralCode}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryBlue),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1),

                const SizedBox(height: 32),

                // ─── Stats Grid ───
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard(
                      context,
                      AppStrings.totalSteps,
                      Formatters.formatNumber(user.totalSteps),
                      Icons.directions_walk_rounded,
                      AppColors.primaryBlue,
                    ),
                    _buildStatCard(
                      context,
                      AppStrings.totalDistance,
                      Formatters.formatDistance(
                          Formatters.stepsToDistance(user.totalSteps)),
                      Icons.route_rounded,
                      AppColors.secondaryTeal,
                    ),
                    _buildStatCard(
                      context,
                      AppStrings.caloriesBurned,
                      Formatters.formatCalories(
                          Formatters.stepsToCalories(user.totalSteps)),
                      Icons.local_fire_department_rounded,
                      AppColors.accentOrange,
                    ),
                    _buildStatCard(
                      context,
                      AppStrings.currentStreak,
                      Formatters.formatStreak(user.currentStreak),
                      Icons.whatshot_rounded,
                      AppColors.errorRed,
                    ),
                    _buildStatCard(
                      context,
                      AppStrings.longestStreak,
                      Formatters.formatStreak(user.longestStreak),
                      Icons.emoji_events_rounded,
                      AppColors.goldBadge,
                    ),
                    _buildStatCard(
                      context,
                      AppStrings.globalRank,
                      globalRankAsync.valueOrNull != null ? Formatters.formatRank(globalRankAsync.value!) : "...",
                      Icons.leaderboard_rounded,
                      AppColors.primaryLight,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

                const SizedBox(height: 32),

                // ─── Achievements Section ───
                Consumer(
                  builder: (context, ref, child) {
                    final badges = ref.watch(individualBadgesProvider);
                    if (badges.isEmpty) return const SizedBox.shrink();
                    return AchievementsGrid(badges: badges)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.05);
                  },
                ),

                const SizedBox(height: 32),

                // ─── Friends Section ───
                _buildActionTile(
                  context,
                  AppStrings.friends,
                  Icons.people_rounded,
                  () => context.push('/friends'),
                  badge: '${user.friendUids.length}',
                ),
                _buildActionTile(
                  context,
                  AppStrings.inviteFriends,
                  Icons.person_add_alt_1_rounded,
                  () => context.push('/friends/invite'),
                ),
                _buildActionTile(
                  context,
                  'My Referrals',
                  Icons.card_giftcard_rounded,
                  () => context.push('/my-referrals'),
                ),

                const SizedBox(height: 8),

                // ─── Actions ───
                _buildActionTile(
                  context,
                  AppStrings.editProfile,
                  Icons.person_rounded,
                  () => context.push('/edit-profile'),
                ),
                _buildActionTile(
                  context,
                  AppStrings.settings,
                  Icons.settings_rounded,
                  () => context.push('/settings'),
                ),
                const SizedBox(height: 16),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(currentUserProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(
                      AppStrings.signOut,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials =
        name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      borderRadius: AppDimensions.radiusLg,
      padding: const EdgeInsets.all(14),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, size: 22, color: AppColors.primaryBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
            ),
            if (badge != null && badge != '0')
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
