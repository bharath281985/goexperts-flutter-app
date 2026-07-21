import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/constants/app_assets.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _email.text.trim();
    final result = await sl<ApiClientHelper>().postEnvelope<String>(
      ApiEndpoints.forgotPassword,
      body: {'email': email},
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Password reset OTP sent',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (message) {
        context.showSnack(message);
        context.push(Routes.resetPassword, extra: email);
      },
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
              // AppSizes.vGapLg,
              Text(
                context.tr('Reset password'),
                style: context.text.displaySmall,
              ),
              AppSizes.vGapXl,
              Text(
                context.tr(
                  'Enter your email and we will send you a verification code',
                ),
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              AppSizes.vGapXxxl,
              AppTextField(
                controller: _email,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: Validators.email,
                onSubmitted: (_) => _submit(),
              ),
              AppSizes.vGapXxxl,
              AppPrimaryButton(
                label: 'Send Code',
                isLoading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
