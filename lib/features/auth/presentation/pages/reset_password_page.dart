import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';

/// Set a new password after OTP verification.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await sl<ApiClientHelper>().postEnvelope<String>(
      ApiEndpoints.resetPassword,
      body: {
        'email': _email.text.trim(),
        'otp': _otp.text.trim(),
        'newPassword': _password.text,
      },
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Password reset successfully',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (message) {
        context.showSnack(message);
        context.go(Routes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Create a new password for your account.',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _email,
              label: 'Email',
              hint: 'Email address',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              validator: Validators.email,
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _otp,
              label: 'OTP',
              hint: 'Enter verification code',
              prefixIcon: Icons.password_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return context.tr('OTP is required');
                if (value.length != 6) {
                  return context.tr('Enter the 6-digit code');
                }
                return null;
              },
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _password,
              label: 'New password',
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.next,
              validator: Validators.password,
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _confirm,
              label: 'Confirm password',
              hint: 'Re-enter new password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.confirmPassword(v, _password.text),
              onSubmitted: (_) => _submit(),
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(
              label: 'Update Password',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
