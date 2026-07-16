import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../catalog/presentation/widgets/detail_widgets.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ContractDetailsPage extends StatelessWidget {
  const ContractDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final role = context.select((AuthBloc b) => b.state.user?.role);
    return DetailView<Contract>(
      title: 'Contract',
      fetcher: () => sl<ProjectRepository>().getContract(id),
      actions: detailActions(context, shareTitle: 'this contract', shareLink: '${Routes.contractDetails}/$id', reportType: 'contract'),
      bottomBar: (context, c) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: role == UserRole.client
            ? Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Cancel',
                      onPressed: () => _contractAction(context, ApiEndpoints.clientContractCancel(c.id), 'Contract cancelled'),
                    ),
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Activate',
                      onPressed: () => _contractAction(context, ApiEndpoints.clientContractActivate(c.id), 'Contract activated'),
                    ),
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Complete',
                      onPressed: () => _contractAction(context, ApiEndpoints.clientContractComplete(c.id), 'Contract completed'),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: AppSecondaryButton(label: 'Message', icon: Icons.chat_bubble_outline_rounded, onPressed: () => context.showSnack('Opening chat…'))),
                  AppSizes.hGapMd,
                  Expanded(flex: 2, child: AppPrimaryButton(label: 'View Milestones', icon: Icons.flag_outlined, onPressed: () => context.showSnack('Scroll to milestones'))),
                ],
              ),
      ),
      builder: (context, c) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.assignment_turned_in_outlined,
            title: c.projectTitle,
            subtitle: 'with ${c.counterpartyName}',
            chips: [DetailStatChip(icon: Icons.payments_outlined, label: Formatters.compactCurrency(c.amount))],
          ),
          AppSizes.vGapLg,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Progress', style: context.text.titleSmall)),
                    AppStatusChip.status(c.status, dense: true),
                  ],
                ),
                AppSizes.vGapSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: c.progress,
                    minHeight: 8,
                    backgroundColor: context.theme.dividerColor,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  ),
                ),
                AppSizes.vGapSm,
                Text('${(c.progress * 100).toStringAsFixed(0)}% complete · Started ${Formatters.date(c.startDate)}', style: context.text.labelSmall),
              ],
            ),
          ),
          AppSizes.vGapLg,
          DetailSection(
            title: 'Milestones',
            child: DetailTimeline(
              events: [
                for (final m in c.milestones)
                  TimelineEvent(
                    m.title,
                    subtitle: '${Formatters.compactCurrency(m.amount)} · ${m.status.label} · due ${Formatters.date(m.dueDate)}',
                    done: m.status == EntityStatus.completed,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Future<void> _contractAction(BuildContext context, String endpoint, String msg) async {
    final res = await sl<ApiClientHelper>().patchAction(endpoint);
    if (!context.mounted) return;
    res.fold((f) => context.showSnack(f.message), (_) => context.showSnack(msg));
  }
}
