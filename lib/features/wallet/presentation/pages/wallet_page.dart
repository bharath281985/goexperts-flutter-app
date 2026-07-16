import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../widgets/payment_card.dart';
import '../widgets/withdrawal_request_sheet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _listKey = 0;

  void _reload() => setState(() => _listKey++);

  @override
  Widget build(BuildContext context) {
    final repo = sl<WalletRepository>();
    final body = CatalogView<WalletTransaction>(
      key: ValueKey(_listKey),
      fetcher: repo.getTransactions,
      showSearch: false,
      skeletonHeight: 64,
      emptyTitle: 'No transactions yet',
      emptyIcon: Icons.receipt_long_outlined,
      separator: const Divider(height: 1),
      header: _WalletHeader(repo: repo, onWithdrawalSuccess: _reload),
      itemBuilder: (context, t, _) => AppPaymentCard(transaction: t),
    );
    if (widget.embedded) return body;
    return AppScaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: body,
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.repo, required this.onWithdrawalSuccess});
  final WalletRepository repo;
  final VoidCallback onWithdrawalSuccess;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.md,
        AppSizes.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: repo.getSummary(),
            builder: (context, snapshot) {
              final s =
                  snapshot.data?.valueOrNull ??
                  const WalletSummary(available: 0, pending: 0, lifetime: 0);
              return Column(
                children: [
                  _BalanceCard(summary: s),
                  AppSizes.vGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: _action(
                          context,
                          Icons.north_east_rounded,
                          'Withdraw',
                          () => _requestWithdrawal(context, s),
                        ),
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: _action(
                          context,
                          Icons.receipt_long_outlined,
                          'Invoices',
                          () => context.showSnack('Opening invoices'),
                        ),
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: _action(
                          context,
                          Icons.add_card_outlined,
                          'Add Money',
                          () => context.showSnack('Add money'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Recent Transactions'),
          AppSizes.vGapSm,
        ],
      ),
    );
  }

  Future<void> _requestWithdrawal(
    BuildContext context,
    WalletSummary summary,
  ) async {
    final message = await showWithdrawalRequestSheet(context, summary: summary);
    if (!context.mounted || message == null) return;
    context.showSnack(message);
    onWithdrawalSuccess();
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(label, style: context.text.labelMedium),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});
  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.currency(summary.available),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(
                child: _stat(
                  'Pending',
                  Formatters.compactCurrency(summary.pending),
                ),
              ),
              Expanded(
                child: _stat(
                  'In Escrow',
                  Formatters.compactCurrency(summary.escrow),
                ),
              ),
              Expanded(
                child: _stat(
                  'Lifetime',
                  Formatters.compactCurrency(summary.lifetime),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 11,
        ),
      ),
    ],
  );
}
