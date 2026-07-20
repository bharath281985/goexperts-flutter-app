import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/bloc/list_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_filter_bottom_sheet.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../master_data/domain/entities/skill_category.dart';
import '../../../master_data/domain/repositories/master_data_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../widgets/project_card.dart';

const _projectSortOptions = [
  'Newest',
  'Budget: High to Low',
  'Budget: Low to High',
  'Most proposals',
];

const _projectSortApiValues = {
  'Newest': 'newest',
  'Budget: High to Low': 'budget_desc',
  'Budget: Low to High': 'budget_asc',
  'Most proposals': 'proposals_desc',
};

/// Embeddable discover-projects catalog (used as a dashboard tab & standalone).
class ProjectsListView extends StatefulWidget {
  const ProjectsListView({super.key});

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  List<SkillCategory> _categories = const [];
  UserRole? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final role = await sl<TokenRoleHelper>().resolve();
    final categoriesResult = await sl<MasterDataRepository>()
        .getSkillCategories(page: 1, pageSize: 200);
    if (!mounted) return;
    setState(() {
      _role = role;
      _categories = categoriesResult.valueOrNull ?? const [];
      _loading = false;
    });
  }

  Future<void> _openEditProject(BuildContext context, String projectId) async {
    final changed = await context.push<bool>(
      '${Routes.clientCreateProject}?projectId=${Uri.encodeComponent(projectId)}',
    );
    if (!context.mounted || changed != true) return;
    context.read<ListBloc<Project>>().add(const ListRefreshed());
  }

  List<FilterSection> _filterSections() {
    final isClient = _role == UserRole.client;
    return [
      if (isClient)
        FilterSection(
          key: 'status',
          title: 'Status',
          singleSelect: true,
          optionItems: const [
            FilterOption(value: 'draft', label: 'Draft'),
            FilterOption(value: 'open', label: 'Open'),
            FilterOption(value: 'in_progress', label: 'In progress'),
            FilterOption(value: 'completed', label: 'Completed'),
            FilterOption(value: 'cancelled', label: 'Cancelled'),
          ],
        ),
      FilterSection(
        key: 'categoryIds',
        title: 'Category',
        searchable: true,
        searchHint: 'Search categories…',
        optionItems: _categories
            .map((c) => FilterOption(value: c.id, label: c.name))
            .toList(),
      ),
      FilterSection(
        key: 'workModes',
        title: 'Work Mode',
        options: const ['Remote', 'On-site', 'Hybrid'],
      ),
      if (_role != UserRole.client)
        FilterSection(
          key: 'experienceLevels',
          title: 'Experience Level',
          optionItems: const [
            FilterOption(value: 'beginner', label: 'Beginner'),
            FilterOption(value: 'intermediate', label: 'Intermediate'),
            FilterOption(value: 'expert', label: 'Expert'),
          ],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final repo = sl<ProjectRepository>();
    final isClient = _role == UserRole.client;

    return CatalogView<Project>(
      fetcher: (params) {
        final sortLabel = params.sortBy;
        final apiSort = sortLabel == null
            ? null
            : (_projectSortApiValues[sortLabel] ?? sortLabel);
        return repo.getProjects(
          params.copyWith(
            sortBy: apiSort,
            filters: {
              for (final entry in params.filters.entries)
                if (entry.key == 'categoryIds')
                  'categoryIds': entry.value
                else if (entry.key == 'workModes')
                  'workModes': entry.value
                else if (entry.key == 'experienceLevels')
                  'experienceLevels': entry.value
                else if (entry.key == 'status' && entry.value is List)
                  'status': (entry.value as List).isNotEmpty
                      ? (entry.value as List).first
                      : null
                else
                  entry.key: entry.value,
            },
          ),
        );
      },
      searchHint: 'Search projects, skills…',
      emptyTitle: 'No projects found',
      emptyMessage: 'Try adjusting your search or filters.',
      emptyIcon: Icons.work_outline_rounded,
      header: isClient ? const _CreateProjectHeader() : null,
      sortOptions: _projectSortOptions,
      filterSections: _filterSections,
      itemBuilder: (context, project, _) => AppProjectCard(
        project: project,
        onTap: () => context.push('${Routes.projectDetails}/${project.id}'),
        onSave: () => context.showSnack(
          project.isSaved ? 'Removed from saved' : 'Saved project',
        ),
        onApply: () => context.push('${Routes.projectDetails}/${project.id}'),
        onEdit: project.isOwner
            ? () => _openEditProject(context, project.id)
            : null,
        onUpdateStatus: project.isOwner
            ? () => context.push('${Routes.projectDetails}/${project.id}')
            : null,
      ),
    );
  }
}

class _CreateProjectHeader extends StatelessWidget {
  const _CreateProjectHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: () async {
            final changed = await context.push<bool>(
              Routes.clientCreateProject,
            );
            if (!context.mounted || changed != true) return;
            context.read<ListBloc<Project>>().add(const ListRefreshed());
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(context.tr('Create Project')),
        ),
      ),
    );
  }
}
