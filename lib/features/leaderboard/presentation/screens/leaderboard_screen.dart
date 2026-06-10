import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/loading_shimmer.dart';
import 'package:step_sync/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_provider.dart';

/// Leaderboard screen showing ranked users with tab filters.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(leaderboardFilterProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.leaderboard,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
              vertical: 8,
            ),
            child: Row(
              children: LeaderboardFilter.values.map((f) {
                final isSelected = f == filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(leaderboardFilterProvider.notifier).state = f,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightCard),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : (isDark
                                    ? AppColors.darkBorder.withValues(alpha: 0.3)
                                    : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          _filterLabel(f),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Leaderboard list
          Expanded(
            child: leaderboard.when(
              loading: () => const LeaderboardShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.leaderboard_rounded,
                          size: 64,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(leaderboardProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _LeaderboardTile(
                        entry: entry,
                        index: index,
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * index),
                            duration: 300.ms,
                          )
                          .slideX(begin: 0.05);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(LeaderboardFilter filter) {
    switch (filter) {
      case LeaderboardFilter.today:
        return AppStrings.today;
      case LeaderboardFilter.thisWeek:
        return 'Week';
      case LeaderboardFilter.thisMonth:
        return 'Month';
      case LeaderboardFilter.allTime:
        return 'All Time';
    }
  }
}

/// Individual leaderboard tile for a user entry.
class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;

  const _LeaderboardTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTopThree = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isTopThree
              ? _getRankColor(entry.rank).withValues(alpha: 0.4)
              : (isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.2)
                  : AppColors.lightBorder.withValues(alpha: 0.5)),
          width: isTopThree ? 1.5 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _getRankColor(entry.rank).withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: isTopThree
                ? _buildRankBadge(entry.rank)
                : Text(
                    '${entry.rank}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
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
                  ? LinearGradient(
                      colors: [
                        _getRankColor(entry.rank),
                        _getRankColor(entry.rank).withValues(alpha: 0.7),
                      ],
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: entry.profileImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      entry.profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildInitials(entry.name),
                    ),
                  )
                : _buildInitials(entry.name),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(
              entry.name,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Steps
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatNumber(entry.steps),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isTopThree
                      ? _getRankColor(entry.rank)
                      : AppColors.secondaryTeal,
                ),
              ),
              Text(
                'steps',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    final color = _getRankColor(rank);
    final emoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : '🥉';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
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

  Widget _buildInitials(String name) {
    final initials =
        name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
