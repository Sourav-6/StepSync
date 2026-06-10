import 'package:step_sync/features/auth/domain/entities/user_entity.dart';

/// Abstract repository interface for authentication operations.
/// Defined in the domain layer; implemented in the data layer.
abstract class AuthRepository {
  /// Get the currently authenticated user, or null if not signed in.
  Future<UserEntity?> getCurrentUser();

  /// Stream of auth state changes.
  Stream<UserEntity?> authStateChanges();

  /// Sign in with Google.
  Future<UserEntity> signInWithGoogle();

  /// Sign in with email and password.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Sign in with phone number (sends OTP).
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  });

  /// Verify OTP for phone authentication.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otp,
  });

  /// Send password reset email.
  Future<void> forgotPassword({required String email});

  /// Send email verification.
  Future<void> sendEmailVerification();

  /// Sign out.
  Future<void> signOut();

  /// Update user profile.
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  });

  /// Delete user account.
  Future<void> deleteAccount();
}
