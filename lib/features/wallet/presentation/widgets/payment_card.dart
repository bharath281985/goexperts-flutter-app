import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/wallet.dart';

/// Reusable transaction / payment row.
class AppPaymentCard extends StatelessWidget {
  const AppPaymentCard({super.key, required this.transaction, this.onTap});

  final WalletTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = _color();
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      leading: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(_icon(), color: color, size: AppSizes.iconSm),
      ),
      title: Text(transaction.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${Formatters.date(transaction.date)} · ${transaction.reference}', style: context.text.labelSmall),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${isCredit ? '+' : '-'}${Formatters.compactCurrency(transaction.amount)}',
              style: context.text.titleSmall?.copyWith(color: isCredit ? AppColors.success : AppColors.darkText)),
          Text(
            _capitalize(transaction.direction),
            style: context.text.labelSmall?.copyWith(
              color: _getDirectionColor(transaction.direction),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDirectionColor(String direction) {
    final dir = direction.toLowerCase();
    if (dir == 'rejected' || dir == 'pending' || dir == 'cancelled') {
      return AppColors.danger;
    }
    return AppColors.success;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Color _color() {
    switch (transaction.type) {
      case TransactionType.credit:
      case TransactionType.refund:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.info;
      case TransactionType.escrow:
        return AppColors.warning;
      case TransactionType.debit:
        return AppColors.danger;
    }
  }

  IconData _icon() {
    switch (transaction.type) {
      case TransactionType.credit:
        return Icons.south_west_rounded;
      case TransactionType.refund:
        return Icons.replay_rounded;
      case TransactionType.withdrawal:
        return Icons.north_east_rounded;
      case TransactionType.escrow:
        return Icons.lock_outline_rounded;
      case TransactionType.debit:
        return Icons.remove_rounded;
    }
  }
}
