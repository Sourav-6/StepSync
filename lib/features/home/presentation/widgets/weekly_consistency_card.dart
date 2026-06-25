import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';
import 'package:step_sync/features/steps/domain/entities/daily_steps_entity.dart';

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
                  _buildStarRating(user.consistencyScore),
                ],
              ),
              const SizedBox(height: 20),
              recentStepsAsync.when(
                data: (recentSteps) => _buildDayTracker(context, recentSteps, user.dailyGoal),
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

  Widget _buildStarRating(double score) {
    // Score is 0.0 to 1.0. Multiply by 5 for a 5-star rating.
    final stars = score * 5;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (stars >= index + 0.75) {
          icon = Icons.star_rounded;
        } else if (stars >= index + 0.25) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        
        return Icon(
          icon,
          size: 18,
          color: AppColors.warningYellow,
        );
      }),
    );
  }

  Widget _buildDayTracker(BuildContext context, List<DailyStepsEntity> recentSteps, int dailyGoal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We want the last 7 days ending with today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final Map<String, int> stepsByDate = {
      for (var step in recentSteps) step.date: step.steps
    };
    
    final days = <Widget>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayLabel = _getDayLabel(date.weekday);
      
      final steps = stepsByDate[dateStr] ?? 0;
      final bool metGoal = steps >= dailyGoal;
      final bool hasData = steps > 0;
      
      days.add(
        Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: metGoal 
                      ? AppColors.successGreen.withValues(alpha: 0.15)
                      : (hasData ? AppColors.warningYellow.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))),
                  border: Border.all(
                    color: metGoal
                        ? AppColors.successGreen
                        : (hasData ? AppColors.warningYellow.withValues(alpha: 0.5) : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
                    width: metGoal ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: metGoal 
                      ? const Icon(Icons.check_rounded, size: 16, color: AppColors.successGreen)
                      : (hasData 
                          ? Text(
                              '${(steps/dailyGoal * 100).toInt()}%',
                              style: GoogleFonts.inter(fontSize: 8, color: AppColors.warningYellow, fontWeight: FontWeight.w600),
                            )
                          : const SizedBox.shrink()),
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
