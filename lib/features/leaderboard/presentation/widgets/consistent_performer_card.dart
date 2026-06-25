import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_highlights_provider.dart';

import 'package:step_sync/core/widgets/clay_card.dart';

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

        return ClayCard(
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
            );
      },
    );
  }
}
