import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';
import 'package:step_sync/core/widgets/golden_star_badge.dart';

import 'package:step_sync/core/widgets/clay_card.dart';

class WeeklyConsistencyCard extends ConsumerWidget {
  const WeeklyConsistencyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final recentStepsAsync = ref.watch(recentStepsProvider(user.uid));

        return ClayCard(
          borderRadius: AppDimensions.radiusXl,
          padding: const EdgeInsets.all(20),
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Consistency',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  _buildRatingDisplay(user.starRating, isDark),
                ],
              ),
              const SizedBox(height: 20),
              recentStepsAsync.when(
                data: (recentSteps) => _buildDayTracker(context, recentSteps, user.dailyGoal, user),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading steps', style: GoogleFonts.inter(fontSize: 12))),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRatingDisplay(double score, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: AppColors.warningYellow),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.warningYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTracker(BuildContext context, List<DailyStepsEntity> recentSteps, int dailyGoal, UserEntity user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We want the last 7 days ending with today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final Map<String, DailyStepsEntity> stepsByDate = {
      for (var step in recentSteps) step.date: step
    };
    
    final days = <Widget>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayLabel = _getDayLabel(date.weekday);
      
      final stepEntity = stepsByDate[dateStr];
      final steps = stepEntity?.steps ?? 0;
      final bool hasData = steps > 0;
      
      // For today, use the live user star rating. For past days, strictly use the saved rating.
      // We no longer fallback to step-ratio because the user specifically requested the exact daily rating.
      double displayRating = 0.0;
      if (dateStr == '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}') {
         // Today
         displayRating = user.starRating;
      } else if (stepEntity != null) {
         // Past day
         displayRating = stepEntity.starRating;
      }
      
      days.add(
        Expanded(
          child: Column(
            children: [
              hasData
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GoldenStarBadge(
                        rating: displayRating,
                        fontSize: 12,
                        iconSize: 14,
                      ),
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                dayLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                  color: i == 0 
                      ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                      : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days,
    );
  }
  
  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '';
    }
  }
}
