import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/app_section_header.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  List<String> _recent = const [];
  List<String> _trending = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final recent = await api.getEnvelope<List<String>>(
      ApiEndpoints.discoveryRecentlyViewed,
      parser: (e) => (e.data as List?)?.map((x) => x.toString()).toList() ?? const [],
    );
    final rec = await api.getEnvelope<List<String>>(
      ApiEndpoints.discoveryRecommendations,
      parser: (e) => (e.data as List?)?.map((x) => x.toString()).toList() ?? const [],
    );
    if (!mounted) return;
    _recent = recent.valueOrNull?.isNotEmpty == true
        ? recent.valueOrNull!
        : ['Flutter developer', 'FinTech startups', 'UI/UX design'];
    _trending = rec.valueOrNull?.isNotEmpty == true
        ? rec.valueOrNull!
        : ['AI/ML', 'Web3', 'Remote', 'HealthTech'];
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSizes.md),
          child: AppSearchBar(
            autofocus: true,
            hint: 'Search everything…',
            onSubmitted: (v) async {
              final res = await sl<ApiClientHelper>().getEnvelope<List<dynamic>>(
                ApiEndpoints.search,
                query: {'q': v},
                parser: (e) => (e.data as List?) ?? const [],
              );
              if (!context.mounted) return;
              res.fold(
                (f) => context.showSnack(f.message),
                (list) => context.showSnack('Found ${list.length} results'),
              );
            },
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Row(
            children: [
              Expanded(child: _quick(context, Icons.mic_none_rounded, 'Voice Search')),
              AppSizes.hGapMd,
              Expanded(child: _quick(context, Icons.auto_awesome_outlined, 'AI Search')),
            ],
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Recent Searches'),
          AppSizes.vGapSm,
          for (final r in _recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, color: AppColors.mutedText),
              title: Text(r),
              trailing: const Icon(Icons.north_west_rounded, size: 16),
              onTap: () => context.showSnack('Searching "$r"'),
            ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Trending'),
          AppSizes.vGapSm,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final t in _trending)
                ActionChip(
                  avatar: const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                  label: Text(t),
                  onPressed: () => context.showSnack('Searching "$t"'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label) => OutlinedButton.icon(
        onPressed: () => context.showSnack('$label (coming soon)'),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
      );
}
