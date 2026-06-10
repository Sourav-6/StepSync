import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';

/// Reusable text styles for StepSync.
/// Use these for custom styling outside the default TextTheme.
class AppTextStyles {
  AppTextStyles._();

  // ─── Step Counter (Large number display) ───
  static TextStyle stepCount(BuildContext context) => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.1,
      );

  static TextStyle stepCountSmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.1,
      );

  // ─── Metric Values ───
  static TextStyle metricValue(BuildContext context) => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle metricLabel(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textLightSecondary,
      );

  // ─── Leaderboard ───
  static TextStyle rankNumber(BuildContext context) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      );

  static TextStyle leaderboardName(BuildContext context) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle leaderboardSteps(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryTeal,
      );

  // ─── Badge / Achievement ───
  static TextStyle badgeTitle(BuildContext context) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ─── Section Headers ───
  static TextStyle sectionHeader(BuildContext context) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ─── Greeting ───
  static TextStyle greeting(BuildContext context) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle greetingSubtitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textLightSecondary,
      );

  // ─── Percentage Display ───
  static TextStyle percentage(BuildContext context) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      );

  // ─── Onboarding ───
  static TextStyle onboardingTitle(BuildContext context) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle onboardingDescription(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textDarkSecondary
            : AppColors.textLightSecondary,
        height: 1.5,
      );
}
