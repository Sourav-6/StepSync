import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/features/profile/presentation/providers/my_referrals_provider.dart';

class MyReferralsScreen extends ConsumerWidget {
  const MyReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final referralsAsync = ref.watch(myReferralsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Referrals',
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
      body: referralsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load referrals',
            style: GoogleFonts.inter(
              color: AppColors.errorRed,
            ),
          ),
        ),
        data: (referrals) {
          if (referrals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    size: 64,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ).animate().fadeIn().scale(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No Referrals Yet',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Share your code with friends\nand earn rewards!',
                    textAlign: TextAlign.center,
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
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final user = referrals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                      backgroundImage: user.profileImage.isNotEmpty
                          ? NetworkImage(user.profileImage)
                          : null,
                      child: user.profileImage.isEmpty
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: GoogleFonts.outfit(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Joined: ${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: -0.05);
            },
          );
        },
      ),
    );
  }
}
