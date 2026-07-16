import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';

/// Set a new password after OTP verification.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.showSnack('Password updated. Please sign in.');
    context.go(Routes.login);
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
              controller: _password,
              label: 'New password',
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.password,
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _confirm,
              label: 'Confirm password',
              hint: 'Re-enter new password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: (v) => Validators.confirmPassword(v, _password.text),
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(label: 'Update Password', isLoading: _loading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
