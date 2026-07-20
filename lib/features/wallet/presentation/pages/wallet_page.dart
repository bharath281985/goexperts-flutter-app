import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../widgets/add_money_sheet.dart';
import '../widgets/payment_card.dart';
import '../widgets/withdrawal_request_sheet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.embedded = false, this.refreshToken = 0});
  final bool embedded;
  final int refreshToken;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _listKey = 0;
  Future<Result<WalletSummary>>? _summaryFuture;
  late final WalletRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = sl<WalletRepository>();
    _summaryFuture = _repo.getSummary();
  }

  void _reload() {
    setState(() {
      _listKey++;
      _summaryFuture = _repo.getSummary();
    });
  }

  @override
  void didUpdateWidget(covariant WalletPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = CatalogView<WalletTransaction>(
      key: ValueKey(_listKey),
      fetcher: _repo.getTransactions,
      showSearch: false,
      skeletonHeight: 64,
      emptyTitle: 'No transactions yet',
      emptyIcon: Icons.receipt_long_outlined,
      separator: const Divider(height: 1),
      header: _WalletHeader(
        repo: _repo,
        summaryFuture: _summaryFuture ?? _repo.getSummary(),
        onWithdrawalSuccess: _reload,
      ),
      itemBuilder: (context, t, _) => AppPaymentCard(transaction: t),
      onRefresh: () async {
        final future = _repo.getSummary();
        setState(() {
          _summaryFuture = future;
        });
        await future;
      },
    );
    if (widget.embedded) return body;
    return AppScaffold(
      appBar: AppBar(title: Text(context.tr('Wallet'))),
      body: body,
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({
    required this.repo,
    required this.summaryFuture,
    required this.onWithdrawalSuccess,
  });
  final WalletRepository repo;
  final Future<Result<WalletSummary>> summaryFuture;
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
            future: summaryFuture,
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
                          () => context.push(Routes.freelancerInvoices),
                        ),
                      ),
                      if (context.select((AuthBloc b) => b.state.user?.role) ==
                          UserRole.client) ...[
                        AppSizes.hGapMd,
                        Expanded(
                          child: _action(
                            context,
                            Icons.add_card_outlined,
                            'Add Money',
                            () => _addMoney(context),
                          ),
                        ),
                      ],
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

  Future<void> _addMoney(BuildContext context) async {
    final message = await showAddMoneySheet(context);
    if (!context.mounted || message == null) return;
    context.showSnack(message);
    onWithdrawalSuccess();
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
          Text(context.tr(label), style: context.text.labelMedium),
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
            context.tr('Available Balance'),
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
                  context,
                  'Pending',
                  Formatters.compactCurrency(summary.pending),
                ),
              ),
              Expanded(
                child: _stat(
                  context,
                  'In Escrow',
                  Formatters.compactCurrency(summary.escrow),
                ),
              ),
              Expanded(
                child: _stat(
                  context,
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

  Widget _stat(BuildContext context, String label, String value) => Column(
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
        context.tr(label),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 11,
        ),
      ),
    ],
  );
}
