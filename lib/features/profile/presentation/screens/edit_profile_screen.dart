import 'package:flutter/material.dart';
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
import 'package:step_sync/core/widgets/clay_card.dart';

/// Edit profile screen with name, phone, and photo editing.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await ref.read(currentUserProvider.notifier).refresh();
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Profile updated!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.editProfile,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar placeholder
              ClayCard(
                width: 100,
                height: 100,
                borderRadius: 28,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {
                  // Image picker integration
                  CustomSnackBar.showInfo(context, 'Image picker will open here');
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  AppStrings.changePhoto,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 32),

              AuthTextField(
                controller: _nameController,
                label: AppStrings.fullName,
                hint: 'Your name',
                prefixIcon: Icons.person_outlined,
                validator: Validators.name,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              AuthTextField(
                controller: _phoneController,
                label: AppStrings.phoneNumber,
                hint: '+91 9876543210',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),

              const SizedBox(height: 40),

              ClayButton(
                width: double.infinity,
                height: 56,
                onPressed: _isLoading ? null : _saveProfile,
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
                        AppStrings.save,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
