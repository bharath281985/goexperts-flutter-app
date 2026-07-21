import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/bookmark_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/entities/startup.dart';
import '../../domain/repositories/startup_repository.dart';
import '../../../../core/utils/result.dart';

class StartupDetailsPage extends StatefulWidget {
  const StartupDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
  late final Future<Result<Startup>> _future;
  bool? _hasInvestedOverride;
  bool? _isSavedOverride;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _future = sl<StartupRepository>().getStartup(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkManager.instance,
      builder: (context, _) {
        return FutureBuilder<Result<Startup>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: const Text('Startup Details')),
                body: const AppLoadingShimmer(itemCount: 4, height: 120),
              );
            }
            final s = snapshot.data?.valueOrNull;
            if (s == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Startup Details')),
                body: const AppErrorState(),
              );
            }

            final isSaved = _isSavedOverride ?? s.isSaved;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Startup Details'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => context.showSnack('Link copied'),
                  ),
                  IconButton(
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isSaved ? AppColors.primary : null,
                    ),
                    onPressed: () async {
                      if (_isLoadingAction) return;
                      setState(() => _isSavedOverride = !isSaved);

                      final repo = sl<StartupRepository>();
                      final res = await repo.toggleSave(widget.id);

                      if (mounted) {
                        res.fold(
                          (f) {
                            setState(() => _isSavedOverride = isSaved);
                            context.showSnack(f.message, isError: true);
                          },
                          (success) {
                            BookmarkManager.instance.toggle(
                              BookmarkManager.categoryStartups,
                              widget.id,
                            );
                            context.showSnack(
                              !isSaved ? 'Saved startup' : 'Removed from saved',
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              body: _content(context, s),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: 'Message',
                          icon: Icons.chat_bubble_outline_rounded,
                          onPressed: () {
                            print("founderId: ${s.founderId}");
                            if (s.founderId != null &&
                                s.founderId!.isNotEmpty) {
                              final nameEncoded = Uri.encodeComponent(
                                s.founderName,
                              );
                              final avatarEncoded = Uri.encodeComponent(
                                s.founderAvatar ?? '',
                              );
                              context.push(
                                '${Routes.chat}/${s.founderId}?name=$nameEncoded&avatarUrl=$avatarEncoded',
                              );
                            } else {
                              final nameEncoded = Uri.encodeComponent(s.name);
                              final avatarEncoded = Uri.encodeComponent(
                                s.logoUrl ?? '',
                              );
                              context.push(
                                '${Routes.chat}/su_${widget.id}?name=$nameEncoded&avatarUrl=$avatarEncoded',
                              );
                            }
                          },
                        ),
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        flex: 2,
                        child: AppPrimaryButton(
                          label: (_hasInvestedOverride ?? s.hasInvested)
                              ? 'Withdraw Interest'
                              : 'Invest / Express Interest',
                          icon: (_hasInvestedOverride ?? s.hasInvested)
                              ? Icons.cancel_outlined
                              : Icons.trending_up_rounded,
                          isLoading: _isLoadingAction,
                          backgroundColor:
                              (_hasInvestedOverride ?? s.hasInvested)
                              ? AppColors.danger
                              : AppColors.primary,
                          onPressed: () async {
                            if (_hasInvestedOverride ?? s.hasInvested) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Withdraw Interest'),
                                  content: const Text(
                                    'Are you sure you want to withdraw your interest in this startup?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Withdraw',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              setState(() {
                                _isLoadingAction = true;
                              });

                              final res = await sl<StartupRepository>()
                                  .withdrawInterest(s.id);

                              if (mounted) {
                                setState(() {
                                  _isLoadingAction = false;
                                });
                                res.fold((f) => context.showSnack(f.message), (
                                  success,
                                ) {
                                  if (success) {
                                    setState(() {
                                      _hasInvestedOverride = false;
                                    });
                                    context.showSnack(
                                      'Withdrew interest successfully',
                                    );
                                  }
                                });
                              }
                            } else {
                              await context.push(
                                '${Routes.apply}?type=Investment&name=${Uri.encodeComponent(s.name)}&projectId=${s.id}',
                              );
                              if (mounted) {
                                setState(() {
                                  _hasInvestedOverride = null;
                                  _future = sl<StartupRepository>().getStartup(
                                    widget.id,
                                  );
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _content(BuildContext context, Startup s) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            image: const DecorationImage(
              image: AssetImage('assets/images/startup_banner.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -34),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(name: s.name, imageUrl: s.logoUrl, size: 68),
                AppSizes.vGapSm,
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.name,
                        style: context.text.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (s.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.verified_rounded,
                          color: AppColors.info,
                        ),
                      ),
                  ],
                ),
                Text(s.tagline, style: context.text.bodyMedium),
                AppSizes.vGapMd,
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    _pill(context, s.industry),
                    _pill(context, s.stage),
                    _pill(context, s.location),
                  ],
                ),
                AppSizes.vGapLg,
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              context,
                              'Ask',
                              Formatters.compactCurrency(s.fundingRequired),
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              context,
                              'Equity',
                              '${s.equityOffered.toStringAsFixed(0)}%',
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              context,
                              'Valuation',
                              Formatters.compactCurrency(s.valuation),
                            ),
                          ),
                        ],
                      ),
                      AppSizes.vGapMd,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: s.fundingProgress,
                          minHeight: 8,
                          backgroundColor: context.theme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${Formatters.compactCurrency(s.fundingRaised)} raised · ${s.investorInterests} interested',
                          style: context.text.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSizes.vGapLg,
                AppCard(
                  onTap: () =>
                      context.push('${Routes.publicFounder}/${s.founderId}'),
                  child: Row(
                    children: [
                      AppAvatar(
                        name: s.founderName,
                        imageUrl: s.founderAvatar,
                        size: 40,
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.founderName, style: context.text.titleSmall),
                            Text(
                              'Founder · Tap to view profile',
                              style: context.text.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                if (s.problem.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Problem'),
                  AppSizes.vGapSm,
                  Text(s.problem, style: context.text.bodyMedium),
                ],
                if (s.solution.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Solution'),
                  AppSizes.vGapSm,
                  Text(s.solution, style: context.text.bodyMedium),
                ],
                AppSizes.vGapLg,
                if (s.businessModel.isNotEmpty ||
                    s.revenueModel.isNotEmpty ||
                    s.marketSize.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Business Details'),
                  AppSizes.vGapSm,
                  if (s.businessModel.isNotEmpty)
                    _detail(context, 'Business Model', s.businessModel),
                  if (s.revenueModel.isNotEmpty)
                    _detail(context, 'Revenue Model', s.revenueModel),
                  if (s.marketSize.isNotEmpty)
                    _detail(context, 'Market Size', s.marketSize),
                ],
                if ((s.pitchDeckUrl != null && s.pitchDeckUrl!.isNotEmpty) ||
                    (s.businessPlanUrl != null &&
                        s.businessPlanUrl!.isNotEmpty)) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Documents'),
                  AppSizes.vGapSm,
                  if (s.pitchDeckUrl != null && s.pitchDeckUrl!.isNotEmpty)
                    _doc(
                      context,
                      'Pitch Deck',
                      Icons.slideshow_outlined,
                      s.pitchDeckUrl!,
                    ),
                  if (s.businessPlanUrl != null &&
                      s.businessPlanUrl!.isNotEmpty)
                    _doc(
                      context,
                      'Business Plan',
                      Icons.description_outlined,
                      s.businessPlanUrl!,
                    ),
                ],
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
    children: [
      Text(value, style: context.text.titleSmall, textAlign: TextAlign.center),
      Text(label, style: context.text.labelSmall),
    ],
  );

  Widget _pill(BuildContext context, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );

  Widget _detail(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: context.text.labelMedium),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: context.text.bodyMedium,
          ),
        ),
      ],
    ),
  );

  Widget _doc(
    BuildContext context,
    String name,
    IconData icon,
    String url,
  ) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSizes.sm),
    padding: const EdgeInsets.all(AppSizes.md),
    onTap: () => context.push(
      '${Routes.documentViewer}?url=${Uri.encodeComponent(url)}&name=${Uri.encodeComponent(name)}',
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        AppSizes.hGapMd,
        Expanded(child: Text(name, style: context.text.bodyMedium)),
        const Icon(
          Icons.download_rounded,
          size: 18,
          color: AppColors.mutedText,
        ),
      ],
    ),
  );
}
