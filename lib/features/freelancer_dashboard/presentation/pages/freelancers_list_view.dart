import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_filter_bottom_sheet.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../master_data/domain/entities/skill_category.dart';
import '../../../master_data/domain/repositories/master_data_repository.dart';
import '../../domain/entities/freelancer.dart';
import '../../domain/repositories/freelancer_repository.dart';
import '../widgets/freelancer_card.dart';

/// Embeddable freelancer discovery catalog.
class FreelancersListView extends StatefulWidget {
  const FreelancersListView({super.key});

  @override
  State<FreelancersListView> createState() => _FreelancersListViewState();
}

class _FreelancersListViewState extends State<FreelancersListView> {
  List<SkillCategory> _categories = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await sl<MasterDataRepository>().getSkillCategories(
      page: 1,
      pageSize: 200,
    );
    if (!mounted) return;
    setState(() {
      _categories = result.valueOrNull ?? const [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final repo = sl<FreelancerRepository>();
    return CatalogView<Freelancer>(
      fetcher: repo.getFreelancers,
      searchHint: 'Search freelancers, skills…',
      emptyTitle: 'No freelancers found',
      emptyIcon: Icons.groups_outlined,
      sortOptions: const ['Top rated', 'Rate: Low to High', 'Most experienced'],
      filterSections: () => [
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
          key: 'availability',
          title: 'Availability',
          options: const ['Available now', 'Within a week'],
        ),
      ],
      itemBuilder: (context, f, _) => AppFreelancerCard(
        freelancer: f,
        onTap: () => context.push('${Routes.publicFreelancer}/${f.id}'),
        onSave: () =>
            context.showSnack(f.isSaved ? 'Removed from saved' : 'Saved'),
        onInvite: () => context.showSnack('Invitation sent to ${f.name}'),
      ),
    );
  }
}
