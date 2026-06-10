import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/routes/app_router.dart';
import 'package:step_sync/core/theme/app_theme.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';

/// Root application widget.
/// Configures MaterialApp with GoRouter, theming, and Riverpod.
class StepSyncApp extends ConsumerWidget {
  const StepSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
