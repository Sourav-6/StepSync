import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_highlights_provider.dart';

import 'package:step_sync/core/widgets/clay_card.dart';
import 'package:step_sync/features/leaderboard/domain/entities/leaderboard_entry.dart';

/// Card highlighting the most consistent performer in the global leaderboard.
class ConsistentPerformerCard extends ConsumerWidget {
  const ConsistentPerformerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPerformerAsync = ref.watch(topConsistentPerformerProvider);

    return topPerformerAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (performer) {
        if (performer == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _showPerformerStats(context, performer),
          behavior: HitTestBehavior.opaque,
          child: ClayCard(
            borderRadius: AppDimensions.radiusLg,
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : const Color(0xFFE8F6ED),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: performer.profileImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            performer.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                performer.name.isNotEmpty
                                    ? performer.name[0].toUpperCase()
                                    : 'U',
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
                            performer.name.isNotEmpty
                                ? performer.name[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.mostConsistent,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        performer.name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                          performer.starRating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warningYellow,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .slideX(begin: 0.03)
              .then()
              .shimmer(
                delay: 500.ms,
                duration: 1500.ms,
                color: AppColors.secondaryTeal.withValues(alpha: 0.15),
              ),
        );
      },
    );
  }

  void _showPerformerStats(BuildContext context, LeaderboardEntry performer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: AppColors.primaryBlue, size: 28),
                const SizedBox(width: 8),
                Text(
                  '${performer.name}\'s Stats',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatRow(
              icon: Icons.directions_walk_rounded,
              title: 'Total Steps',
              value: performer.steps.toString(),
              isDark: isDark,
            ),
            _buildStatRow(
              icon: Icons.emoji_events_rounded,
              title: 'Current Rank',
              value: '#${performer.rank}',
              isDark: isDark,
            ),
            _buildStatRow(
              icon: Icons.auto_graph_rounded,
              title: 'Consistency Score',
              value: '${(performer.consistencyScore * 100).toStringAsFixed(1)}%',
              isDark: isDark,
            ),
            _buildStatRow(
              icon: Icons.star_rounded,
              title: 'Star Rating',
              value: '${performer.starRating.toStringAsFixed(1)} / 5.0',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

