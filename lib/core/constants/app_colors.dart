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

  // ─── Dark Theme Backgrounds (Earthy/Matte Charcoal - Not typical neon/slate) ───
  static const Color darkBg = Color(0xFF1E1D1B);      // Deep matte espresso/charcoal
  static const Color darkSurface = Color(0xFF252422); // Slightly lighter for surfaces
  static const Color darkCard = Color(0xFF252422);    // Same as surface for clay effect
  static const Color darkBorder = Color(0xFF33312E);
  
  // Dark Claymorphism Shadows
  static const Color darkClayHighlight = Color(0xFF2F2D2A); // Top-left light
  static const Color darkClayShadow = Color(0xFF131211);    // Bottom-right shadow

  // ─── Light Theme Backgrounds (Soft Clay) ───
  static const Color lightBg = Color(0xFFE0E5EC);      // Soft clay bluish-grey
  static const Color lightSurface = Color(0xFFE0E5EC); // Same for smooth 3D effect
  static const Color lightCard = Color(0xFFE0E5EC);    
  static const Color lightBorder = Color(0xFFD1D9E6);

  // Light Claymorphism Shadows
  static const Color lightClayHighlight = Color(0xFFFFFFFF); // Top-left light
  static const Color lightClayShadow = Color(0xFFA3B1C6);    // Bottom-right shadow

  // ─── Text Colors ───
  static const Color textDarkPrimary = Color(0xFFE8E6E3); // Warm off-white
  static const Color textDarkSecondary = Color(0xFF9E9B96);
  static const Color textLightPrimary = Color(0xFF4A4E69); // Deep clay text
  static const Color textLightSecondary = Color(0xFF72778F);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x55FFFFFF);
  static const Color glassDark = Color(0x33252422);
  static const Color glassDarkBorder = Color(0x5533312E);

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

  static const LinearGradient goldenStarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)], // Vibrant Gold to Metallic Gold
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
