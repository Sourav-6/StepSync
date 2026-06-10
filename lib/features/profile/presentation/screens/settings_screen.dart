import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/services/hive_service.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/steps/presentation/providers/steps_provider.dart';

/// Settings screen with theme, notification, and goal configuration.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final goal = ref.watch(dailyGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // Dark Mode
          _buildSettingTile(
            context,
            title: AppStrings.darkMode,
            subtitle: 'Switch between light and dark theme',
            icon: Icons.dark_mode_rounded,
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state = value;
                HiveService.setDarkMode(value);
              },
              activeColor: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 8),

          // Daily Step Goal
          _buildSettingTile(
            context,
            title: AppStrings.stepGoal,
            subtitle: '${_formatGoal(goal)} steps per day',
            icon: Icons.flag_rounded,
            onTap: () => _showGoalDialog(context, ref, goal),
          ),

          const SizedBox(height: 8),

          // Notifications
          _buildSettingTile(
            context,
            title: AppStrings.notifications,
            subtitle: 'Goal reminders & achievements',
            icon: Icons.notifications_rounded,
            trailing: Switch.adaptive(
              value: HiveService.notificationsEnabled,
              onChanged: (value) {
                HiveService.setNotifications(value);
              },
              activeColor: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 24),

          // About section
          Text(
            'About',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingTile(
            context,
            title: AppStrings.about,
            subtitle: 'StepSync v${AppStrings.appVersion}',
            icon: Icons.info_outline_rounded,
          ),

          _buildSettingTile(
            context,
            title: AppStrings.privacyPolicy,
            subtitle: 'View our privacy policy',
            icon: Icons.privacy_tip_outlined,
          ),

          _buildSettingTile(
            context,
            title: AppStrings.termsOfService,
            subtitle: 'View terms of service',
            icon: Icons.description_outlined,
          ),

          const SizedBox(height: 24),

          // Danger zone
          _buildSettingTile(
            context,
            title: AppStrings.deleteAccount,
            subtitle: 'Permanently delete your account and data',
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.errorRed,
            titleColor: AppColors.errorRed,
            onTap: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.2)
                : AppColors.lightBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? AppColors.primaryBlue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor ??
                          (isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatGoal(int goal) {
    return goal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Set Daily Goal',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: 'steps',
            suffixStyle: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal >= 100 && goal <= 100000) {
                ref.read(dailyGoalProvider.notifier).state = goal;
                final repo = ref.read(stepsRepositoryProvider);
                repo.setDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repo = ref.read(authRepositoryProvider);
                await repo.deleteAccount();
                await ref.read(currentUserProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              } catch (e) {
                // Handle error
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
