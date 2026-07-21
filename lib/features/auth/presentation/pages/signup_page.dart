import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/phone_validation.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_scaffold.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _countryCode = '+91';
  String _countryIsoCode = 'IN';
  String _countryName = 'India';
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      context.showSnack(
        'Please accept the Terms & Privacy Policy',
        isError: true,
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignupDraftSaved(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        countryCode: _countryCode,
        password: _password.text,
      ),
    );
    context.go('${Routes.roleSelection}?from=signup');
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Join thousands of professionals on Go Experts',
      showBack: true,
      backAlignment: Alignment.topLeft,
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) =>
            context.showSnack(state.errorMessage!, isError: true),
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _name,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => Validators.minLength(v, 3, field: 'Name'),
                ),
                AppSizes.vGapLg,
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AppSizes.vGapLg,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 132,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Country', style: context.text.titleSmall),
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
                              showFlag: false,
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
                        label: 'Mobile',
                        hint: 'Enter your mobile number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
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
                AppSizes.vGapLg,
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: Validators.password,
                ),
                AppSizes.vGapLg,
                AppTextField(
                  controller: _confirm,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                ),
                AppSizes.vGapSm,
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: context.text.bodySmall,
                          children: const [
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AppSizes.vGapMd,
                Wrap(
                  spacing: AppSizes.sm,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.push(Routes.emailVerification),
                      icon: const Icon(Icons.mail_outline_rounded, size: 16),
                      label: const Text('Verify Email'),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(Routes.phoneVerification),
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: const Text('Verify Phone'),
                    ),
                  ],
                ),
                AppSizes.vGapSm,
                AppPrimaryButton(
                  label: 'Continue',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                AppSizes.vGapLg,
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: context.text.bodySmall,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
