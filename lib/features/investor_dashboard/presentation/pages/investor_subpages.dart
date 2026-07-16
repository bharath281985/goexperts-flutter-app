import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_multi_select.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class InvestorPreferencesPage extends StatefulWidget {
  const InvestorPreferencesPage({super.key});
  @override
  State<InvestorPreferencesPage> createState() => _InvestorPreferencesPageState();
}

class _InvestorPreferencesPageState extends State<InvestorPreferencesPage> {
  static const _industries = ['FinTech', 'HealthTech', 'EdTech', 'AI', 'SaaS', 'E-Commerce', 'CleanTech', 'AgriTech', 'Manufacturing', 'MSME'];
  static const _stages = ['Idea', 'Prototype', 'MVP', 'Early Revenue', 'Growth', 'Expansion'];
  static const _roles = ['Working Partner', 'Sleeping Partner', 'Strategic Partner', 'Mentor Investor'];

  Set<String> _selIndustries = {'FinTech', 'SaaS', 'AI'};
  Set<String> _selStages = {'MVP', 'Early Revenue'};
  String _role = 'Strategic Partner';
  RangeValues _ticket = const RangeValues(2500000, 50000000);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Investment Preferences'), actions: [TextButton(onPressed: () => context.showSnack('Preferences saved'), child: const Text('Save'))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          AppMultiSelect(label: 'Interested industries', options: _industries, selected: _selIndustries, onChanged: (s) => setState(() => _selIndustries = s)),
          AppSizes.vGapLg,
          AppMultiSelect(label: 'Preferred stages', options: _stages, selected: _selStages, onChanged: (s) => setState(() => _selStages = s)),
          AppSizes.vGapLg,
          Text('Partner role', style: context.text.titleSmall),
          AppSizes.vGapSm,
          Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: [
            for (final r in _roles)
              ChoiceChip(label: Text(r), selected: _role == r, onSelected: (_) => setState(() => _role = r)),
          ]),
          AppSizes.vGapLg,
          Text('Ticket size: ${Formatters.compactCurrency(_ticket.start)} — ${Formatters.compactCurrency(_ticket.end)}', style: context.text.titleSmall),
          RangeSlider(
            values: _ticket,
            min: 500000,
            max: 300000000,
            onChanged: (v) => setState(() => _ticket = v),
          ),
        ],
      ),
    );
  }
}

class InvestorDueDiligencePage extends StatefulWidget {
  const InvestorDueDiligencePage({super.key});
  @override
  State<InvestorDueDiligencePage> createState() => _InvestorDueDiligencePageState();
}

class _InvestorDueDiligencePageState extends State<InvestorDueDiligencePage> {
  final _items = <String, bool>{
    'Review pitch deck': true,
    'Verify cap table': true,
    'Financial statements audit': false,
    'Founder background check': true,
    'Legal & IP verification': false,
    'Customer references': false,
    'Market validation': true,
  };

  @override
  Widget build(BuildContext context) {
    final done = _items.values.where((v) => v).length;
    return AppScaffold(
      appBar: AppBar(title: const Text('Due Diligence')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$done of ${_items.length} completed', style: context.text.titleSmall),
              AppSizes.vGapSm,
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: done / _items.length, minHeight: 8, backgroundColor: context.theme.dividerColor, valueColor: const AlwaysStoppedAnimation(AppColors.success)),
              ),
            ]),
          ),
          AppSizes.vGapLg,
          for (final e in _items.entries)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: CheckboxListTile(
                value: e.value,
                onChanged: (v) => setState(() => _items[e.key] = v ?? false),
                title: Text(e.key),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}

class InvestorOffersPage extends StatelessWidget {
  const InvestorOffersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final offers = [
      ('FarmLink', '₹1.5Cr for 8%', 'Pending'),
      ('MediSync', '₹4Cr for 12%', 'Countered'),
      ('EduSpark', '₹5Cr for 10%', 'Accepted'),
    ];
    return AppScaffold(
      appBar: AppBar(title: const Text('Offers')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          for (final (startup, terms, status) in offers)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(children: [
                const Icon(Icons.local_offer_outlined, color: AppColors.primary),
                AppSizes.hGapMd,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(startup, style: context.text.titleSmall),
                  Text(terms, style: context.text.labelSmall),
                ])),
                AppStatusChip(label: status, dense: true, color: status == 'Accepted' ? AppColors.success : (status == 'Countered' ? AppColors.warning : AppColors.info)),
              ]),
            ),
        ],
      ),
    );
  }
}

class InvestorDocumentsPage extends StatelessWidget {
  const InvestorDocumentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final docs = [
      ('FarmLink Pitch Deck.pdf', 'PDF'),
      ('MediSync Financials.xlsx', 'Excel'),
      ('EduSpark NDA.pdf', 'PDF'),
      ('Term Sheet.docx', 'DOCX'),
    ];
    return AppScaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          for (final (name, type) in docs)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              onTap: () => context.push('${Routes.documentViewer}?type=$type&name=$name'),
              child: Row(children: [
                const Icon(Icons.description_outlined, color: AppColors.primary),
                AppSizes.hGapMd,
                Expanded(child: Text(name, style: context.text.bodyMedium)),
                Text(type, style: context.text.labelSmall),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
              ]),
            ),
        ],
      ),
    );
  }
}

class InvestorTransactionsPage extends StatelessWidget {
  const InvestorTransactionsPage({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: CatalogView<WalletTransaction>(
          fetcher: (q) => sl<WalletRepository>().getTransactions(q),
          searchHint: 'Search transactions…',
          itemBuilder: (context, t, __) => AppCard(
            onTap: () => context.push('${Routes.transactionDetails}/${t.id}'),
            child: Row(children: [
              Icon(t.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded, color: t.isCredit ? AppColors.success : AppColors.danger),
              AppSizes.hGapMd,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(Formatters.date(t.date), style: context.text.labelSmall),
              ])),
              Text('${t.isCredit ? '+' : '-'}${Formatters.compactCurrency(t.amount)}', style: context.text.titleSmall?.copyWith(color: t.isCredit ? AppColors.success : AppColors.danger)),
            ]),
          ),
        ),
      );
}
