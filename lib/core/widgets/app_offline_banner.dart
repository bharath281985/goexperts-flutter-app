import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';

/// Thin banner shown when the device is offline. Wire visibility to
/// connectivity state / an offline queue later.
class AppOfflineBanner extends StatelessWidget {
  const AppOfflineBanner({super.key, this.pendingCount = 0, this.onRetry});

  final int pendingCount;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
            AppSizes.hGapSm,
            Expanded(
              child: Text(
                pendingCount > 0
                    ? "You're offline · $pendingCount change(s) queued"
                    : "You're offline",
                style: const TextStyle(fontSize: 12, color: AppColors.darkText),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry Sync')),
          ],
        ),
      ),
    );
  }
}
