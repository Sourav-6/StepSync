import 'package:firebase_auth/firebase_auth.dart';

/// Utility to parse raw Firebase exceptions into friendly user messages.
class FirebaseErrorParser {
  static String parseAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getFriendlyMessage(error.code);
    }
    
    // Fallback if it's caught as a generic Exception but has a Firebase code inside the string
    final errorString = error.toString();
    if (errorString.contains('invalid-verification-code')) {
      return 'The OTP you entered is incorrect. Please check and try again.';
    } else if (errorString.contains('invalid-credential')) {
      return 'The login details are incorrect. Please try again.';
    } else if (errorString.contains('user-not-found')) {
      return 'No account found for this email. Please sign up.';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email-already-in-use')) {
      return 'An account already exists for this email.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    } else if (errorString.contains('invalid-phone-number')) {
      return 'The phone number you entered is invalid.';
    } else if (errorString.contains('quota-exceeded')) {
      return 'SMS quota exceeded. Please try again later.';
    } else if (errorString.contains('operation-not-allowed')) {
      return 'This login method is not enabled.';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('credential-already-in-use')) {
      return 'This phone number is already associated with another account.';
    } else if (errorString.contains('provider-already-linked')) {
      return 'This account is already linked to a phone number.';
    }

    // Default fallback
    return 'An unexpected error occurred. Please try again.';
  }

  static String _getFriendlyMessage(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'The OTP you entered is incorrect. Please check and try again.';
      case 'invalid-credential':
        return 'The login details are incorrect. Please try again.';
      case 'user-not-found':
        return 'No account found for this email. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'invalid-phone-number':
        return 'The phone number you entered is invalid.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'operation-not-allowed':
        return 'This login method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'credential-already-in-use':
        return 'This phone number is already associated with another account.';
      case 'provider-already-linked':
        return 'This account is already linked to a phone number.';
      default:
        return 'An error occurred during authentication. Please try again.';
    }
  }
}
