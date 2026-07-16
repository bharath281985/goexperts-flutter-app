import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_assets.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/phone_validation.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/otp_verification_args.dart';

/// Phone verification entry screen before OTP.
class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  String _countryCode = '+91';
  String _countryIsoCode = 'IN';
  String _countryName = 'India';
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _setCountryCode(CountryCode countryCode) {
    setState(() {
      _countryCode = countryCode.dialCode ?? '+91';
      _countryIsoCode = countryCode.code ?? 'IN';
      _countryName = countryCode.name ?? 'India';
      _phone.text = PhoneValidation.trimToRequiredLength(
        _phone.text,
        _countryIsoCode,
      );
    });
    _formKey.currentState?.validate();
  }

  String? _validatePhone(String? value) => PhoneValidation.validateMobile(
        value: value,
        countryIsoCode: _countryIsoCode,
        countryName: _countryName,
      );

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phone.text.trim();
    setState(() => _loading = true);

    final result = await sl<AuthRepository>().sendOtp(
      phone: phone,
      countryCode: _countryCode,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) => context.push(
        Routes.otp,
        extra: OtpVerificationArgs(
          destination: phone,
          countryCode: _countryCode,
          isPhone: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppSizes.vGapXs,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: Image.asset(
                  AppAssets.logo,
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Text('Verify your phone', style: context.text.displaySmall),
              AppSizes.vGapXl,
              Text(
                'Enter your mobile number to receive OTP.',
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              AppSizes.vGapXxl,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code', style: context.text.titleSmall),
                        AppSizes.vGapSm,
                        InputDecorator(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: AppSizes.md,
                            ),
                          ),
                          child: CountryCodePicker(
                            initialSelection: _countryIsoCode,
                            onInit: (countryCode) {
                              if (countryCode == null) return;
                              _countryCode = countryCode.dialCode ?? '+91';
                              _countryIsoCode = countryCode.code ?? 'IN';
                              _countryName = countryCode.name ?? 'India';
                            },
                            onChanged: _setCountryCode,
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            showDropDownButton: false,
                            alignLeft: true,
                            padding: EdgeInsets.zero,
                            flagWidth: 24,
                            textStyle: context.text.bodyMedium,
                            dialogTextStyle: context.text.bodyMedium,
                            searchDecoration: const InputDecoration(
                              hintText: 'Search country',
                            ),
                            builder: (countryCode) =>
                                _CountryCodeButton(countryCode: countryCode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.hGapSm,
                  Expanded(
                    child: AppTextField(
                      controller: _phone,
                      label: 'Mobile number',
                      hint: 'Enter your mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          PhoneValidation.requiredLength(_countryIsoCode),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: _validatePhone,
                    ),
                  ),
                ],
              ),
              AppSizes.vGapXs,
              Padding(
                padding: const EdgeInsets.only(left: 140),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    PhoneValidation.counterText(
                      value: _phone.text,
                      countryIsoCode: _countryIsoCode,
                    ),
                    style: context.text.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
              AppSizes.vGapXxxl,
              AppPrimaryButton(
                label: 'Send OTP',
                isLoading: _loading,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({required this.countryCode});

  final CountryCode? countryCode;

  @override
  Widget build(BuildContext context) {
    final code = countryCode;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          if (code?.flagUri != null) ...[
            Image.asset(
              code!.flagUri!,
              package: 'country_code_picker',
              width: 24,
            ),
            AppSizes.hGapXs,
          ],
          Expanded(
            child: Text(
              code?.dialCode ?? '+91',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: AppSizes.iconSm),
        ],
      ),
    );
  }
}
