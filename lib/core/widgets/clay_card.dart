import 'package:flutter/material.dart';

/// A premium Claymorphism Card widget with soft 3D bubble-like depth.
/// Uses dual inner shadows (top-left highlight, bottom-right shadow)
/// and a soft outer shadow.
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double depth;
  final double spread;
  final Color? color;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.depth = 12,
    this.spread = 5,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Fallback base color
    final baseColor = color ?? (isDark ? theme.colorScheme.surface : Colors.white);

    // Calculate light and dark inner shadow colors
    final hsl = HSLColor.fromColor(baseColor);
    
    // Light inner shadow (highlight): Lighter than base color
    final Color lightInnerShadowColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.70);

    // Dark inner shadow: Slightly darker/saturated variant
    final Color darkInnerShadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor().withOpacity(0.25);

    // Outer shadow: Soft blur for floating depth
    final Color outerShadowColor = isDark
        ? Colors.black.withOpacity(0.35)
        : Colors.black.withOpacity(0.06);

    final Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: outerShadowColor,
            blurRadius: depth * 1.5,
            spreadRadius: spread * 0.15,
            offset: Offset(depth * 0.6, depth * 0.6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Light top-left inner shadow highlight
            Positioned.fill(
              child: CustomPaint(
                painter: _InnerShadowPainter(
                  borderRadius: borderRadius,
                  shadowColor: lightInnerShadowColor,
                  blur: depth,
                  offset: Offset(depth * 0.35, depth * 0.35),
                ),
              ),
            ),
            // Dark bottom-right inner shadow depth
            Positioned.fill(
              child: CustomPaint(
                painter: _InnerShadowPainter(
                  borderRadius: borderRadius,
                  shadowColor: darkInnerShadowColor,
                  blur: depth,
                  offset: Offset(-depth * 0.35, -depth * 0.35),
                ),
              ),
            ),
            // Actual user child widget
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}

class _InnerShadowPainter extends CustomPainter {
  final double borderRadius;
  final Color shadowColor;
  final double blur;
  final Offset offset;

  _InnerShadowPainter({
    required this.borderRadius,
    required this.shadowColor,
    required this.blur,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final Path path = Path()..addRRect(rrect);

    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.saveLayer(rect, Paint());
    canvas.clipPath(path);
    canvas.drawPath(path.shift(offset), shadowPaint);

    shadowPaint.blendMode = BlendMode.srcOut;
    canvas.drawPath(path, shadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.blur != blur ||
        oldDelegate.offset != offset;
  }
}
