import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';

import 'package:step_sync/core/widgets/clay_button.dart';

/// Social login button for Google, Phone, etc.
class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return ClayButton(
      width: double.infinity,
      height: 56,
      onPressed: onPressed,
      color: baseColor,
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ??
                (isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
