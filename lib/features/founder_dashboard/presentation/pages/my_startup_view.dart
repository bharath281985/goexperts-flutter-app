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
  const MyStartupView({super.key, this.id});
  final String? id;

  @override
  State<MyStartupView> createState() => _MyStartupViewState();
}

class _MyStartupViewState extends State<MyStartupView> {
  bool _loading = true;
  Map<String, dynamic> _startup = const {};
  List<Map<String, dynamic>> _bids = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MyStartupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!_loading) {
      setState(() => _loading = true);
    }
    final api = sl<ApiClientHelper>();
    Map<String, dynamic> startupData = const {};

    if (widget.id != null && widget.id!.isNotEmpty) {
      final detailRes = await api.get<Map<String, dynamic>>(
        '${ApiEndpoints.founderStartup}/${widget.id}',
        parser: (raw) => Map<String, dynamic>.from(raw as Map),
      );
      if (detailRes.isSuccess) {
        startupData = detailRes.valueOrNull ?? const {};
      }
    } else {
      final res = await api.get<dynamic>(
        ApiEndpoints.founderStartup,
        parser: (raw) => raw,
      );

      if (!mounted) return;

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
    }

    if (!mounted) return;
    _startup = startupData;

    // Fetch bids/investor-requests
    final List<Map<String, dynamic>> bidsData = [];
    final embedded = startupData['bids'] as List?;
    if (embedded != null) {
      bidsData.addAll(
        embedded.whereType<Map>().map((x) => Map<String, dynamic>.from(x)),
      );
    }

    final bidsRes = await api.getEnvelope<List<Map<String, dynamic>>>(
      ApiEndpoints.founderInvestorRequests,
      query: widget.id != null
          ? {'ideaId': widget.id, 'startupId': widget.id}
          : null,
      parser: (env) {
        final list = env.data as List?;
        if (list == null) return const [];
        return list
            .whereType<Map>()
            .map((x) => Map<String, dynamic>.from(x))
            .where((x) {
              if (widget.id == null || widget.id!.isEmpty) return true;
              final targetId = widget.id!.toLowerCase();
              final reqStartupId =
                  (x['startupId'] ??
                          x['startup_id'] ??
                          x['ideaId'] ??
                          x['idea_id'] ??
                          x['startup']?['id'] ??
                          x['idea']?['id'])
                      ?.toString()
                      .toLowerCase();
              return reqStartupId == null || reqStartupId == targetId;
            })
            .toList();
      },
    );

    if (bidsRes.isSuccess) {
      final fetched = bidsRes.valueOrNull ?? const [];
      for (final item in fetched) {
        final bidId = item['id']?.toString();
        if (bidId != null &&
            !bidsData.any((x) => x['id']?.toString() == bidId)) {
          bidsData.add(item);
        }
      }
    }

    _bids = bidsData;
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
    final startup = _startup.isNotEmpty ? Startup.fromApiJson(_startup) : null;
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

    final bids = _bids;

    final bidsSum = bids.fold<double>(
      0.0,
      (sum, b) =>
          sum +
          (num.tryParse(
                b['offer']?.toString() ?? b['amount']?.toString() ?? '0',
              )?.toDouble() ??
              0.0),
    );

    final raised = bidsSum;
    final percentFunded = goal == 0 ? 0.0 : (raised / goal);
    final percentText = '${(percentFunded * 100).toStringAsFixed(0)}% funded';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: AppSizes.lg,
        ),
        children: [
          // Founder Startup card header
          AppCard(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 2.5,
                    ),
                  ),
                  child: AppAvatar(name: name, imageUrl: logoUrl, size: 60),
                ),
                AppSizes.hGapLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tagline,
                        style: context.text.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: context.theme.scaffoldBackgroundColor,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _editStartup,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.sm + 2),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,

          // Funding stats card
          AppCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Funding Progress',
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                        child: Text(
                          percentText,
                          style: context.text.labelMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSizes.vGapMd,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: goal == 0 ? 0 : (raised / goal).clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: context.theme.dividerColor.withValues(
                        alpha: 0.4,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.success,
                      ),
                    ),
                  ),
                  AppSizes.vGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: _stat(
                          context,
                          'Raised',
                          Formatters.compactCurrency(raised),
                          Icons.trending_up_rounded,
                          AppColors.success,
                        ),
                      ),
                      Container(
                        height: 38,
                        width: 1,
                        color: context.theme.dividerColor.withValues(
                          alpha: 0.4,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                      ),
                      Expanded(
                        child: _stat(
                          context,
                          'Goal Ask',
                          Formatters.compactCurrency(goal),
                          Icons.payments_outlined,
                          AppColors.primary,
                        ),
                      ),
                      Container(
                        height: 38,
                        width: 1,
                        color: context.theme.dividerColor.withValues(
                          alpha: 0.4,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                      ),
                      Expanded(
                        child: _stat(
                          context,
                          'Equity',
                          '${equity.toStringAsFixed(0)}%',
                          Icons.pie_chart_outline_rounded,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Startup Assets'),
          AppSizes.vGapSm,
          if (startup != null &&
              (startup.pitchDeckUrl != null &&
                  startup.pitchDeckUrl!.isNotEmpty))
            _asset(
              context,
              Icons.slideshow_outlined,
              'Pitch Deck',
              'Available',
              startup.pitchDeckUrl,
            ),
          if (startup != null &&
              (startup.businessPlanUrl != null &&
                  startup.businessPlanUrl!.isNotEmpty))
            _asset(
              context,
              Icons.description_outlined,
              'Business Plan',
              'Available',
              startup.businessPlanUrl,
            ),
          if (startup == null ||
              ((startup.pitchDeckUrl == null ||
                      startup.pitchDeckUrl!.isEmpty) &&
                  (startup.businessPlanUrl == null ||
                      startup.businessPlanUrl!.isEmpty)))
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
                        r['investorName']?.toString() ??
                        'Investor',
                    imageUrl:
                        r['investorProfile']?['avatarUrl']?.toString() ??
                        r['investorAvatar']?.toString(),
                    size: 42,
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['investorProfile']?['fullName']?.toString() ??
                              r['investorName']?.toString() ??
                              'Investor',
                          style: context.text.titleSmall,
                        ),
                        Text(
                          '${Formatters.compactCurrency(num.tryParse(r['offer']?.toString() ?? r['amount']?.toString() ?? '0')?.toDouble() ?? 0)} · ${num.tryParse(r['equity']?.toString() ?? '0')?.toDouble().toStringAsFixed(0)}% equity',
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: const Text(
          'Accepted',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
    if (statusStr == 'rejected' || statusStr == 'reject') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: const Text(
          'Rejected',
          style: TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    final id = r['id']?.toString() ?? '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: id.isEmpty ? null : () => _respond(id, 'accept'),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 26,
          ),
          tooltip: 'Accept Proposal',
        ),
        IconButton(
          onPressed: id.isEmpty ? null : () => _respond(id, 'reject'),
          icon: const Icon(
            Icons.cancel_rounded,
            color: AppColors.danger,
            size: 26,
          ),
          tooltip: 'Reject Proposal',
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

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _asset(
    BuildContext context,
    IconData icon,
    String title,
    String meta,
    String? url,
  ) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSizes.sm),
    padding: const EdgeInsets.all(AppSizes.md),
    onTap: () {
      if (url != null && url.isNotEmpty) {
        final type = title.toLowerCase().contains('deck') ? 'PDF' : 'PDF';
        context.push(
          '${Routes.documentViewer}?url=${Uri.encodeComponent(url)}&name=${Uri.encodeComponent(title)}&type=$type',
        );
      } else {
        context.showSnack('Document URL is not available', isError: true);
      }
    },
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
