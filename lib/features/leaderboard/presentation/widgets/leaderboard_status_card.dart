import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_highlights_provider.dart';


import 'package:step_sync/core/widgets/clay_card.dart';


class LeaderboardStatusCard extends ConsumerWidget {
  const LeaderboardStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(currentUserProvider);
    final rankAsync = ref.watch(currentUserGlobalRankProvider);
    final rankChangeAsync = ref.watch(userRankChangeProvider);

    final user = userState.valueOrNull;
    if (user == null) return const SizedBox.shrink();

    final rank = rankAsync.valueOrNull ?? 0;
    final rankChange = rankChangeAsync.valueOrNull ?? 0;

    return ClayCard(
      borderRadius: AppDimensions.radiusLg,
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: [
          // Rank circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rank > 0 ? '#$rank' : '...',
                style: GoogleFonts.outfit(
                  fontSize: rank > 99 ? 14 : 18,
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
                  AppStrings.yourStatus,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Global Rank ${rank > 0 ? Formatters.formatRank(rank) : '...'}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Rank change indicator
          if (rankChange != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rankChange > 0
                    ? AppColors.successGreen.withValues(alpha: 0.15)
                    : AppColors.errorRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    rankChange > 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: rankChange > 0 ? AppColors.successGreen : AppColors.errorRed,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${rankChange.abs()}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: rankChange > 0 ? AppColors.successGreen : AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppStrings.rankSteady,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTeal,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}
