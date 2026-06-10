import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';

/// Shimmer loading skeleton for premium loading states.
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      highlightColor:
          isDark ? AppColors.darkBorder : AppColors.lightBorder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Loading card skeleton mimicking a metric card.
class MetricCardShimmer extends StatelessWidget {
  const MetricCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoadingShimmer(height: 14, width: 60),
        SizedBox(height: 8),
        LoadingShimmer(height: 28, width: 80),
        SizedBox(height: 4),
        LoadingShimmer(height: 12, width: 40),
      ],
    );
  }
}

/// Loading card for the step progress ring.
class ProgressRingShimmer extends StatelessWidget {
  const ProgressRingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoadingShimmer(
        height: AppDimensions.progressRingSize,
        width: AppDimensions.progressRingSize,
        borderRadius: AppDimensions.radiusRound,
      ),
    );
  }
}

/// Full dashboard loading skeleton.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          const LoadingShimmer(height: 28, width: 200),
          const SizedBox(height: 8),
          const LoadingShimmer(height: 14, width: 140),
          const SizedBox(height: AppDimensions.sectionSpacing),
          // Progress ring
          const ProgressRingShimmer(),
          const SizedBox(height: AppDimensions.sectionSpacing),
          // Metric cards
          Row(
            children: [
              Expanded(child: LoadingShimmer(height: 100, borderRadius: AppDimensions.radiusLg)),
              const SizedBox(width: 12),
              Expanded(child: LoadingShimmer(height: 100, borderRadius: AppDimensions.radiusLg)),
              const SizedBox(width: 12),
              Expanded(child: LoadingShimmer(height: 100, borderRadius: AppDimensions.radiusLg)),
            ],
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          // Motivational banner
          LoadingShimmer(height: 80, borderRadius: AppDimensions.radiusLg),
        ],
      ),
    );
  }
}

/// Leaderboard loading skeleton.
class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(
          height: 72,
          borderRadius: AppDimensions.radiusLg,
        ),
      ),
    );
  }
}
