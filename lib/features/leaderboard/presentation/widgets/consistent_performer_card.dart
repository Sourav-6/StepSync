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

              // Consistency stars
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStars(performer.consistencyScore),
                  const SizedBox(height: 2),
                  Text(
                    '${(performer.consistencyScore * 100).toInt()}% consistent',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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

  Widget _buildStars(double score) {
    final fullStars = (score * 5).floor();
    final hasHalfStar = (score * 5) - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.orange, size: 14);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.orange, size: 14);
        } else {
          return const Icon(Icons.star_border, color: Colors.orange, size: 14);
        }
      }),
    );
  }
}
