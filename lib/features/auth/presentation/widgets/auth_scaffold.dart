import 'package:flutter/material.dart';
import '../../../../app/constants/app_assets.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/responsive_wrapper.dart';

/// Shared scaffold for auth screens: branded header + card body.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
    this.backAlignment = Alignment.centerLeft,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;
  final AlignmentGeometry backAlignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        leading: showBack
            ? Align(
                alignment: backAlignment,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Text(context.tr(title), style: context.text.displaySmall),
                AppSizes.vGapXs,
                Text(context.tr(subtitle), style: context.text.bodyMedium),
                AppSizes.vGapXl,
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
