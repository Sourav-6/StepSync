import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';

/// Reusable text field for authentication screens.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Inset background color is slightly darker/lighter than standard surfaces
    final Color baseColor = isDark 
        ? const Color(0xFF1E2026) 
        : const Color(0xFFE8ECF5);

    // Inset inner shadow colors
    final Color darkInnerShadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.08);

    final Color lightInnerShadowColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.70);

    const double borderRadius = 16;
    const double depth = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textLightPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                      offset: const Offset(depth * 0.5, depth * 0.5),
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
                      offset: const Offset(-depth * 0.5, -depth * 0.5),
                    ),
                  ),
                ),
                // Actual text field
                TextFormField(
                  controller: widget.controller,
                  readOnly: widget.readOnly,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  textCapitalization: widget.textCapitalization,
                  maxLines: widget.isPassword ? 1 : widget.maxLines,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: widget.readOnly
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    filled: true,
                    fillColor: Colors.transparent, // Let container background show
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
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
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            size: 20,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                          )
                        : null,
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textLightSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
