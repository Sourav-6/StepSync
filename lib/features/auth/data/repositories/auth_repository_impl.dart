import 'package:step_sync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';
import 'package:step_sync/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of the AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = remoteDataSource.currentUser;
      if (user == null) return null;

      return await remoteDataSource.getUserModel(user.uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        return await remoteDataSource.getUserModel(user.uid);
      } catch (e) {
        // Fallback if unable to fetch full profile
        return UserEntity(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          profileImage: user.photoURL ?? '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
      }
    });
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      return await remoteDataSource.signInWithGoogle();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      return await remoteDataSource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(UserEntity)? onVerificationCompleted,
  }) async {
    try {
      await remoteDataSource.signInWithPhone(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
        onVerificationCompleted: onVerificationCompleted,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      return await remoteDataSource.verifyOtp(
        verificationId: verificationId,
        otp: otp,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final user = remoteDataSource.currentUser;
      if (user != null) {
        final data = <String, dynamic>{};
        if (name != null) data['name'] = name;
        if (phone != null) data['phone'] = phone;
        if (profileImage != null) data['profileImage'] = profileImage;
        await remoteDataSource.updateProfile(uid: user.uid, data: data);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<UserEntity>> getReferredUsers(String uid) async {
    try {
      return await remoteDataSource.getReferredUsers(uid);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
