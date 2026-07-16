import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/entities/founder.dart';
import '../../domain/repositories/founder_repository.dart';

/// Founder's own startup management view (embeddable tab).
class MyStartupView extends StatefulWidget {
  const MyStartupView({super.key});

  @override
  State<MyStartupView> createState() => _MyStartupViewState();
}

class _MyStartupViewState extends State<MyStartupView> {
  bool _loading = true;
  Map<String, dynamic> _startup = const {};
  Map<String, dynamic> _funding = const {};
  List<InvestorRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final startup = await api.get<Map<String, dynamic>>(
      ApiEndpoints.founderStartup,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final funding = await api.get<Map<String, dynamic>>(
      ApiEndpoints.founderFunding,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final requests = await sl<FounderRepository>().getInvestorRequests(const QueryParams(pageSize: 10));
    if (!mounted) return;
    _startup = startup.valueOrNull ?? const {};
    _funding = funding.valueOrNull ?? const {};
    _requests = requests.valueOrNull?.items ?? const [];
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final name = _startup['startupName']?.toString().trim().isNotEmpty == true
        ? _startup['startupName'].toString()
        : (_startup['name']?.toString() ?? 'Startup');
    final tagline = _startup['tagline']?.toString() ??
        _startup['industry']?.toString() ??
        '';
    final logoUrl = _startup['logoUrl']?.toString() ??
        (_startup['user'] is Map
            ? (_startup['user'] as Map)['avatarUrl']?.toString()
            : null);
    final raised = (_funding['raised'] as num?)?.toDouble() ??
        (_startup['fundingRaised'] as num?)?.toDouble() ??
        0;
    final goal = (_funding['goal'] as num?)?.toDouble() ??
        (_startup['fundingRequired'] as num?)?.toDouble() ??
        1;
    final equity = (_startup['equityOffered'] as num?)?.toDouble() ?? 0;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        AppCard(
          child: Row(
            children: [
              AppAvatar(name: name, imageUrl: logoUrl, size: 56),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.text.titleMedium),
                    Text(tagline, style: context.text.bodySmall),
                  ],
                ),
              ),
              IconButton(onPressed: () => context.showSnack('Edit startup'), icon: const Icon(Icons.edit_outlined)),
            ],
          ),
        ),
        AppSizes.vGapLg,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(title: 'Funding'),
              AppSizes.vGapMd,
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: goal == 0 ? 0 : (raised / goal).clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: context.theme.dividerColor,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
              AppSizes.vGapMd,
              Row(
                children: [
                  Expanded(child: _stat(context, 'Raised', Formatters.compactCurrency(raised))),
                  Expanded(child: _stat(context, 'Goal', Formatters.compactCurrency(goal))),
                  Expanded(child: _stat(context, 'Equity', '${equity.toStringAsFixed(0)}%')),
                ],
              ),
            ],
          ),
        ),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Startup Assets'),
        AppSizes.vGapSm,
        _asset(context, Icons.slideshow_outlined, 'Pitch Deck', '312 views'),
        _asset(context, Icons.description_outlined, 'Business Plan', 'Updated 3d ago'),
        _asset(context, Icons.table_chart_outlined, 'Cap Table', '4 shareholders'),
        _asset(context, Icons.insights_outlined, 'Financial Projections', 'FY24–FY27'),
        _asset(context, Icons.photo_library_outlined, 'Media Gallery', '8 items'),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Investor Requests'),
        AppSizes.vGapSm,
        if (_requests.isEmpty)
          const AppCard(child: Text('No investor requests yet')),
        for (final r in _requests)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: [
                AppAvatar(name: r.investorName, imageUrl: r.investorAvatar, size: 42),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.investorName, style: context.text.titleSmall),
                      Text('${Formatters.compactCurrency(r.amount)} · ${r.equity.toStringAsFixed(0)}% equity', style: context.text.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _respond(r.id, 'accept'),
                  icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                ),
                IconButton(
                  onPressed: () => _respond(r.id, 'reject'),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                ),
              ],
            ),
          ),
      ],
    ));
  }

  Future<void> _respond(String id, String action) async {
    final res = await sl<FounderRepository>().respondToRequest(id, action);
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message), (_) => context.showSnack('Request updated'));
    await _load();
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.text.titleSmall),
          Text(label, style: context.text.labelSmall),
        ],
      );

  Widget _asset(BuildContext context, IconData icon, String title, String meta) => AppCard(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        onTap: () => context.showSnack('Opening $title'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  Text(meta, style: context.text.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
          ],
        ),
      );
}
