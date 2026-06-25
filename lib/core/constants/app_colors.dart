import 'package:flutter/material.dart';

/// StepSync Google Pay style color palette.
/// Uses a vibrant, modern scheme inspired by clean Material 3 fintech apps.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF174EA6);
  static const Color primaryLight = Color(0xFF8AB4F8);
  static const Color primarySurface = Color(0xFFE8F0FE);

  // ─── Secondary / Teal ───
  static const Color secondaryTeal = Color(0xFF1E8E3E); // Mapping to Google Green
  static const Color secondaryDark = Color(0xFF137333);
  static const Color secondaryLight = Color(0xFF81C995);

  // ─── Accent / Orange ───
  static const Color accentOrange = Color(0xFFFA7B17); // Google Yellow/Orange
  static const Color accentDark = Color(0xFFE37400);
  static const Color accentLight = Color(0xFFFDE293);

  // ─── Success / Green ───
  static const Color successGreen = Color(0xFF1E8E3E);
  static const Color successDark = Color(0xFF137333);
  static const Color successLight = Color(0xFF81C995);

  // ─── Warning / Yellow ───
  static const Color warningYellow = Color(0xFFF9AB00);
  static const Color warningLight = Color(0xFFFDE293);

  // ─── Error / Red ───
  static const Color errorRed = Color(0xFFD93025);
  static const Color errorDark = Color(0xFFA50E0E);
  static const Color errorLight = Color(0xFFF28B82);

  // ─── Dark Theme Backgrounds ───
  static const Color darkBg = Color(0xFF16181E);      // Softer dark background
  static const Color darkSurface = Color(0xFF222631); // Soft dark slate surface
  static const Color darkCard = Color(0xFF2C3242);    // Softer dark slate card
  static const Color darkBorder = Color(0xFF373E52);

  // ─── Light Theme Backgrounds ───
  static const Color lightBg = Color(0xFFEDF2FA);      // Softer, premium pastel blue-grey background
  static const Color lightSurface = Color(0xFFF6F8FD); // Pastel blue-grey surface
  static const Color lightCard = Color(0xFFFFFFFF);    // Clean white card that pops on pastel background
  static const Color lightBorder = Color(0xFFD3DFEF);

  // ─── Text Colors ───
  static const Color textDarkPrimary = Color(0xFFE8EAED);
  static const Color textDarkSecondary = Color(0xFF9AA0A6);
  static const Color textLightPrimary = Color(0xFF202124);
  static const Color textLightSecondary = Color(0xFF5E6368);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x55FFFFFF);
  static const Color glassDark = Color(0x33202124);
  static const Color glassDarkBorder = Color(0x555F6368);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accentOrange],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryTeal],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, successGreen],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF303134), Color(0xFF202124)],
  );

  // ─── Badge Colors ───
  static const Color goldBadge = Color(0xFFF9AB00);
  static const Color silverBadge = Color(0xFFBCC1C6);
  static const Color bronzeBadge = Color(0xFFD93025);

  // ─── Chart Colors ───
  static const List<Color> chartColors = [
    primaryBlue,
    successGreen,
    warningYellow,
    errorRed,
    Color(0xFFA142F4),
    Color(0xFF24C1E0),
    Color(0xFFFA7B17),
  ];
}
