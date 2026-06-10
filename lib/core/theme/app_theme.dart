import 'package:flutter/material.dart';
import 'package:step_sync/core/theme/light_theme.dart';
import 'package:step_sync/core/theme/dark_theme.dart';

/// Central theme provider for StepSync.
/// Exposes both light and dark themes built on Material 3.
class AppTheme {
  AppTheme._();

  /// Light theme data.
  static ThemeData get light => LightTheme.theme;

  /// Dark theme data.
  static ThemeData get dark => DarkTheme.theme;
}
