import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/services/hive_service.dart';

/// Onboarding screen with 3 swipeable pages introducing the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.directions_walk_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      backgroundColor: const Color(0xFFE3F2FD),
      iconColor: AppColors.primaryBlue,
    ),
    _OnboardingData(
      icon: Icons.people_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      backgroundColor: const Color(0xFFE0F2F1),
      iconColor: AppColors.secondaryTeal,
    ),
    _OnboardingData(
      icon: Icons.emoji_events_rounded,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      backgroundColor: const Color(0xFFFFF3E0),
      iconColor: AppColors.accentOrange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await HiveService.setOnboardingComplete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: GoogleFonts.inter(
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with gradient background
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: isDark ? page.iconColor.withValues(alpha: 0.15) : page.backgroundColor,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: page.iconColor,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            )
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots & Buttons
            Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryBlue
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for onboarding page content.
class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color iconColor;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.iconColor,
  });
}
