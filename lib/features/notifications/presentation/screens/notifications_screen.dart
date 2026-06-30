import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/utils/formatters.dart';
import 'package:step_sync/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:step_sync/core/widgets/clay_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load notifications',
            style: GoogleFonts.inter(color: AppColors.errorRed),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_rounded,
                    size: 64,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ).animate().fadeIn().scale(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    'You are all caught up!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, delay: 400.ms),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (!notification.isRead) {
                      ref.read(markNotificationReadProvider)(notification.id);
                    }
                  },
                  child: ClayCard(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppDimensions.radiusLg,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getIconColor(notification.type).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _getIcon(notification.type),
                            color: _getIconColor(notification.type),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary).withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'star_deduction':
        return Icons.star_rounded;
      case 'friend_invite':
        return Icons.person_add_rounded;
      case 'message':
        return Icons.message_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'star_deduction':
        return AppColors.goldBadge;
      case 'friend_invite':
        return AppColors.secondaryTeal;
      case 'message':
        return AppColors.primaryBlue;
      default:
        return AppColors.accentOrange;
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
