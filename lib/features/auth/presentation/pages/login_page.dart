import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_login_row.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to continue to ${AppStrings.appName}',
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
                  controller: _email,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: Validators.email,
                ),
                AppSizes.vGapLg,
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) => Validators.required(v, field: 'Password'),
                ),
                AppSizes.vGapSm,
                Row(
                  children: [
                    Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(context.tr(AppStrings.rememberMe)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push(Routes.forgotPassword),
                      child: Text(context.tr(AppStrings.forgotPassword)),
                    ),
                  ],
                ),
                AppSizes.vGapMd,
                AppPrimaryButton(
                  label: AppStrings.login,
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                AppSizes.vGapLg,
                const SocialLoginRow(),
                AppSizes.vGapLg,
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr("Don't have an account?"),
                        style: context.text.bodySmall,
                      ),
                      TextButton(
                        onPressed: () => context.push(Routes.signup),
                        child: Text(
                          context.tr('Create Account'),
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
