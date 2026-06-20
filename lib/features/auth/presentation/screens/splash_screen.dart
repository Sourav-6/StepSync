import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/services/hive_service.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';

/// Animated splash screen with a minimal GPay-style design.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Show splash animation for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check Firebase Auth directly — this is synchronous and reliable
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userRepo = ref.read(authRepositoryProvider);
      final userEntity = await userRepo.getCurrentUser();
      
      if (userEntity != null) {
        if (userEntity.phoneVerified) {
          if (mounted) context.go('/home');
        } else {
          if (mounted) context.go('/otp', extra: {'isLinking': true});
        }
      } else {
        await ref.read(currentUserProvider.notifier).signOut();
        if (mounted) context.go('/login');
      }
    } else if (HiveService.onboardingComplete) {
      // User has seen onboarding before, go to login
      if (mounted) context.go('/login');
    } else {
      // First time user, show onboarding
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimal, flat logo icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                size: 50,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            // Clean app name
            Text(
              AppStrings.appName,
              style: GoogleFonts.rubik(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
