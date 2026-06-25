import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/utils/validators.dart';
import 'package:step_sync/core/widgets/custom_snackbar.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:step_sync/features/auth/presentation/widgets/social_login_button.dart';
import 'package:step_sync/core/utils/firebase_error_parser.dart';
import 'package:step_sync/core/widgets/clay_button.dart';

/// Login screen with email/password, Google, and phone auth options.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        if (user.phone.isNotEmpty && user.phoneVerified) {
          context.go('/home');
        } else {
          context.go('/otp', extra: {'isLinking': true});
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, FirebaseErrorParser.parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.notifier).signInWithGoogle();
      if (mounted) {
        if (user.phone.isNotEmpty && user.phoneVerified) {
          context.go('/home');
        } else {
          context.go('/otp', extra: {'isLinking': true});
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, FirebaseErrorParser.parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // App Banner
                Center(
                  child: Image.asset(
                    'assets/images/app_banner.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  AppStrings.welcomeBack,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: 8),

                Text(
                  AppStrings.loginSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: 40),

                // Email field
                AuthTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: '••••••••',
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.password,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: GoogleFonts.inter(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign in button
                ClayButton(
                  width: double.infinity,
                  height: 56,
                  onPressed: _isLoading ? null : _signInWithEmail,
                  color: AppColors.primaryBlue,
                  borderRadius: 16,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.signIn,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.orContinueWith,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Social login buttons
                SocialLoginButton(
                  label: AppStrings.signInWithGoogle,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                const SizedBox(height: 12),

                SocialLoginButton(
                  label: AppStrings.signInWithPhone,
                  icon: Icons.phone_rounded,
                  onPressed: _isLoading
                      ? null
                      : () => context.push('/otp', extra: {'isLinking': false}),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => context.push('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.dontHaveAccount,
                        style: GoogleFonts.inter(
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUp,
                            style: GoogleFonts.inter(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
