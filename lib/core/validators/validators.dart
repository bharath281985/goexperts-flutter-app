import '../extensions/string_extensions.dart';

/// Reusable form field validators returning null when valid.
class Validators {
  Validators._();

  static String? required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v.isNullOrEmpty) return 'Email is required';
    if (!v!.isValidEmail) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? v) {
    if (v.isNullOrEmpty) return 'Mobile number is required';
    if (!RegExp(r'^\d{7,15}$').hasMatch(v!.trim())) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  static String? countryCode(String? v) {
    if (v.isNullOrEmpty) return 'Country code is required';
    if (!RegExp(r'^\+[1-9]\d{0,3}$').hasMatch(v!.trim())) {
      return 'Enter a valid country code';
    }
    return null;
  }

  static String? password(String? v) {
    if (v.isNullOrEmpty) return 'Password is required';
    if (v!.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v.isNullOrEmpty) return 'Confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? minLength(String? v, int min, {String field = 'This field'}) {
    if (v == null || v.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? url(String? v) {
    if (v.isNullOrEmpty) return null; // optional
    if (!v!.isValidUrl) return 'Enter a valid URL';
    return null;
  }

}
