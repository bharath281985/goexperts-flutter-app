import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneValidation {
  PhoneValidation._();

  static int requiredLength(String countryIsoCode) {
    switch (countryIsoCode.toUpperCase()) {
      case 'IN':
        return 10;
      default:
        return 15;
    }
  }

  static String counterText({
    required String value,
    required String countryIsoCode,
  }) {
    return '${_digits(value).length}/${requiredLength(countryIsoCode)}';
  }

  static String? validateMobile({
    required String? value,
    required String countryIsoCode,
    required String countryName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final digits = _digits(value);
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Enter digits only';
    }

    if (countryIsoCode.toUpperCase() == 'IN') {
      if (digits.length != 10) {
        return 'India mobile number must be 10 digits';
      }
      if (!RegExp(r'^[6-9]').hasMatch(digits)) {
        return 'India mobile number must start with 6, 7, 8 or 9';
      }
      return null;
    }

    try {
      final isoCode = IsoCode.values.byName(countryIsoCode);
      final phoneNumber = PhoneNumber.parse(
        digits,
        callerCountry: isoCode,
        destinationCountry: isoCode,
      );
      if (!phoneNumber.isValidLength(type: PhoneNumberType.mobile)) {
        return 'Enter a valid mobile number for $countryName';
      }
    } catch (_) {
      if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
        return 'Enter a valid mobile number';
      }
    }

    return null;
  }

  static String trimToRequiredLength(String value, String countryIsoCode) {
    final digits = _digits(value);
    final max = requiredLength(countryIsoCode);
    if (digits.length <= max) return digits;
    return digits.substring(0, max);
  }

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');
}
