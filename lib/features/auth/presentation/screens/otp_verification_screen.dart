import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_sync/core/constants/app_colors.dart';
import 'package:step_sync/core/constants/app_dimensions.dart';
import 'package:step_sync/core/constants/app_strings.dart';
import 'package:step_sync/core/widgets/custom_snackbar.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';
import 'package:step_sync/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:step_sync/core/utils/firebase_error_parser.dart';

/// OTP verification screen for phone authentication.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final bool isLinking;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
    this.isLinking = false,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  /// Normalize a phone number to E.164 format.
  String _normalizePhone(String raw) {
    // Strip spaces, dashes, parentheses
    String phone = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // If the number doesn't start with '+', assume Indian (+91)
    if (phone.isNotEmpty && !phone.startsWith('+')) {
      phone = '+91$phone';
    }
    return phone;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number if provided, but don't auto-send OTP
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.isEmpty) {
      CustomSnackBar.showError(context, AppStrings.phoneRequired);
      return;
    }
    ref.read(phoneAuthProvider.notifier).sendOtp(phone);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      CustomSnackBar.showError(context, 'Please enter a valid 6-digit OTP');
      return;
    }

    final user = await ref.read(phoneAuthProvider.notifier).verifyOtp(otp);
    if (user != null && mounted) {
      await ref.read(currentUserProvider.notifier).refresh();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phoneState = ref.watch(phoneAuthProvider);

    ref.listen<PhoneAuthState>(phoneAuthProvider, (_, next) async {
      if (next.error != null) {
        CustomSnackBar.showError(context, FirebaseErrorParser.parseAuthError(next.error!));
      }
      if (next.codeSent && next.user == null) {
        CustomSnackBar.showSuccess(context, 'OTP sent successfully!');
      }
      if (next.user != null) {
        await ref.read(currentUserProvider.notifier).refresh();
        if (mounted) {
          context.go('/home');
        }
      }
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
          onPressed: () async {
            ref.read(phoneAuthProvider.notifier).reset();
            if (widget.isLinking) {
              await ref.read(currentUserProvider.notifier).signOut();
            }
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  size: 32,
                  color: AppColors.secondaryTeal,
                ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 24),

              Text(
                phoneState.codeSent
                    ? AppStrings.verifyOtp
                    : AppStrings.signInWithPhone,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                phoneState.codeSent
                    ? '${AppStrings.otpSentTo}${_phoneController.text}'
                    : AppStrings.enterPhoneNumber,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),

              const SizedBox(height: 36),

              if (!phoneState.codeSent) ...[
                // Phone number input
                AuthTextField(
                  controller: _phoneController,
                  label: AppStrings.phoneNumber,
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  // Always allow editing so user can fix the number
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: phoneState.isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: phoneState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Send OTP',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // OTP input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _otpFocusNodes[index - 1].requestFocus();
                          }
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOtp();
                          }
                        },
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: phoneState.isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: phoneState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppStrings.verifyOtp,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: phoneState.isLoading ? null : _sendOtp,
                    child: Text(
                      AppStrings.resendOtp,
                      style: GoogleFonts.inter(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
