import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:step_sync/core/constants/firestore_paths.dart';
import 'package:step_sync/features/auth/data/models/user_model.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';

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
  }) async {
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;

    // Update Firebase display name
    await user.updateDisplayName(name);

    // Create Firestore document
    return _getOrCreateUser(
      uid: user.uid,
      name: name,
      email: email,
    );
  }

  // ─── Phone Authentication ───

  /// Send OTP to phone number.
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution for Android
        await _firebaseAuth.signInWithCredential(credential);
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

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;

    return _getOrCreateUser(
      uid: user.uid,
      name: 'Phone User',
      email: '',
      phone: user.phoneNumber ?? '',
    );
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
  }) async {
    final docRef = _firestore.collection(FirestorePaths.users).doc(uid);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      // Update last login
      await _updateLastLogin(uid);
      return UserModel.fromFirestore(docSnap);
    } else {
      // Create new user document
      final newUser = UserModel.newUser(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    }
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
}
