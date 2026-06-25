import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_highlights_provider.dart';


import 'package:step_sync/core/widgets/clay_card.dart';

class TopPerformingGroupCard extends ConsumerWidget {
  const TopPerformingGroupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topGroupAsync = ref.watch(topPerformingGroupProvider);

    return topGroupAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (group) {
        if (group == null) return const SizedBox.shrink();

        final avgSteps = group.memberUids.isNotEmpty
            ? (group.totalSteps / group.memberUids.length).round()
            : 0;

        return ClayCard(
          borderRadius: AppDimensions.radiusLg,
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFFFF8EE),
          child: Row(
            children: [
              // Trophy icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.topGroup,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.name,
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

              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '~$avgSteps',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  Text(
                    'avg steps/member',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: 0.03);
      },
    );
  }
}
