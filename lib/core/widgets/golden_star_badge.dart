import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';

class GoldenStarBadge extends StatelessWidget {
  final double rating;
  final double fontSize;
  final double iconSize;

  const GoldenStarBadge({
    super.key,
    required this.rating,
    this.fontSize = 15,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.goldBadge.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldBadge.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.goldBadge,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.star_rounded,
            color: AppColors.goldBadge,
            size: iconSize,
          ),
        ],
      ),
    );
  }
}
