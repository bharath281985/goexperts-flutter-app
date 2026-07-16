import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../proposals/domain/entities/proposal.dart';
import '../../../messages/domain/repositories/message_repository.dart';
import '../../domain/repositories/client_proposal_repository.dart';
import '../bloc/client_proposal_bloc.dart';

/// Client-side action buttons for reviewing a freelancer proposal.
class ClientProposalActionBar extends StatelessWidget {
  const ClientProposalActionBar({super.key, required this.proposal});

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientProposalBloc(sl<ClientProposalRepository>()),
      child: _ClientProposalActionBarBody(proposal: proposal),
    );
  }
}

class _ClientProposalActionBarBody extends StatelessWidget {
  const _ClientProposalActionBarBody({required this.proposal});

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientProposalBloc, ClientProposalState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.successMessage != c.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showSnack(state.errorMessage!, isError: true);
        }
        if (state.successMessage != null) {
          context.showSnack(state.successMessage!);
          if (state.successMessage == 'Proposal accepted' && context.mounted) {
            context.push('${Routes.contractDetails}/new');
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClientProposalBloc>();
        final status = proposal.status;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == EntityStatus.pending ||
                    status == EntityStatus.underReview) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          isLoading: state.isActionLoading(
                            ClientProposalAction.reject,
                            proposal.id,
                          ),
                          onPressed: () => _confirm(
                            context,
                            title: 'Reject proposal?',
                            message: 'The freelancer will be notified.',
                            confirmLabel: 'Reject',
                            isDestructive: true,
                            onConfirm: () => bloc.add(
                              ClientProposalRejectRequested(proposal.id),
                            ),
                          ),
                        ),
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: AppPrimaryButton(
                          label: 'Shortlist',
                          icon: Icons.star_outline_rounded,
                          isLoading: state.isActionLoading(
                            ClientProposalAction.shortlist,
                            proposal.id,
                          ),
                          onPressed: () => bloc.add(
                            ClientProposalShortlistRequested(proposal.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSizes.vGapSm,
                  AppPrimaryButton(
                    label: 'Move to Interview',
                    icon: Icons.videocam_outlined,
                    isLoading: state.isActionLoading(
                      ClientProposalAction.interview,
                      proposal.id,
                    ),
                    onPressed: () => bloc.add(
                      ClientProposalInterviewRequested(proposal.id),
                    ),
                  ),
                ],
                if (status == EntityStatus.shortlisted ||
                    status == EntityStatus.interview) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          isLoading: state.isActionLoading(
                            ClientProposalAction.reject,
                            proposal.id,
                          ),
                          onPressed: () => _confirm(
                            context,
                            title: 'Reject proposal?',
                            message: 'This cannot be undone.',
                            confirmLabel: 'Reject',
                            isDestructive: true,
                            onConfirm: () => bloc.add(
                              ClientProposalRejectRequested(proposal.id),
                            ),
                          ),
                        ),
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        flex: 2,
                        child: AppPrimaryButton(
                          label: 'Accept',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: state.isActionLoading(
                            ClientProposalAction.accept,
                            proposal.id,
                          ),
                          onPressed: () => _confirm(
                            context,
                            title: 'Accept proposal?',
                            message: 'You can create a contract after accepting.',
                            confirmLabel: 'Accept',
                            onConfirm: () => bloc.add(
                              ClientProposalAcceptRequested(proposal.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (status == EntityStatus.accepted)
                  AppPrimaryButton(
                    label: 'View Contract',
                    icon: Icons.description_outlined,
                    onPressed: () =>
                        context.push('${Routes.contractDetails}/${proposal.id}'),
                  ),
                AppSizes.vGapSm,
                AppSecondaryButton(
                  label: 'Message Freelancer',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => _openChat(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
    );
    if (ok) onConfirm();
  }

  Future<void> _openChat(BuildContext context) async {
    final freelancerId = proposal.freelancerId;
    if (freelancerId == null || freelancerId.isEmpty) {
      context.showSnack('Freelancer unavailable for messaging', isError: true);
      return;
    }
    final res = await sl<MessageRepository>().startChat(
      recipientId: freelancerId,
      projectId: proposal.projectId,
    );
    if (!context.mounted) return;
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (msg) {
        final convId = msg.conversationId;
        if (convId.isEmpty) {
          context.push(Routes.messages);
          return;
        }
        context.push('${Routes.chat}/$convId');
      },
    );
  }
}
