import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../client_dashboard/domain/repositories/client_proposal_repository.dart';
import '../../../client_dashboard/presentation/widgets/client_proposal_action_bar.dart';
import '../../../messages/domain/repositories/message_repository.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/proposal_repository.dart';

/// Dedicated proposal details page.
class ProposalDetailsPage extends StatefulWidget {
  const ProposalDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<ProposalDetailsPage> createState() => _ProposalDetailsPageState();
}

class _ProposalDetailsPageState extends State<ProposalDetailsPage> {
  Future? _future;
  bool _busy = false;
  bool _isClient = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _isClient = context.read<AuthBloc>().state.user?.role == UserRole.client;
    _reload();
  }

  void _reload() {
    _future = _isClient
        ? sl<ClientProposalRepository>().getProposal(widget.id)
        : sl<ProposalRepository>().getProposal(widget.id);
    setState(() {});
  }

  Future<void> _withdraw(Proposal p) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: 'Withdraw proposal?',
      message: 'The client will no longer see this proposal.',
      confirmLabel: 'Withdraw',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final res = await sl<ProposalRepository>().withdraw(p.id);
    if (!mounted) return;
    setState(() => _busy = false);
    res.fold((f) => context.showSnack(f.message, isError: true), (_) {
      context.showSnack('Proposal withdrawn');
      _reload();
    });
  }

  Future<void> _delete(Proposal p) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: 'Delete proposal?',
      message: 'This permanently removes the proposal from your list.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final res = await sl<ProposalRepository>().deleteProposal(p.id);
    if (!mounted) return;
    setState(() => _busy = false);
    res.fold((f) => context.showSnack(f.message, isError: true), (_) {
      context.showSnack('Proposal deleted');
      context.pop();
    });
  }

  Future<void> _messageClient(Proposal p) async {
    final clientId = p.clientId;
    if (clientId == null || clientId.isEmpty) {
      context.showSnack('Client unavailable for messaging', isError: true);
      return;
    }
    final res = await sl<MessageRepository>().startChat(
      recipientId: clientId,
      projectId: p.projectId,
    );
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message, isError: true), (msg) {
      final convId = msg.conversationId;
      if (convId.isEmpty) {
        context.push(Routes.messages);
        return;
      }
      context.push('${Routes.chat}/$convId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isClient =
        context.watch<AuthBloc>().state.user?.role == UserRole.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        actions: [
          if (!isClient) ...[
            IconButton(
              tooltip: 'Edit bid',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final proposal = (await _future)?.valueOrNull as Proposal?;
                if (!context.mounted || proposal == null) return;
                final projectId = proposal.projectId ?? '';
                final path =
                    '${Routes.apply}?type=Project'
                    '&projectId=${Uri.encodeComponent(projectId)}'
                    '&proposalId=${Uri.encodeComponent(proposal.id)}'
                    '&name=${Uri.encodeComponent(proposal.projectTitle)}'
                    '&bid=${Uri.encodeComponent(proposal.bidAmount.toString())}'
                    '&cover=${Uri.encodeComponent(proposal.coverLetter)}'
                    '&deliveryDays=${Uri.encodeComponent(proposal.deliveryDays.toString())}';
                await context.push(path);
                if (!mounted) return;
                _reload();
              },
            ),
            IconButton(
              tooltip: 'Delete proposal',
              color: context.theme.colorScheme.error,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final proposal = (await _future)?.valueOrNull as Proposal?;
                if (!context.mounted || proposal == null) return;
                await _delete(proposal);
              },
            ),
          ],
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (_future == null ||
              snapshot.connectionState == ConnectionState.waiting ||
              _busy) {
            return const AppLoadingShimmer(itemCount: 4, height: 110);
          }
          final proposal = snapshot.data?.valueOrNull as Proposal?;
          if (proposal == null) return const AppErrorState();
          return _content(context, proposal);
        },
      ),
      bottomNavigationBar: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          final proposal = snapshot.data?.valueOrNull as Proposal?;
          if (proposal == null) return const SizedBox.shrink();
          if (isClient) {
            return ClientProposalActionBar(proposal: proposal);
          }
          return _freelancerActions(context, proposal);
        },
      ),
    );
  }

  Widget _freelancerActions(BuildContext context, Proposal p) {
    final withdrawn = p.status == EntityStatus.withdrawn;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: withdrawn ? 'Withdrawn' : 'Withdraw',
                icon: Icons.undo_rounded,
                onPressed: withdrawn ? null : () => _withdraw(p),
              ),
            ),
            AppSizes.hGapMd,
            Expanded(
              child: AppPrimaryButton(
                label: 'Message Client',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => _messageClient(p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Proposal p) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.screenPadding,
          AppSizes.screenPadding,
          AppSizes.screenPadding + 88,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(p.projectTitle, style: context.text.headlineSmall),
              ),
              AppStatusChip.status(p.status, dense: true),
            ],
          ),
          AppSizes.vGapSm,
          Text(
            'Submitted ${Formatters.relative(p.submittedAt)}',
            style: context.text.labelSmall,
          ),
          AppSizes.vGapLg,
          AppCard(
            child: Row(
              children: [
                AppAvatar(
                  name: p.freelancerName,
                  imageUrl: p.freelancerAvatar,
                  size: 44,
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.freelancerName, style: context.text.titleSmall),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          Text(
                            ' ${p.freelancerRating} rating',
                            style: context.text.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(
                child: _stat(
                  context,
                  Icons.payments_outlined,
                  'Bid',
                  p.isHourly
                      ? '${Formatters.compactCurrency(p.bidAmount)}/hr'
                      : Formatters.compactCurrency(p.bidAmount),
                ),
              ),
              Expanded(
                child: _stat(
                  context,
                  Icons.schedule_rounded,
                  'Delivery',
                  '${p.deliveryDays} days',
                ),
              ),
            ],
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Cover Letter'),
          AppSizes.vGapSm,
          Text(p.coverLetter, style: context.text.bodyMedium),
          // AppSizes.vGapLg,
          // const AppSectionHeader(title: 'Attachments'),
          // AppSizes.vGapSm,
          // if (p.attachments.isEmpty)
          //   Text('No attachments', style: context.text.bodySmall)
          // else
          //   for (final a in p.attachments)
          //     AppCard(
          //       margin: const EdgeInsets.only(bottom: AppSizes.sm),
          //       padding: const EdgeInsets.all(AppSizes.md),
          //       onTap: () => context.showSnack('Opening $a'),
          //       child: Row(
          //         children: [
          //           const Icon(
          //             Icons.description_outlined,
          //             color: AppColors.primary,
          //           ),
          //           AppSizes.hGapMd,
          //           Expanded(child: Text(a, style: context.text.bodyMedium)),
          //           const Icon(
          //             Icons.download_rounded,
          //             size: 18,
          //             color: AppColors.mutedText,
          //           ),
          //         ],
          //       ),
          //     ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => AppCard(
    margin: const EdgeInsets.all(AppSizes.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        AppSizes.vGapSm,
        Text(
          value,
          style: context.text.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: context.text.labelSmall),
      ],
    ),
  );
}
