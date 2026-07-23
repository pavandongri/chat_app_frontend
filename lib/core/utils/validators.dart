/// Shared form validation rules for the auth screens (Login, Signup, Verify
/// OTP, Forgot/Reset Password). Centralized so validation stays consistent
/// across all six screens instead of being redefined per form.
class Validators {
  Validators._();

  static final RegExp _emailPattern =
      RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _otpPattern = RegExp(r'^\d{6}$');
  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (!_usernamePattern.hasMatch(value.trim())) {
      return '3-20 letters, numbers, or underscores';
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a gender';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String? Function() password,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password()) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the code sent to your email';
    }
    if (!_otpPattern.hasMatch(value.trim())) {
      return 'Enter the 6-digit code';
    }
    return null;
  }
}
