import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import 'app_primary_button.dart';

/// Full-screen offline state with retry action.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 72, color: AppColors.warning.withValues(alpha: 0.9)),
                AppSizes.vGapLg,
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                AppSizes.vGapSm,
                Text(
                  'Please check your network settings. Cached data may still be available when you reconnect.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                AppSizes.vGapXl,
                AppPrimaryButton(label: 'Retry', onPressed: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
