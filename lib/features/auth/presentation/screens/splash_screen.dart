import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/services/hive_service.dart';

/// Animated splash screen with logo and auto-navigation.
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
      // User is already signed in, go straight to home
      if (mounted) context.go('/home');
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              Color(0xFF1A1A2E),
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                size: 60,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // App name
            Text(
              AppStrings.appName,
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
              AppStrings.appTagline,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textDarkSecondary,
                letterSpacing: 1,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryLight.withValues(alpha: 0.7),
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
