import 'package:flutter/material.dart';

/// A premium Claymorphic text input field.
/// Styled to look "pressed" or inset into the clay background.
class ClayInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double borderRadius;
  final double depth;

  const ClayInputField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.borderRadius = 16,
    this.depth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Inset background color is slightly darker/lighter than standard surfaces
    final Color baseColor = isDark 
        ? Color(0xFF1E2026) 
        : Color(0xFFE8ECF5);

    // Inset inner shadow colors
    final Color darkInnerShadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.08);

    final Color lightInnerShadowColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.70);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Top-left dark inset shadow (creates the recess)
            Positioned.fill(
              child: CustomPaint(
                painter: _InnerShadowPainter(
                  borderRadius: borderRadius,
                  shadowColor: darkInnerShadowColor,
                  blur: depth,
                  offset: Offset(depth * 0.5, depth * 0.5),
                ),
              ),
            ),
            // Bottom-right light inset shadow (creates the rim highlight)
            Positioned.fill(
              child: CustomPaint(
                painter: _InnerShadowPainter(
                  borderRadius: borderRadius,
                  shadowColor: lightInnerShadowColor,
                  blur: depth,
                  offset: Offset(-depth * 0.5, -depth * 0.5),
                ),
              ),
            ),
            // Actual text field
            TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              validator: validator,
              onChanged: onChanged,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                prefixIcon: prefixIcon != null 
                    ? Icon(prefixIcon, color: theme.colorScheme.primary.withOpacity(0.7)) 
                    : null,
                suffixIcon: suffixIcon != null 
                    ? Icon(suffixIcon, color: theme.colorScheme.primary.withOpacity(0.7)) 
                    : null,
                filled: true,
                fillColor: Colors.transparent, // Let container background show
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 2.0,
                  ),
                ),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
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
