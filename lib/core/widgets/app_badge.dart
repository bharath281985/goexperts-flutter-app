import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

/// Small count badge (e.g. unread notifications).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.count,
    this.color = AppColors.primary,
  });

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Verified check badge.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16, this.color = AppColors.info});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified_rounded, size: size, color: color);
  }
}
