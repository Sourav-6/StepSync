import 'package:flutter/material.dart';

/// StepSync premium fitness color palette.
/// Uses a vibrant, modern scheme inspired by fitness/health apps.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySurface = Color(0xFFDBEAFE);

  // ─── Secondary / Teal ───
  static const Color secondaryTeal = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF5EEAD4);

  // ─── Accent / Orange ───
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentDark = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFDBA74);

  // ─── Success / Green ───
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF86EFAC);

  // ─── Warning / Yellow ───
  static const Color warningYellow = Color(0xFFEAB308);
  static const Color warningLight = Color(0xFFFDE047);

  // ─── Error / Red ───
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFCA5A5);

  // ─── Dark Theme Backgrounds ───
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);

  // ─── Light Theme Backgrounds ───
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ─── Text Colors ───
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x55FFFFFF);
  static const Color glassDark = Color(0x331E293B);
  static const Color glassDarkBorder = Color(0x55475569);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, Color(0xFFEC4899)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryTeal, Color(0xFF06B6D4)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, secondaryTeal],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  // ─── Badge Colors ───
  static const Color goldBadge = Color(0xFFFFD700);
  static const Color silverBadge = Color(0xFFC0C0C0);
  static const Color bronzeBadge = Color(0xFFCD7F32);

  // ─── Chart Colors ───
  static const List<Color> chartColors = [
    primaryBlue,
    secondaryTeal,
    accentOrange,
    successGreen,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    warningYellow,
  ];
}
