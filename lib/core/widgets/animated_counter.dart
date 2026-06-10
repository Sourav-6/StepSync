import 'package:flutter/material.dart';

/// Animated number counter that smoothly transitions between values.
/// Used for step counts, calories, distance, and other metrics.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final formatted = _formatNumber(animatedValue);
        return Text(
          '${prefix ?? ''}$formatted${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final formatted = number.toString();
      final buffer = StringBuffer();
      for (var i = 0; i < formatted.length; i++) {
        if (i > 0 && (formatted.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(formatted[i]);
      }
      return buffer.toString();
    }
    return number.toString();
  }
}

/// Animated decimal counter for distance, calories, etc.
class AnimatedDecimalCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final int decimalPlaces;
  final String? prefix;
  final String? suffix;

  const AnimatedDecimalCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.decimalPlaces = 2,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}${animatedValue.toStringAsFixed(decimalPlaces)}${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
