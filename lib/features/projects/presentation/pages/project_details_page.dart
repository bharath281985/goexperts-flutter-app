import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/bookmark_manager.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/share_sheet.dart';
import '../../../client_dashboard/domain/repositories/client_proposal_repository.dart';
import '../../../client_dashboard/presentation/widgets/client_proposal_action_bar.dart';
import '../../../messages/domain/repositories/message_repository.dart';
import '../../../proposals/domain/entities/proposal.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

String _experienceLevelLabel(String? raw) {
  final value = (raw ?? 'intermediate').trim().toLowerCase();
  if (value == 'beginner' || value == 'entry' || value == 'junior') {
    return 'Beginner';
  }
  if (value == 'expert' || value == 'senior' || value == 'advanced') {
    return 'Expert';
  }
  return 'Intermediate';
}

class ProjectDetailsPage extends StatefulWidget {
  const ProjectDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Future<ResultLike> _future;
  List<Proposal> _proposals = const [];
  bool _loadingProposals = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = sl<ProjectRepository>().getProject(widget.id).then((res) {
      final project = res.valueOrNull;
      if (project?.isOwner == true) {
        _loadProposals();
      }
      return ResultLike(project: project, error: res.failureOrNull?.message);
    });
    setState(() {});
  }

  Future<void> _loadProposals() async {
    setState(() => _loadingProposals = true);
    final res = await sl<ClientProposalRepository>().getProjectProposals(
      widget.id,
      const QueryParams(page: 1, pageSize: 50),
    );
    if (!mounted) return;
    setState(() {
      _loadingProposals = false;
      _proposals = res.valueOrNull?.items ?? const [];
    });
  }

  Future<void> _deleteProject() async {
    final ok = await AppConfirmDialog.show(
      context,
      title: 'Delete project?',
      message:
          'This will permanently remove the project from your listings. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !mounted) return;
    final res = await sl<ProjectRepository>().deleteProject(widget.id);
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (_) {
        context.showSnack('Project deleted');
        context.pop();
      },
    );
  }

  Future<void> _updateStatus(Project project) async {
    const options = [
      _ProjectStatusOption(value: 'draft', label: 'Draft'),
      _ProjectStatusOption(value: 'open', label: 'Open'),
      _ProjectStatusOption(value: 'in_progress', label: 'In Progress'),
      _ProjectStatusOption(value: 'completed', label: 'Completed'),
      _ProjectStatusOption(value: 'cancelled', label: 'Cancelled'),
    ];
    final current = options.firstWhere(
      (option) => EntityStatus.fromString(option.value) == project.status,
      orElse: () => options.first,
    );
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _ProjectStatusSheet(
        options: options,
        initialValue: current,
      ),
    );
    if (selected == null || !mounted) return;
    final res = await sl<ProjectRepository>().updateProjectStatus(
      widget.id,
      selected,
    );
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (_) {
        final label = options
            .firstWhere(
              (option) => option.value == selected,
              orElse: () => _ProjectStatusOption(
                value: selected,
                label: selected.replaceAll('_', ' '),
              ),
            )
            .label;
        context.showSnack('Status updated to $label');
        _reload();
      },
    );
  }

  Future<void> _shareProject(Project project) async {
    final link = 'https://goexperts.in/projects/${project.id}';
    await ShareSheet.show(
      context,
      title: project.title,
      subtitle: 'Share with freelancers via WhatsApp, email, SMS, and more',
      link: link,
      onShared: (platform) {
        sl<ProjectRepository>().trackProjectShare(project.id, platform);
      },
    );
  }

  Future<void> _messageAboutProject(Project project) async {
    final recipientId = project.clientId;
    if (recipientId == null || recipientId.isEmpty) {
      context.showSnack('Client unavailable for messaging', isError: true);
      return;
    }
    final res = await sl<MessageRepository>().startChat(
      recipientId: recipientId,
      projectId: project.id,
    );
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkManager.instance,
      builder: (context, _) {
        final isSaved = BookmarkManager.instance.isBookmarked(
          BookmarkManager.categoryProjects,
          widget.id,
        );
        return FutureBuilder<ResultLike>(
          future: _future,
          builder: (context, snapshot) {
            final project = snapshot.data?.project;
            final isOwner = project?.isOwner == true;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Project Details'),
                actions: [
                  if (isOwner)
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                      onPressed: _deleteProject,
                    ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: project == null
                        ? null
                        : () => _shareProject(project),
                  ),
                  if (!isOwner)
                    IconButton(
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: isSaved ? AppColors.primary : null,
                      ),
                      onPressed: () => BookmarkManager.instance.toggle(
                        BookmarkManager.categoryProjects,
                        widget.id,
                      ),
                    ),
                ],
              ),
              body: snapshot.connectionState == ConnectionState.waiting
                  ? const AppLoadingShimmer(itemCount: 4, height: 120)
                  : project == null
                      ? AppErrorState(
                          message: snapshot.data?.error,
                          onRetry: _reload,
                        )
                      : _content(context, project),
              bottomNavigationBar: project == null
                  ? null
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: isOwner
                            ? Row(
                                children: [
                                  Expanded(
                                    child: AppSecondaryButton(
                                      label: 'Edit',
                                      icon: Icons.edit_outlined,
                                      onPressed: () async {
                                        await context.push(
                                          '${Routes.clientCreateProject}?projectId=${Uri.encodeComponent(widget.id)}',
                                        );
                                        if (mounted) _reload();
                                      },
                                    ),
                                  ),
                                  AppSizes.hGapMd,
                                  Expanded(
                                    flex: 2,
                                    child: AppPrimaryButton(
                                      label: 'Update Status',
                                      icon: Icons.flag_outlined,
                                      onPressed: () => _updateStatus(project),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: AppSecondaryButton(
                                      label: 'Message',
                                      icon: Icons.chat_bubble_outline_rounded,
                                      onPressed: () =>
                                          _messageAboutProject(project),
                                    ),
                                  ),
                                  AppSizes.hGapMd,
                                  Expanded(
                                    flex: 2,
                                    child: AppPrimaryButton(
                                      label: project.isApplied
                                          ? 'Applied'
                                          : 'Apply Now',
                                      icon: project.isApplied
                                          ? Icons.check_rounded
                                          : Icons.send_rounded,
                                      gradient: !project.isApplied,
                                      onPressed: project.isApplied
                                          ? null
                                          : () => context.push(
                                                '${Routes.apply}?type=Project'
                                                '&projectId=${Uri.encodeComponent(project.id)}'
                                                '&name=${Uri.encodeComponent(project.title)}',
                                              ),
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

  Widget _content(BuildContext context, Project p) {
    final budget = p.isHourly
        ? '${Formatters.currency(p.budgetMin)} - ${Formatters.currency(p.budgetMax)} / hr'
        : '${Formatters.currency(p.budgetMin)} - ${Formatters.currency(p.budgetMax)}';
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Image.asset(
            'assets/images/project_banner.png',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        AppSizes.vGapLg,
        Text(p.title, style: context.text.headlineSmall),
        AppSizes.vGapSm,
        Row(
          children: [
            AppStatusChip.status(p.status, dense: true),
            AppSizes.hGapSm,
            Text(
              'Posted ${Formatters.relative(p.postedAt)}',
              style: context.text.labelSmall,
            ),
          ],
        ),
        AppSizes.vGapLg,
        AppCard(
          child: Row(
            children: [
              AppAvatar(name: p.clientName, imageUrl: p.clientAvatar, size: 44),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.clientName,
                            style: context.text.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.clientVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.info,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      p.category,
                      style: context.text.labelSmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
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
              child: _stat(context, Icons.payments_outlined, 'Budget', budget),
            ),
            Expanded(
              child: _stat(
                context,
                Icons.schedule_rounded,
                'Timeline',
                p.timeline.isEmpty ? '—' : p.timeline,
              ),
            ),
          ],
        ),
        AppSizes.vGapSm,
        Row(
          children: [
            Expanded(
              child: _stat(
                context,
                Icons.work_history_outlined,
                'Level',
                _experienceLevelLabel(p.experienceLevel),
              ),
            ),
            Expanded(
              child: _stat(
                context,
                Icons.location_on_outlined,
                'Work Mode',
                p.workMode,
              ),
            ),
          ],
        ),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Category'),
        AppSizes.vGapSm,
        Align(
          alignment: Alignment.centerLeft,
          child: _chip(context, p.category),
        ),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Project Overview'),
        AppSizes.vGapSm,
        Text(
          p.description.isEmpty ? 'No description provided.' : p.description,
          style: context.text.bodyMedium,
        ),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Skills Required'),
        AppSizes.vGapSm,
        if (p.skills.isEmpty)
          Text('No skills listed', style: context.text.bodySmall)
        else
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [for (final s in p.skills) _chip(context, s)],
          ),
        AppSizes.vGapLg,
        const AppSectionHeader(title: 'Attachments'),
        AppSizes.vGapSm,
        if (p.attachments.isEmpty)
          AppCard(
            child: Text(
              'No attachments for this project.',
              style: context.text.bodyMedium,
            ),
          )
        else
          for (final url in p.attachments)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, color: AppColors.primary),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Text(
                      url.split('/').last,
                      style: context.text.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        AppSizes.vGapLg,
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.groups_outlined, color: AppColors.primary),
              AppSizes.hGapMd,
              Text(
                '${p.proposalsCount} freelancers have applied',
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
        if (p.isOwner) ...[
          AppSizes.vGapLg,
          const AppSectionHeader(
            title: 'Proposals',
            subtitle: 'Review and update freelancer applications',
          ),
          AppSizes.vGapSm,
          if (_loadingProposals)
            const AppLoadingShimmer(itemCount: 2, height: 90)
          else if (_proposals.isEmpty)
            AppCard(
              child: Text(
                'No proposals yet for this project.',
                style: context.text.bodyMedium,
              ),
            )
          else
            for (final proposal in _proposals) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppAvatar(
                          name: proposal.freelancerName,
                          imageUrl: proposal.freelancerAvatar,
                          size: 40,
                        ),
                        AppSizes.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proposal.freelancerName,
                                style: context.text.titleSmall,
                              ),
                              Text(
                                Formatters.currency(proposal.bidAmount),
                                style: context.text.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        AppStatusChip.status(proposal.status, dense: true),
                      ],
                    ),
                    if (proposal.coverLetter.trim().isNotEmpty) ...[
                      AppSizes.vGapSm,
                      Text(
                        proposal.coverLetter,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ],
                    AppSizes.vGapMd,
                    ClientProposalActionBar(proposal: proposal),
                  ],
                ),
              ),
              AppSizes.vGapMd,
            ],
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) =>
      AppCard(
        margin: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            AppSizes.vGapSm,
            Text(
              value,
              style: context.text.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: context.text.labelSmall),
          ],
        ),
      );

  Widget _chip(BuildContext context, String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          s,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
}

class ResultLike {
  ResultLike({this.project, this.error});
  final Project? project;
  final String? error;
}

class _ProjectStatusOption {
  const _ProjectStatusOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _ProjectStatusSheet extends StatefulWidget {
  const _ProjectStatusSheet({
    required this.options,
    required this.initialValue,
  });

  final List<_ProjectStatusOption> options;
  final _ProjectStatusOption initialValue;

  @override
  State<_ProjectStatusSheet> createState() => _ProjectStatusSheetState();
}

class _ProjectStatusSheetState extends State<_ProjectStatusSheet> {
  late _ProjectStatusOption _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSizes.xl,
          right: AppSizes.xl,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSizes.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Update project status',
                    style: context.text.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            AppSizes.vGapMd,
            AppDropdown<_ProjectStatusOption>(
              label: 'Status',
              hint: 'Select status',
              value: _selected,
              items: widget.options,
              itemLabel: (option) => option.label,
              prefixIcon: Icons.flag_outlined,
              onChanged: (option) {
                if (option == null) return;
                setState(() => _selected = option);
              },
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(
              label: 'Submit',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(context).pop(_selected.value),
            ),
          ],
        ),
      ),
    );
  }
}
