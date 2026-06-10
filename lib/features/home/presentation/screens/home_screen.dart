import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/loading_shimmer.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/home/presentation/widgets/metric_card.dart';
import 'package:step_sync/features/home/presentation/widgets/step_progress_ring.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';

/// Main home dashboard screen showing step progress, metrics, and status.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(currentUserProvider);
    final stepData = ref.watch(todayStepsProvider);

    // Activate the step sync service to auto-save steps to Firebase
    ref.watch(stepSyncProvider);

    return Scaffold(
      body: SafeArea(
        child: userState.when(
          loading: () => const DashboardShimmer(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            final userName = user?.name ?? 'User';
            final greeting = Formatters.getGreeting();
            final streak = user?.currentStreak ?? 0;
            final rank = user?.currentRank ?? 0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Greeting ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting 👋',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textLightSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName.split(' ').first,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Profile avatar
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: user?.profileImage.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    user!.profileImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildAvatarPlaceholder(userName),
                                  ),
                                )
                              : _buildAvatarPlaceholder(userName),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1),

                  const SizedBox(height: 32),

                  // ─── Progress Ring ───
                  Center(
                    child: StepProgressRing(
                      progress: stepData.progress,
                      steps: stepData.steps,
                      goal: stepData.goal,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 28),

                  // ─── Motivational Message ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: stepData.goalReached
                          ? AppColors.successGradient
                          : AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: (stepData.goalReached
                                  ? AppColors.successGreen
                                  : AppColors.primaryBlue)
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          stepData.goalReached ? '🏆' : '💪',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            Formatters.getMotivationalMessage(
                              stepData.steps,
                              stepData.goal,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ─── Metrics Grid ───
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: AppStrings.distanceCovered,
                          value: Formatters.formatDistanceShort(
                              stepData.distance),
                          unit: AppStrings.kmUnit,
                          icon: Icons.route_rounded,
                          iconColor: AppColors.secondaryTeal,
                          animatedDoubleValue: stepData.distance,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          label: AppStrings.caloriesBurned,
                          value: Formatters.formatCaloriesShort(
                              stepData.calories),
                          unit: AppStrings.kcalUnit,
                          icon: Icons.local_fire_department_rounded,
                          iconColor: AppColors.accentOrange,
                          animatedDoubleValue: stepData.calories,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: AppStrings.currentStreak,
                          value: Formatters.formatStreak(streak),
                          unit: AppStrings.daysUnit,
                          icon: Icons.whatshot_rounded,
                          iconColor: AppColors.errorRed,
                          animatedValue: streak,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          label: AppStrings.globalRank,
                          value: Formatters.formatRank(rank),
                          unit: 'rank',
                          icon: Icons.leaderboard_rounded,
                          iconColor: AppColors.goldBadge,
                          animatedValue: rank,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ─── Daily Achievement Badge ───
                  if (stepData.goalReached)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.goldBadge.withValues(alpha: 0.2),
                            AppColors.accentOrange.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: AppColors.goldBadge.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.goldBadge.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: AppColors.goldBadge,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Goal Achieved! 🎉',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldBadge,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You crushed ${Formatters.formatNumber(stepData.steps)} steps today!',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textDarkSecondary
                                        : AppColors.textLightSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .scale(begin: const Offset(0.95, 0.95))
                        .shimmer(
                          delay: 1000.ms,
                          duration: 1500.ms,
                          color: AppColors.goldBadge.withValues(alpha: 0.3),
                        ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
