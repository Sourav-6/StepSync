import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/features/achievements/domain/entities/achievement_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementsGrid extends StatelessWidget {
  final List<AchievementBadge> badges;
  final String title;

  const AchievementsGrid({
    super.key,
    required this.badges,
    this.title = 'Achievements',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(context, badge, isDark)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .slideY(begin: 0.1);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BuildContext context, AchievementBadge badge, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: badge.isUnlocked
              ? badge.color.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: badge.isUnlocked ? 1.5 : 1.0,
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: badge.color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.isUnlocked
                  ? badge.color.withValues(alpha: 0.15)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Icon(
              badge.icon,
              color: badge.isUnlocked
                  ? badge.color
                  : (isDark ? Colors.white38 : Colors.black38),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badge.isUnlocked
                  ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                  : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
