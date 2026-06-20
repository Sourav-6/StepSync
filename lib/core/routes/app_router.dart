import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:step_sync/features/auth/presentation/screens/login_screen.dart';
import 'package:step_sync/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:step_sync/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:step_sync/features/auth/presentation/screens/register_screen.dart';
import 'package:step_sync/features/auth/presentation/screens/splash_screen.dart';
import 'package:step_sync/features/home/presentation/screens/home_screen.dart';
import 'package:step_sync/features/history/presentation/screens/history_screen.dart';
import 'package:step_sync/features/groups/presentation/screens/groups_screen.dart';
import 'package:step_sync/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:step_sync/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:step_sync/features/profile/presentation/screens/profile_screen.dart';
import 'package:step_sync/features/profile/presentation/screens/settings_screen.dart';
import 'package:step_sync/features/friends/presentation/screens/friends_screen.dart';
import 'package:step_sync/features/friends/presentation/screens/friends_leaderboard_screen.dart';
import 'package:step_sync/features/friends/presentation/screens/invite_friends_screen.dart';
import 'package:step_sync/features/profile/presentation/screens/my_referrals_screen.dart';

/// GoRouter configuration for StepSync navigation.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // ─── Auth Routes ───
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            phoneNumber: extra?['phone'] as String?,
            isLinking: extra?['isLinking'] as bool? ?? false,
          );
        },
      ),

      // ─── Main App (Shell with Bottom Navigation) ───
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/groups',
            builder: (context, state) => const GroupsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ─── Settings & Edit Routes ───
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/my-referrals',
        builder: (context, state) => const MyReferralsScreen(),
      ),

      // ─── Friends Routes ───
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/friends/leaderboard',
        builder: (context, state) => const FriendsLeaderboardScreen(),
      ),
      GoRoute(
        path: '/friends/invite',
        builder: (context, state) => const InviteFriendsScreen(),
      ),
    ],
  );
});

/// Main shell widget with bottom navigation bar.
class _MainShell extends StatelessWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: location == '/home',
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.leaderboard_rounded,
                  label: 'Leaderboard',
                  isSelected: location == '/leaderboard',
                  onTap: () => context.go('/leaderboard'),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'History',
                  isSelected: location == '/history',
                  onTap: () => context.go('/history'),
                ),
                _NavItem(
                  icon: Icons.groups_rounded,
                  label: 'Groups',
                  isSelected: location == '/groups',
                  onTap: () => context.go('/groups'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: location == '/profile',
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item with selection animation.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primaryBlue
                  : (isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
