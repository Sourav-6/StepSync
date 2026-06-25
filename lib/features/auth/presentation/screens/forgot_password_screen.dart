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
import 'package:step_sync/core/widgets/clay_button.dart';

/// Forgot password screen to send reset email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(forgotPasswordProvider.notifier)
        .sendResetLink(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(forgotPasswordProvider);

    ref.listen<AsyncValue<bool>>(forgotPasswordProvider, (_, next) {
      next.when(
        data: (sent) {
          if (sent) {
            CustomSnackBar.showSuccess(
              context,
              'Password reset link sent! Check your email.',
            );
            ref.read(forgotPasswordProvider.notifier).reset();
            context.pop();
          }
        },
        loading: () {},
        error: (e, _) {
          CustomSnackBar.showError(context, e.toString());
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 32,
                    color: AppColors.accentOrange,
                  ),
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 24),

                Text(
                  AppStrings.forgotPassword.replaceAll('?', ''),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  AppStrings.forgotPasswordSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 36),

                AuthTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                ClayButton(
                  width: double.infinity,
                  height: 56,
                  onPressed: state.isLoading ? null : _sendResetLink,
                  color: AppColors.primaryBlue,
                  borderRadius: 16,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.sendResetLink,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
