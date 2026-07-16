import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../../catalog/presentation/widgets/detail_widgets.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class InvoiceDetailsPage extends StatelessWidget {
  const InvoiceDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<Invoice>(
      title: 'Invoice',
      fetcher: () => sl<WalletRepository>().getInvoice(id),
      actions: detailActions(context, shareTitle: 'this invoice', shareLink: '${Routes.invoiceDetails}/$id', reportType: 'invoice', bookmarkable: false),
      bottomBar: (context, inv) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Expanded(child: AppSecondaryButton(label: 'Download', icon: Icons.download_rounded, onPressed: () => context.showSnack('Downloading PDF'))),
            AppSizes.hGapMd,
            Expanded(flex: 2, child: AppPrimaryButton(label: inv.status == 'Paid' ? 'View Receipt' : 'Pay Now', icon: Icons.payments_outlined, onPressed: () => context.showSnack(inv.status == 'Paid' ? 'Opening receipt' : 'Opening payment'))),
          ],
        ),
      ),
      builder: (context, inv) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.receipt_long_outlined,
            title: inv.number,
            subtitle: inv.party,
            chips: [DetailStatChip(icon: Icons.circle, label: inv.status)],
          ),
          AppSizes.vGapLg,
          AppCard(
            child: Column(
              children: [
                _row(context, 'Amount', Formatters.currency(inv.amount), emphasize: true),
                const Divider(height: AppSizes.lg),
                _row(context, 'Billed to', inv.party),
                const Divider(height: AppSizes.lg),
                _row(context, 'Issued on', Formatters.date(inv.issuedAt)),
                const Divider(height: AppSizes.lg),
                _row(context, 'Status', inv.status),
              ],
            ),
          ),
          AppSizes.vGapLg,
          DetailSection(
            title: 'Line Items',
            child: AppCard(
              child: Column(
                children: [
                  _lineItem(context, 'Professional services', inv.amount * 0.9),
                  const Divider(height: AppSizes.lg),
                  _lineItem(context, 'Platform fee', inv.amount * 0.1),
                  const Divider(height: AppSizes.lg),
                  Row(children: [
                    Text('Total', style: context.text.titleSmall),
                    const Spacer(),
                    Text(Formatters.currency(inv.amount), style: context.text.titleMedium?.copyWith(color: AppColors.primary)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool emphasize = false}) => Row(
        children: [
          Text(label, style: context.text.labelMedium),
          const Spacer(),
          Text(value, style: emphasize ? context.text.titleMedium?.copyWith(color: AppColors.primary) : context.text.bodyMedium),
        ],
      );

  Widget _lineItem(BuildContext context, String label, double amount) => Row(
        children: [
          Expanded(child: Text(label, style: context.text.bodyMedium)),
          Text(Formatters.currency(amount), style: context.text.bodyMedium),
        ],
      );
}
