import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../../catalog/presentation/widgets/detail_widgets.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<WalletTransaction>(
      title: 'Transaction',
      fetcher: () => sl<WalletRepository>().getTransaction(id),
      actions: detailActions(
        context,
        shareTitle: 'this transaction',
        shareLink: '${Routes.transactionDetails}/$id',
        reportType: 'transaction',
        bookmarkable: false,
      ),
      bottomBar: (context, t) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppSecondaryButton(
          label: 'Download Receipt',
          icon: Icons.download_rounded,
          onPressed: () => context.showSnack('Downloading receipt'),
        ),
      ),
      builder: (context, t) {
        final color = t.isCredit ? AppColors.success : AppColors.danger;
        return ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      t.isCredit
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: color,
                      size: 30,
                    ),
                  ),
                  AppSizes.vGapMd,
                  Text(
                    '${t.isCredit ? '+' : '-'}${Formatters.currency(t.amount)}',
                    style: context.text.headlineMedium?.copyWith(color: color),
                  ),
                  AppSizes.vGapXs,
                  Text(
                    t.title,
                    style: context.text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            AppSizes.vGapLg,
            AppCard(
              child: Column(
                children: [
                  _row(
                    context,
                    'Type',
                    t.type.name[0].toUpperCase() + t.type.name.substring(1),
                  ),
                  const Divider(height: AppSizes.lg),
                  _row(context, 'Date', Formatters.dateTime(t.date)),
                  const Divider(height: AppSizes.lg),
                  _row(
                    context,
                    'Reference',
                    t.reference.isEmpty ? '—' : t.reference,
                  ),
                  const Divider(height: AppSizes.lg),
                  _row(context, 'Status', t.status),
                ],
              ),
            ),
            AppSizes.vGapLg,
            DetailSection(
              title: 'Activity',
              child: DetailTimeline(
                events: [
                  const TimelineEvent('Transaction initiated', done: true),
                  const TimelineEvent(
                    'Processed by payment gateway',
                    done: true,
                  ),
                  TimelineEvent(
                    '${t.status} · funds settled',
                    subtitle: Formatters.dateTime(t.date),
                    done: t.status == 'Completed',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        );
      },
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
    children: [
      Text(label, style: context.text.labelMedium),
      const Spacer(),
      Flexible(
        child: Text(
          value,
          style: context.text.bodyMedium,
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
