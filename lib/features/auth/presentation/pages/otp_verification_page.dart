import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_assets.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/otp_verification_args.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key, this.args});

  final OtpVerificationArgs? args;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _seconds = 30;

  OtpVerificationArgs get _args =>
      widget.args ?? const OtpVerificationArgs(destination: '');

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (_seconds > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _seconds--);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _verify() async {
    if (_otpCode.length != 6) {
      context.showSnack('Enter the 6-digit code', isError: true);
      return;
    }

    setState(() => _loading = true);
    final result = await sl<AuthRepository>().verifyOtp(
      code: _otpCode,
      phone: _args.isPhone ? _args.destination : null,
      countryCode: _args.isPhone ? _args.countryCode : null,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        context.showSnack('Verified successfully');
        context.go(Routes.resetPassword);
      },
    );
  }

  Future<void> _resend() async {
    if (!_args.isPhone ||
        _args.destination.isEmpty ||
        (_args.countryCode ?? '').isEmpty) {
      setState(() {
        _seconds = 30;
        _tick();
      });
      return;
    }

    final result = await sl<AuthRepository>().sendOtp(
      phone: _args.destination,
      countryCode: _args.countryCode!,
    );
    if (!mounted) return;

    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        context.showSnack('OTP sent again');
        setState(() {
          _seconds = 30;
          _tick();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = _args.displayDestination.isNotEmpty
        ? _args.displayDestination
        : 'your email';

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
            Text('Verify code', style: context.text.displaySmall),
            AppSizes.vGapXl,
            Text(
              'Enter the 6-digit code sent to $destination',
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            AppSizes.vGapXxxl,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 6; i++)
                  SizedBox(
                    width: 46,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: context.text.titleLarge,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                        if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                      },
                    ),
                  ),
              ],
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(
              label: 'Verify',
              isLoading: _loading,
              onPressed: _verify,
            ),
            AppSizes.vGapLg,
            Center(
              child: _seconds > 0
                  ? Text(
                      'Resend code in ${_seconds}s',
                      style: context.text.bodySmall,
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
