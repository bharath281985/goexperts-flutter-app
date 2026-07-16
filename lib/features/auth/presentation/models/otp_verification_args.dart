class OtpVerificationArgs {
  const OtpVerificationArgs({
    required this.destination,
    this.countryCode,
    this.isPhone = false,
  });

  final String destination;
  final String? countryCode;
  final bool isPhone;

  String get displayDestination {
    if (isPhone && countryCode != null && countryCode!.isNotEmpty) {
      return '$countryCode $destination';
    }
    return destination;
  }
}
