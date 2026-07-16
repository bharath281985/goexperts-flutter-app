import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../client_dashboard/domain/repositories/client_proposal_repository.dart';
import '../../../proposals/domain/entities/proposal.dart';

Widget _proposalCard(BuildContext context, Proposal p) => AppCard(
  onTap: () => context.push('${Routes.proposalDetails}/${p.id}'),
  child: Row(
    children: [
      AppAvatar(name: p.freelancerName, imageUrl: p.freelancerAvatar, size: 44),
      AppSizes.hGapMd,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.freelancerName, style: context.text.titleSmall),
            Text(
              p.projectTitle,
              style: context.text.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSizes.vGapXs,
            Text(
              '${Formatters.compactCurrency(p.bidAmount)}${p.isHourly ? '/hr' : ''}',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
      AppStatusChip.status(p.status, dense: true),
    ],
  ),
);

class ClientApplicationsPage extends StatelessWidget {
  const ClientApplicationsPage({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Applications')),
    body: CatalogView<Proposal>(
      fetcher: (q) => sl<ClientProposalRepository>().getProposals(q),
      searchHint: 'Search applicants…',
      emptyTitle: 'No applications yet',
      itemBuilder: (context, p, __) => _proposalCard(context, p),
    ),
  );
}

class ClientShortlistedPage extends StatelessWidget {
  const ClientShortlistedPage({super.key});

  Future<Result<Paginated<Proposal>>> _fetch(QueryParams q) async {
    final res = await sl<ClientProposalRepository>().getProposals(q);
    return res.fold((f) => Err(f), (p) {
      final items = p.items
          .where(
            (x) =>
                x.status == EntityStatus.shortlisted ||
                x.status == EntityStatus.accepted,
          )
          .toList();
      return Success(
        Paginated(
          items: items,
          page: p.page,
          totalPages: 1,
          totalItems: items.length,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Shortlisted')),
    body: CatalogView<Proposal>(
      fetcher: _fetch,
      searchHint: 'Search shortlisted…',
      emptyTitle: 'No one shortlisted yet',
      emptyIcon: Icons.star_outline_rounded,
      itemBuilder: (context, p, __) => _proposalCard(context, p),
    ),
  );
}

class ClientTeamsPage extends StatefulWidget {
  const ClientTeamsPage({super.key});

  @override
  State<ClientTeamsPage> createState() => _ClientTeamsPageState();
}

class _ClientTeamsPageState extends State<ClientTeamsPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _members = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final res = await api.getEnvelope<List<Map<String, dynamic>>>(
      ApiEndpoints.clientTeam,
      parser: (env) {
        final list = env.data as List?;
        if (list == null) return const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    if (!mounted) return;
    res.fold((_) {}, (list) => _members = list);
    setState(() => _loading = false);
  }

  Future<void> _invite() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Invite member'),
        content: AppTextField(
          controller: ctrl,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final api = sl<ApiClientHelper>();
              final res = await api.postAction(
                '${ApiEndpoints.clientTeam}/invite',
                body: {'email': ctrl.text.trim()},
              );
              if (!mounted) return;
              res.fold(
                (f) => context.showSnack(f.message),
                (_) => context.showSnack('Invitation sent'),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: _invite,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (_members.isEmpty)
                  const AppCard(child: Text('No team members yet')),
                for (final m in _members)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: m['name']?.toString() ?? 'Member',
                          size: 44,
                        ),
                        AppSizes.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name']?.toString() ?? 'Member',
                                style: context.text.titleSmall,
                              ),
                              Text(
                                m['role']?.toString() ?? 'Member',
                                style: context.text.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        if (m['admin'] == true ||
                            m['role']?.toString().toLowerCase() == 'admin')
                          AppStatusChip(
                            label: 'Admin',
                            dense: true,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
