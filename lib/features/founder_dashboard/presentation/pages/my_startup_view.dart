import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../startup_ideas/domain/entities/startup.dart';
import '../../../startup_ideas/domain/repositories/startup_repository.dart';
import '../../../startup_ideas/presentation/pages/startups_list_view.dart';
import '../../domain/repositories/founder_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

/// Founder's own startup management view (embeddable tab).
class MyStartupView extends StatefulWidget {
  const MyStartupView({super.key});

  @override
  State<MyStartupView> createState() => _MyStartupViewState();
}

class _MyStartupViewState extends State<MyStartupView> {
  bool _loading = true;
  Map<String, dynamic> _startup = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final res = await api.get<dynamic>(
      ApiEndpoints.founderStartup,
      parser: (raw) => raw,
    );

    if (!mounted) return;

    Map<String, dynamic> startupData = const {};
    final rawData = res.valueOrNull;

    if (rawData is List && rawData.isNotEmpty) {
      final firstItem = Map<String, dynamic>.from(rawData.first as Map);
      final id = firstItem['id']?.toString();
      if (id != null && id.isNotEmpty) {
        final detailRes = await api.get<Map<String, dynamic>>(
          '${ApiEndpoints.founderStartup}/$id',
          parser: (raw) => Map<String, dynamic>.from(raw as Map),
        );
        if (detailRes.isSuccess) {
          startupData = detailRes.valueOrNull ?? const {};
        } else {
          startupData = firstItem;
        }
      } else {
        startupData = firstItem;
      }
    } else if (rawData is Map) {
      final mapData = Map<String, dynamic>.from(rawData);
      final id = mapData['id']?.toString();
      if (mapData['bids'] == null && id != null && id.isNotEmpty) {
        final detailRes = await api.get<Map<String, dynamic>>(
          '${ApiEndpoints.founderStartup}/$id',
          parser: (raw) => Map<String, dynamic>.from(raw as Map),
        );
        if (detailRes.isSuccess) {
          startupData = detailRes.valueOrNull ?? const {};
        } else {
          startupData = mapData;
        }
      } else {
        startupData = mapData;
      }
    }

    _startup = startupData;
    setState(() => _loading = false);
  }

  Future<void> _editStartup() async {
    if (_startup.isEmpty || _startup['id'] == null) {
      context.showSnack('No startup data to edit', isError: true);
      return;
    }

    final startup = Startup.fromApiJson(_startup);

    final data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditIdeaBottomSheet(startup: startup),
    );

    if (data == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = sl<StartupRepository>();
    final res = await repo.updateIdea(startup.id, data);

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading spinner

    res.fold((f) => context.showSnack(f.message, isError: true), (_) {
      context.showSnack('Startup updated successfully');
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final name = _startup['startupName']?.toString().trim().isNotEmpty == true
        ? _startup['startupName'].toString()
        : (_startup['startup']?.toString() ??
              _startup['name']?.toString() ??
              'Startup');
    final tagline =
        _startup['tagline']?.toString() ??
        _startup['industry']?.toString() ??
        '';
    final logoUrl =
        _startup['logo']?.toString() ??
        _startup['logoUrl']?.toString() ??
        (_startup['user'] is Map
            ? (_startup['user'] as Map)['avatarUrl']?.toString()
            : null);
    final goal = (_startup['funding'] as num?)?.toDouble() ?? 1;
    final equity = (_startup['equity'] as num?)?.toDouble() ?? 0;

    final bidsList = _startup['bids'] as List? ?? [];
    final bids = bidsList
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    final bidsSum = bids.fold<double>(
      0.0,
      (sum, b) =>
          sum +
          (num.tryParse(b['offer']?.toString() ?? '0')?.toDouble() ?? 0.0),
    );

    final raised = bidsSum;

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
                IconButton(
                  onPressed: _editStartup,
                  icon: const Icon(Icons.edit_outlined),
                ),
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
                    Expanded(
                      child: _stat(
                        context,
                        'Raised',
                        Formatters.compactCurrency(raised),
                      ),
                    ),
                    Expanded(
                      child: _stat(
                        context,
                        'Goal',
                        Formatters.compactCurrency(goal),
                      ),
                    ),
                    Expanded(
                      child: _stat(
                        context,
                        'Equity',
                        '${equity.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Startup Assets'),
          AppSizes.vGapSm,
          if (_startup['pitchDeck'] != null || _startup['pitchDeckUrl'] != null)
            _asset(
              context,
              Icons.slideshow_outlined,
              'Pitch Deck',
              'Available',
            ),
          if (_startup['businessPlan'] != null ||
              _startup['businessPlanUrl'] != null)
            _asset(
              context,
              Icons.description_outlined,
              'Business Plan',
              'Available',
            ),
          if ((_startup['pitchDeck'] == null &&
                  _startup['pitchDeckUrl'] == null) &&
              (_startup['businessPlan'] == null &&
                  _startup['businessPlanUrl'] == null))
            const AppCard(child: Text('No assets uploaded yet')),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Investor Requests'),
          AppSizes.vGapSm,
          if (bids.isEmpty)
            const AppCard(child: Text('No investor requests yet')),
          for (final r in bids)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              onTap: () async {
                final id = r['id']?.toString();
                if (id != null && id.isNotEmpty) {
                  await context.push('${Routes.proposalDetails}/$id');
                  _load();
                }
              },
              child: Row(
                children: [
                  AppAvatar(
                    name:
                        r['investorProfile']?['fullName']?.toString() ??
                        'Investor',
                    imageUrl: r['investorProfile']?['avatarUrl']?.toString(),
                    size: 42,
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['investorProfile']?['fullName']?.toString() ??
                              'Investor',
                          style: context.text.titleSmall,
                        ),
                        Text(
                          '${Formatters.compactCurrency(num.tryParse(r['offer']?.toString() ?? '0')?.toDouble() ?? 0)} · ${num.tryParse(r['equity']?.toString() ?? '0')?.toDouble().toStringAsFixed(0)}% equity',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusOrActions(r),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOrActions(Map<String, dynamic> r) {
    final statusStr = r['status']?.toString().toLowerCase() ?? 'pending';
    if (statusStr == 'accepted' || statusStr == 'accept') {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          'Accepted',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (statusStr == 'rejected' || statusStr == 'reject') {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          'Rejected',
          style: TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _respond(r['id']?.toString() ?? '', 'accept'),
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        IconButton(
          onPressed: () => _respond(r['id']?.toString() ?? '', 'reject'),
          icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
        ),
      ],
    );
  }

  Future<void> _respond(String id, String action) async {
    final res = await sl<FounderRepository>().respondToRequest(id, action);
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Request updated'),
    );
    await _load();
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: context.text.titleSmall),
      Text(label, style: context.text.labelSmall),
    ],
  );

  Widget _asset(
    BuildContext context,
    IconData icon,
    String title,
    String meta,
  ) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSizes.sm),
    padding: const EdgeInsets.all(AppSizes.md),
    onTap: () => context.showSnack('Opening $title'),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
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
