import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/widgets/clay_card.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/core/widgets/loading_shimmer.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/home/presentation/widgets/metric_card.dart';
import 'package:step_sync/features/home/presentation/widgets/step_progress_ring.dart';
import 'package:step_sync/features/home/presentation/widgets/dashboard_highlights.dart';
import 'package:step_sync/features/home/presentation/widgets/weekly_consistency_card.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';
import 'package:step_sync/features/leaderboard/presentation/providers/leaderboard_provider.dart';

/// Main home dashboard screen showing step progress, metrics, and status.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _healthCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHealthConnect();
    });
  }

  Future<void> _checkHealthConnect() async {
    if (_healthCheckDone) return;
    _healthCheckDone = true;

    final repo = ref.read(stepsRepositoryProvider);
    final isAvailable = await repo.checkHealthConnectAvailable();

    if (!isAvailable && mounted) {
      // Health Connect not installed — prompt to install
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Health Connect Required'),
          content: const Text(
              'SRP Health uses Google Health Connect to read your daily steps — '
              'the same data that Google Fit displays. '
              'Please install Health Connect from the Play Store.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await repo.promptInstallHealthConnect();
              },
              child: const Text('Install'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      // Health Connect is available — request permissions
      final hasPerms = await repo.checkAndRequestPermissions();
      if (hasPerms) {
        // Permissions granted! Trigger a refresh of step data.
        ref.read(stepCountProvider.notifier).refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(currentUserProvider);
    final stepData = ref.watch(todayStepsProvider);

    // The StepCountNotifier handles polling and syncing automatically now.

    return Scaffold(
      body: SafeArea(
        child: userState.when(
          loading: () => const DashboardShimmer(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            final userName = user?.name ?? 'User';
            final greeting = Formatters.getGreeting();
            final streak = user?.currentStreak ?? 0;
            final liveRankAsync = ref.watch(currentUserGlobalRankProvider);
            final rank = liveRankAsync.valueOrNull ?? user?.currentRank ?? 0;

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
                            greeting,
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

                  
                  Center(
                    child: StepProgressRing(
                      progress: stepData.progress,
                      steps: stepData.steps,
                      goal: stepData.goal,
                      starRating: user?.starRating,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 28),

                  // ─── Motivational Message ───
                  ClayCard(
                    borderRadius: AppDimensions.radiusLg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    color: stepData.goalReached
                        ? AppColors.successGreen
                        : AppColors.primaryBlue,
                    child: Row(
                      children: [
                        Icon(
                          stepData.goalReached ? Icons.emoji_events_rounded : Icons.fitness_center_rounded,
                          size: 28,
                          color: Colors.white,
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
                  const DashboardHighlights().animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),
                  const WeeklyConsistencyCard().animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ─── Daily Achievement Badge ───
                  if (stepData.goalReached)
                    ClayCard(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: AppColors.goldBadge.withValues(alpha: 0.15),
                      borderRadius: AppDimensions.radiusLg,
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
