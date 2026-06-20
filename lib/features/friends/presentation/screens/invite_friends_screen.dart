import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/friends/presentation/providers/friends_provider.dart';

/// Screen for inviting friends via referral code or share link.
class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  ConsumerState<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  final TextEditingController _referralController = TextEditingController();

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final referralCodeAsync = ref.watch(referralCodeProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.inviteFriends,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Referral Code Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.yourReferralCode,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Referral code display
                  referralCodeAsync.when(
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => Text(
                      'Error generating code',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    data: (code) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        code,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Copy & Share buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlassButton(
                        icon: Icons.copy_rounded,
                        label: AppStrings.copyCode,
                        onTap: () {
                          final code = referralCodeAsync.valueOrNull ?? '';
                          if (code.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.codeCopied)),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildGlassButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () {
                          final code = referralCodeAsync.valueOrNull ?? '';
                          Share.share('${AppStrings.inviteMessage}$code');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 32),

            // ─── Share Invite Link ───
            Text(
              AppStrings.shareInviteLink,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildShareOption(
              isDark: isDark,
              icon: Icons.message_rounded,
              label: 'Share via Message',
              color: AppColors.successGreen,
              onTap: () {
                final code = referralCodeAsync.valueOrNull ?? '';
                Share.share('${AppStrings.inviteMessage}$code');
              },
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.03),

            _buildShareOption(
              isDark: isDark,
              icon: Icons.link_rounded,
              label: 'Copy Invite Link',
              color: AppColors.primaryBlue,
              onTap: () {
                final code = referralCodeAsync.valueOrNull ?? '';
                Clipboard.setData(
                  ClipboardData(text: 'https://stepsync.app/invite?code=$code'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.03),

            _buildShareOption(
              isDark: isDark,
              icon: Icons.qr_code_rounded,
              label: 'Share QR Code',
              color: AppColors.accentOrange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code feature coming soon!')),
                );
              },
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.03),

            const SizedBox(height: 32),

            // ─── Enter Referral Code ───
            Text(
              AppStrings.enterReferralCode,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter a friend\'s code to connect',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _referralController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ENTER CODE',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                          color: isDark
                              ? AppColors.textDarkSecondary.withValues(alpha: 0.5)
                              : AppColors.textLightSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () async {
                        if (_referralController.text.isEmpty || user == null) return;

                        final success = await ref
                            .read(friendActionProvider.notifier)
                            .applyReferral(user.uid, _referralController.text.trim());

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? AppStrings.referralApplied
                                  : 'Invalid referral code. Please try again.',
                            ),
                          ),
                        );
                        if (success) {
                          _referralController.clear();
                          ref.refresh(friendsListProvider);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
