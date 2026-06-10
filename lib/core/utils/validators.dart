/// Input validators for form fields.
class Validators {
  Validators._();

  /// Validate email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password (minimum 6 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate confirm password matches password.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate name (not empty).
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate phone number.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate OTP (6 digits).
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.trim().length != 6 || int.tryParse(value.trim()) == null) {
      return 'Please enter a valid 6-digit OTP';
    }
    return null;
  }

  /// Validate step goal (positive integer).
  static String? stepGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Step goal is required';
    }
    final goal = int.tryParse(value.trim());
    if (goal == null || goal < 100) {
      return 'Step goal must be at least 100';
    }
    if (goal > 100000) {
      return 'Step goal cannot exceed 100,000';
    }
    return null;
  }
}
