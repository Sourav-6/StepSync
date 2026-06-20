import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/auth/data/models/user_model.dart';

/// Remote data source wrapping Firebase Auth and Firestore for user operations.
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Get the current Firebase user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ─── Google Sign-In ───

  /// Sign in with Google and return the UserModel.
  Future<UserModel> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;

    // Check if user document exists, create if not
    return _getOrCreateUser(
      uid: user.uid,
      name: user.displayName ?? 'Google User',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      profileImage: user.photoURL ?? '',
    );
  }

  // ─── Email Authentication ───

  /// Sign in with email and password.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;

    // Update last login
    await _updateLastLogin(user.uid);
    return getUserModel(user.uid);
  }

  /// Sign up with email and password.
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;

    // Update Firebase display name
    await user.updateDisplayName(name);
    
    // Resolve referral code
    String? referredBy = await _resolveReferralCode(referralCode);

    // Create Firestore document
    return _getOrCreateUser(
      uid: user.uid,
      name: name,
      email: email,
      referredBy: referredBy,
    );
  }

  // ─── Phone Authentication ───

  /// Send OTP to phone number.
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(UserModel user)? onVerificationCompleted,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final currentUser = _firebaseAuth.currentUser;
          UserCredential userCredential;

          if (currentUser != null) {
            try {
              userCredential = await currentUser.linkWithCredential(credential);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'provider-already-linked') {
                userCredential = await _firebaseAuth.signInWithCredential(credential);
              } else {
                rethrow;
              }
            }
          } else {
            userCredential = await _firebaseAuth.signInWithCredential(credential);
          }

          final user = userCredential.user!;
          final userModel = await _getOrCreateUser(
            uid: user.uid,
            name: user.displayName ?? 'Phone User',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
          );
          await _markPhoneVerified(user.uid, user.phoneNumber ?? '');

          if (onVerificationCompleted != null) {
            onVerificationCompleted(userModel);
          }
        } catch (e) {
          onError(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Verify OTP and sign in.
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final currentUser = _firebaseAuth.currentUser;
    UserCredential userCredential;

    if (currentUser != null) {
      // User is already signed in (e.g. Email/Google). Link phone credential.
      try {
        userCredential = await currentUser.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await _markPhoneVerified(currentUser.uid, currentUser.phoneNumber ?? '');
          return _getOrCreateUser(
            uid: currentUser.uid,
            name: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
            phone: currentUser.phoneNumber ?? '',
          );
        } else {
          rethrow;
        }
      }
      final user = userCredential.user!;
      final userModel = await _getOrCreateUser(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
      );
      await _markPhoneVerified(user.uid, user.phoneNumber ?? '');
      return userModel;
    } else {
      userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;
      final userModel = await _getOrCreateUser(
        uid: user.uid,
        name: 'Phone User',
        email: '',
        phone: user.phoneNumber ?? '',
      );
      await _markPhoneVerified(user.uid, user.phoneNumber ?? '');
      return userModel;
    }
  }

  /// Mark user's phone as verified in Firestore.
  Future<void> _markPhoneVerified(String uid, String phone) async {
    final Map<String, dynamic> updates = {
      FirestorePaths.fieldPhoneVerified: true,
    };
    if (phone.isNotEmpty) {
      updates[FirestorePaths.fieldPhone] = phone;
    }
    await _firestore.collection(FirestorePaths.users).doc(uid).update(updates);
  }

  // ─── Password Reset ───

  /// Send password reset email.
  Future<void> forgotPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification.
  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  // ─── Sign Out ───

  /// Sign out from all providers.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ─── Profile Update ───

  /// Update user profile fields.
  Future<void> updateProfile({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    if (data != null && data.isNotEmpty) {
      await _firestore.collection(FirestorePaths.users).doc(uid).update(data);
    }
  }

  /// Delete user account.
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      final uid = user.uid;
      
      try {
        // 1. Delete all daily_steps documents for this user
        final stepsQuery = await _firestore
            .collection(FirestorePaths.dailySteps)
            .where(FirestorePaths.fieldUid, isEqualTo: uid)
            .get();
            
        // Use a batch to delete all documents efficiently
        final batch = _firestore.batch();
        for (final doc in stepsQuery.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        // 2. Delete firestore user document
        await _firestore.collection(FirestorePaths.users).doc(uid).delete();
        
        // 3. Delete auth account
        await user.delete();
      } catch (e) {
        // Fallback: If user.delete() fails (requires recent login), 
        // we should rethrow to show an error to the user
        rethrow;
      }
    }
  }

  // ─── Helper Methods ───

  /// Get or create a user document in Firestore.
  Future<UserModel> _getOrCreateUser({
    required String uid,
    required String name,
    required String email,
    String phone = '',
    String profileImage = '',
    String? referredBy,
  }) async {
    final docRef = _firestore.collection(FirestorePaths.users).doc(uid);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      // Update last login and phone if provided
      final Map<String, dynamic> updates = {
        FirestorePaths.fieldLastLogin: FieldValue.serverTimestamp(),
      };
      if (phone.isNotEmpty) {
        updates[FirestorePaths.fieldPhone] = phone;
      }
      await docRef.update(updates);
      final updatedSnap = await docRef.get();
      return UserModel.fromFirestore(updatedSnap);
    } else {
      // Create new user document
      final newUser = UserModel.newUser(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
        referredBy: referredBy,
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    }
  }

  /// Resolve referral code to UID.
  Future<String?> _resolveReferralCode(String? referralCode) async {
    if (referralCode == null || referralCode.trim().isEmpty) return null;
    
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.users)
          .where(FirestorePaths.fieldReferralCode, isEqualTo: referralCode.trim().toUpperCase())
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      // Ignore errors for referral resolution
    }
    return null;
  }

  /// Get UserModel from Firestore.
  Future<UserModel> getUserModel(String uid) async {
    final docSnap =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();
    return UserModel.fromFirestore(docSnap);
  }

  /// Update last login timestamp.
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      FirestorePaths.fieldLastLogin: FieldValue.serverTimestamp(),
    });
  }

  /// Get users referred by a specific uid.
  Future<List<UserModel>> getReferredUsers(String uid) async {
    final querySnapshot = await _firestore
        .collection(FirestorePaths.users)
        .where(FirestorePaths.fieldReferredBy, isEqualTo: uid)
        .get();
        
    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }
}
