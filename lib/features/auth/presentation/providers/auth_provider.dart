import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:step_sync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';
import 'package:step_sync/core/services/hive_service.dart';
import 'package:step_sync/features/auth/domain/repositories/auth_repository.dart';
import 'package:step_sync/features/steps/data/repositories/steps_repository_impl.dart' as step_sync_repo;

/// Provider for the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource());
});

/// Stream provider for auth state changes (logged in / logged out).
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Provider for the current user data.
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserEntity?>>((ref) {
  return CurrentUserNotifier(ref.watch(authRepositoryProvider));
});

/// State notifier managing the current user state.
class CurrentUserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  CurrentUserNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _restoreDailySteps(String uid) async {
    // Restore today's steps from Firestore into Hive so the pedometer 
    // doesn't start from 0 if the local cache was wiped.
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final stepsRepo = step_sync_repo.StepsRepositoryImpl();
      final dailySteps = await stepsRepo.getDailySteps(uid, dateStr);
      if (dailySteps != null && dailySteps.steps > 0) {
        await stepsRepo.cacheSteps(dateStr, dailySteps.steps);
      }
    } catch (e) {
      // Ignore restore errors, pedometer will just start from 0
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        await _restoreDailySteps(user.uid);
      }
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign in with Google.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithGoogle();
      await _restoreDailySteps(user.uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      await _restoreDailySteps(user.uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign up with email and password.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      await HiveService.clearAll(); // Wipe local data on logout/delete
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh user data from Firestore.
  Future<void> refresh() async {
    await _loadCurrentUser();
  }
}

/// Provider for phone auth state.
final phoneAuthProvider =
    StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>((ref) {
  return PhoneAuthNotifier(ref.watch(authRepositoryProvider));
});

/// Phone authentication state.
class PhoneAuthState {
  final bool isLoading;
  final bool codeSent;
  final String? verificationId;
  final String? error;
  final UserEntity? user;

  const PhoneAuthState({
    this.isLoading = false,
    this.codeSent = false,
    this.verificationId,
    this.error,
    this.user,
  });

  PhoneAuthState copyWith({
    bool? isLoading,
    bool? codeSent,
    String? verificationId,
    String? error,
    UserEntity? user,
  }) {
    return PhoneAuthState(
      isLoading: isLoading ?? this.isLoading,
      codeSent: codeSent ?? this.codeSent,
      verificationId: verificationId ?? this.verificationId,
      error: error,
      user: user ?? this.user,
    );
  }
}

/// State notifier for phone authentication flow.
class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  final AuthRepository _repository;

  PhoneAuthNotifier(this._repository) : super(const PhoneAuthState());

  /// Send OTP to phone number.
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    await _repository.signInWithPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        state = state.copyWith(
          isLoading: false,
          codeSent: true,
          verificationId: verificationId,
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );
  }

  /// Verify OTP.
  Future<UserEntity?> verifyOtp(String otp) async {
    if (state.verificationId == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.verifyOtp(
        verificationId: state.verificationId!,
        otp: otp,
      );
      state = state.copyWith(isLoading: false, user: user);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Reset state.
  void reset() {
    state = const PhoneAuthState();
  }
}

/// Provider for forgot password.
final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, AsyncValue<bool>>((ref) {
  return ForgotPasswordNotifier(ref.watch(authRepositoryProvider));
});

/// State notifier for forgot password flow.
class ForgotPasswordNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  ForgotPasswordNotifier(this._repository)
      : super(const AsyncValue.data(false));

  Future<void> sendResetLink(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.forgotPassword(email: email);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

/// Provider for theme mode.
final themeModeProvider = StateProvider<bool>((ref) {
  return true; // Default to dark mode
});
