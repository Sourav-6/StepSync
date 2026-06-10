import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';

/// Animated circular progress ring for displaying step goal progress.
class StepProgressRing extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final int steps;
  final int goal;
  final double size;
  final double strokeWidth;

  const StepProgressRing({
    super.key,
    required this.progress,
    required this.steps,
    required this.goal,
    this.size = AppDimensions.progressRingSize,
    this.strokeWidth = AppDimensions.progressRingStroke,
  });

  @override
  State<StepProgressRing> createState() => _StepProgressRingState();
}

class _StepProgressRingState extends State<StepProgressRing>
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
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  // Goal text
                  Text(
                    '/ ${_formatNumber(widget.goal)} steps',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_progressAnimation.value * 100).round()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
