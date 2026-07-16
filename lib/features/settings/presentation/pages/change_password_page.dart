import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Change password from Security Center.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await sl<AuthRepository>().changePassword(
      oldPassword: _oldPassword.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (message) {
        context.showSnack(message);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            Text(
              'Enter your current password and choose a new one.',
              style: context.text.bodyMedium,
            ),
            AppSizes.vGapXl,
            AppTextField(
              controller: _oldPassword,
              label: 'Current password',
              hint: 'Old password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Current password is required' : null,
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _newPassword,
              label: 'New password',
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.password,
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _confirmPassword,
              label: 'Confirm new password',
              hint: 'Re-enter new password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              validator: (v) =>
                  Validators.confirmPassword(v, _newPassword.text),
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
