import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/widgets/golden_star_badge.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/groups/presentation/providers/groups_provider.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';
/// Animated circular progress ring for displaying step goal progress.
class StepProgressRing extends ConsumerStatefulWidget {
  final double progress; // 0.0 - 1.0
  final int steps;
  final int goal;
  final double size;
  final double strokeWidth;
  final double? starRating;

  const StepProgressRing({
    super.key,
    required this.progress,
    required this.steps,
    required this.goal,
    this.size = AppDimensions.progressRingSize,
    this.strokeWidth = AppDimensions.progressRingStroke,
    this.starRating,
  });

  @override
  ConsumerState<StepProgressRing> createState() => _StepProgressRingState();
}

class _StepProgressRingState extends ConsumerState<StepProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(StepProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  isDark:
                      Theme.of(context).brightness == Brightness.dark,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step icon
                  Icon(
                    Icons.directions_walk_rounded,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  // Step count
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.steps),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Text(
                        _formatNumber(value),
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  // Steps label
                  Text(
                    'steps',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                  if (widget.starRating != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showRatingBreakdown(context),
                      child: GoldenStarBadge(
                        rating: widget.starRating!,
                        fontSize: 14,
                        iconSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRatingBreakdown(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = ref.read(currentUserProvider).value;
    
    // Calculate Group Stars
    double bestGroupAvg = 0.0;
    if (user != null) {
      try {
        final userGroups = await ref.read(userGroupsProvider.future);
        for (var group in userGroups) {
          if (group.starRating > bestGroupAvg) {
            bestGroupAvg = group.starRating;
          }
        }
      } catch (_) {}
    }
    double groupStars = (bestGroupAvg / 5.0).clamp(0.0, 1.0);

    // Calculate Weekly Consistency Stars
    double weeklyStars = 0.0;
    if (user != null) {
      try {
        final recentSteps = await ref.read(recentStepsProvider(user.uid).future);
        List<int> stepsList = recentSteps.map((e) => e.steps).toList();
        
        bool todayFound = false;
        final todayStr = Formatters.formatDateKey(DateTime.now());
        for (var s in recentSteps) {
          if (s.date == todayStr) {
            todayFound = true;
            break;
          }
        }
        if (!todayFound) {
          stepsList.add(widget.steps);
        }
        
        stepsList.sort((a, b) => b.compareTo(a));
        final best5 = stepsList.take(5).toList();
        final sum = best5.fold<int>(0, (prev, element) => prev + element);
        final avg = sum / 5; // always divide by 5 to match backend
        weeklyStars = (avg / 10000).clamp(0.0, 1.0);
      } catch (_) {}
    }

    // Daily Stars
    double dailyStars = (widget.steps / 10000).clamp(0.0, 1.0) * 2.0;
    
    // Referral Stars
    double referralStars = (user?.referralBagStars ?? 0) > 0 ? 1.0 : 0.0;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppColors.goldBadge.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.goldBadge, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Rating',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your overall rating is composed of 4 elements. Here is what you earned today:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSimpleBreakdownRow(
                context,
                icon: Icons.directions_walk_rounded,
                title: 'Daily Steps',
                earnedStars: dailyStars,
                maxStars: 2,
                isDark: isDark,
              ),
              _buildSimpleBreakdownRow(
                context,
                icon: Icons.card_giftcard_rounded,
                title: 'Referral Bag',
                earnedStars: referralStars,
                maxStars: 1,
                isDark: isDark,
              ),
              _buildSimpleBreakdownRow(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Weekly Consistency',
                earnedStars: weeklyStars,
                maxStars: 1,
                isDark: isDark,
              ),
              _buildSimpleBreakdownRow(
                context,
                icon: Icons.groups_rounded,
                title: 'Group Average',
                earnedStars: groupStars,
                maxStars: 1,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showRatingGuidelines(context);
                  },
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('How is my rating calculated?'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingGuidelines(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppColors.goldBadge.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.goldBadge, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Rating Guidelines',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Achieve your goals across 4 categories to earn all 5 stars!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildBreakdownRow(
                context,
                icon: Icons.directions_walk_rounded,
                title: 'Daily Steps',
                maxStars: 2,
                description: 'Earn up to 2 stars. One star for completing 5k steps, and another for completing 10k steps total.',
                isDark: isDark,
              ),
              _buildBreakdownRow(
                context,
                icon: Icons.card_giftcard_rounded,
                title: 'Referral Bag',
                maxStars: 1,
                description: 'Earn 1 star automatically as long as you have a positive balance in your referral bag.',
                isDark: isDark,
              ),
              _buildBreakdownRow(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Weekly Consistency',
                maxStars: 1,
                description: 'Earn up to 1 star by maintaining a 10k daily step average over your best 5 of the last 7 days.',
                isDark: isDark,
              ),
              _buildBreakdownRow(
                context,
                icon: Icons.groups_rounded,
                title: 'Group Average',
                maxStars: 1,
                description: 'Earn up to 1 star based on the highest average rating among all the groups you have joined.',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleBreakdownRow(BuildContext context, {
    required IconData icon,
    required String title,
    required double earnedStars,
    required int maxStars,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                earnedStars.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldBadge,
                ),
              ),
              Text(
                ' / $maxStars ★',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, {
    required IconData icon,
    required String title,
    required int maxStars,
    required String description,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    Text(
                      'Max $maxStars ★',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldBadge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final s = number.toString();
      final buffer = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return number.toString();
  }
}

/// Custom painter for the progress ring with gradient.
class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool isDark;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = isDark
          ? AppColors.darkCard
          : AppColors.lightCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: progress >= 1.0
            ? [AppColors.successGreen, AppColors.secondaryTeal, AppColors.successGreen]
            : [AppColors.primaryBlue, AppColors.secondaryTeal, AppColors.primaryLight],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        progressPaint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
