import 'package:flutter/material.dart';

/// A premium, squishy, 3D Claymorphic button.
/// Animates its shape, shadows, and scale on press to create a satisfying tactile feel.
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final double borderRadius;
  final double depth;
  final double spread;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ClayButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.borderRadius = 28, // Rounder buttons are key to claymorphism
    this.depth = 10,
    this.spread = 4,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    // Disabled button has lower opacity and saturation
    final Color baseColor = widget.color ?? theme.colorScheme.primary;
    final finalBaseColor = isEnabled 
        ? baseColor 
        : (isDark ? baseColor.withOpacity(0.3) : baseColor.withOpacity(0.5));

    final hsl = HSLColor.fromColor(finalBaseColor);

    // Inner shadow colors
    final Color lightInnerShadowColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.70);

    final Color darkInnerShadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor().withOpacity(0.3);

    // Outer shadow color
    final Color outerShadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : baseColor.withOpacity(0.25);

    // Animating values based on pressed state
    final double scale = _isPressed ? 0.96 : 1.0;
    final double depth = _isPressed ? widget.depth * 0.2 : widget.depth;
    final double spread = _isPressed ? widget.spread * 0.2 : widget.spread;

    // Inner shadow offsets (swapped on pressed to look concave/inset)
    final Offset lightOffset = _isPressed
        ? Offset(-widget.depth * 0.3, -widget.depth * 0.3) // bottom-right light
        : Offset(widget.depth * 0.3, widget.depth * 0.3);  // top-left light

    final Offset darkOffset = _isPressed
        ? Offset(widget.depth * 0.3, widget.depth * 0.3)    // top-left dark
        : Offset(-widget.depth * 0.3, -widget.depth * 0.3); // bottom-right dark

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: finalBaseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (isEnabled)
                BoxShadow(
                  color: outerShadowColor,
                  blurRadius: depth * 1.5,
                  spreadRadius: spread * 0.1,
                  offset: Offset(depth * 0.5, depth * 0.5),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                // Light inner shadow
                Positioned.fill(
                  child: CustomPaint(
                    painter: _InnerShadowPainter(
                      borderRadius: widget.borderRadius,
                      shadowColor: lightInnerShadowColor,
                      blur: depth,
                      offset: lightOffset,
                    ),
                  ),
                ),
                // Dark inner shadow
                Positioned.fill(
                  child: CustomPaint(
                    painter: _InnerShadowPainter(
                      borderRadius: widget.borderRadius,
                      shadowColor: darkInnerShadowColor,
                      blur: depth,
                      offset: darkOffset,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Center(
                    child: DefaultTextStyle(
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ) ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
