import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/bookmark_manager.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../freelancer_dashboard/domain/entities/freelancer.dart';
import '../../../freelancer_dashboard/domain/repositories/freelancer_repository.dart';
import '../../../freelancer_dashboard/presentation/widgets/freelancer_card.dart';
import '../../../investor_dashboard/domain/entities/investor.dart';
import '../../../investor_dashboard/domain/repositories/investor_repository.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../startup_ideas/domain/entities/startup.dart';
import '../../../startup_ideas/domain/repositories/startup_repository.dart';
import '../../../startup_ideas/presentation/widgets/startup_card.dart';
import '../../../catalog/domain/entities/catalog_entities.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../founder_dashboard/domain/entities/founder.dart';
import '../../../founder_dashboard/domain/repositories/founder_repository.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  Future<Result<Paginated<Project>>> _fetchProjects(QueryParams params) async {
    final res = await sl<ProjectRepository>().getProjects(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryProjects,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<Freelancer>>> _fetchFreelancers(
    QueryParams params,
  ) async {
    final res = await sl<FreelancerRepository>().getFreelancers(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryFreelancers,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .map((x) => x.copyWith(isSaved: true))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<Startup>>> _fetchStartups(QueryParams params) async {
    final res = await sl<StartupRepository>().getStartups(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryStartups,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .map((x) => x.copyWith(isSaved: true))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<Investor>>> _fetchInvestors(
    QueryParams params,
  ) async {
    final res = await sl<InvestorRepository>().getInvestors(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryInvestors,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .map((x) => x.copyWith(isSaved: true))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<Technology>>> _fetchTechnologies(
    QueryParams params,
  ) async {
    final res = await sl<CatalogRepository>().getTechnologies(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryTechnologies,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<CategoryItem>>> _fetchCategories(
    QueryParams params,
  ) async {
    final res = await sl<CatalogRepository>().getCategories(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryCategories,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Future<Result<Paginated<Founder>>> _fetchFounders(QueryParams params) async {
    final res = await sl<FounderRepository>().getFounders(params);
    return res.fold((f) => Err(f), (paginated) {
      final savedIds = BookmarkManager.instance.getIds(
        BookmarkManager.categoryFounders,
      );
      final filtered = paginated.items
          .where((x) => savedIds.contains(x.id))
          .toList();
      return Success(
        Paginated(
          items: filtered,
          page: paginated.page,
          totalPages: 1,
          totalItems: filtered.length,
        ),
      );
    });
  }

  Widget _projectsView(BuildContext context) {
    return CatalogView<Project>(
      fetcher: _fetchProjects,
      showSearch: false,
      emptyTitle: 'No saved projects',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, p, _) => AppProjectCard(
        project: p.copyWith(
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryProjects,
            p.id,
          ),
        ),
        onTap: () => context.push('${Routes.projectDetails}/${p.id}'),
        onSave: () => BookmarkManager.instance.toggle(
          BookmarkManager.categoryProjects,
          p.id,
        ),
      ),
    );
  }

  Widget _freelancersView(BuildContext context) {
    return CatalogView<Freelancer>(
      fetcher: _fetchFreelancers,
      showSearch: false,
      emptyTitle: 'No saved freelancers',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, f, _) => AppFreelancerCard(
        freelancer: f.copyWith(
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryFreelancers,
            f.id,
          ),
        ),
        onTap: () => context.push('${Routes.publicFreelancer}/${f.id}'),
        onSave: () => BookmarkManager.instance.toggle(
          BookmarkManager.categoryFreelancers,
          f.id,
        ),
      ),
    );
  }

  Widget _startupsView(BuildContext context) {
    return CatalogView<Startup>(
      fetcher: _fetchStartups,
      showSearch: false,
      emptyTitle: 'No saved startups',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, s, _) => AppStartupCard(
        startup: s.copyWith(
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryStartups,
            s.id,
          ),
        ),
        onTap: () => context.push('${Routes.startupDetails}/${s.id}'),
        onSave: () => BookmarkManager.instance.toggle(
          BookmarkManager.categoryStartups,
          s.id,
        ),
      ),
    );
  }

  Widget _investorsView(BuildContext context) {
    return CatalogView<Investor>(
      fetcher: _fetchInvestors,
      showSearch: false,
      emptyTitle: 'No saved investors',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, i, _) => AppCard(
        onTap: () => context.push('${Routes.publicInvestor}/${i.id}'),
        child: Row(
          children: [
            AppAvatar(name: i.name, imageUrl: i.avatarUrl, size: 48),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i.name, style: context.text.titleSmall),
                  Text(
                    '${i.investorType} · ${i.company}',
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => BookmarkManager.instance.toggle(
                BookmarkManager.categoryInvestors,
                i.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foundersView(BuildContext context) {
    return CatalogView<Founder>(
      fetcher: _fetchFounders,
      showSearch: false,
      emptyTitle: 'No saved founders',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, f, _) => AppCard(
        onTap: () => context.push('${Routes.publicFounder}/${f.id}'),
        child: Row(
          children: [
            AppAvatar(name: f.name, imageUrl: f.avatarUrl, size: 48),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name, style: context.text.titleSmall),
                  Text(
                    '${f.founderType} · ${f.startupName}',
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                BookmarkManager.instance.isBookmarked(
                      BookmarkManager.categoryFounders,
                      f.id,
                    )
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => BookmarkManager.instance.toggle(
                BookmarkManager.categoryFounders,
                f.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _technologiesView(BuildContext context) {
    return CatalogView<Technology>(
      fetcher: _fetchTechnologies,
      showSearch: false,
      emptyTitle: 'No saved technologies',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, t, _) => AppCard(
        onTap: () => context.push('${Routes.technologyDetails}/${t.id}'),
        child: Row(
          children: [
            const Icon(Icons.code_rounded, color: AppColors.primary, size: 28),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name, style: context.text.titleSmall),
                  Text(t.category, style: context.text.labelSmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => BookmarkManager.instance.toggle(
                BookmarkManager.categoryTechnologies,
                t.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriesView(BuildContext context) {
    return CatalogView<CategoryItem>(
      fetcher: _fetchCategories,
      showSearch: false,
      emptyTitle: 'No saved categories',
      emptyIcon: Icons.bookmark_outline_rounded,
      itemBuilder: (context, c, _) => AppCard(
        onTap: () => context.push('${Routes.categoryDetails}/${c.id}'),
        child: Row(
          children: [
            const Icon(
              Icons.category_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: context.text.titleSmall),
                  Text(
                    '${c.projectsCount} projects · ${c.freelancersCount} freelancers',
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => BookmarkManager.instance.toggle(
                BookmarkManager.categoryCategories,
                c.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final role = user?.role ?? UserRole.freelancer;

    final List<Tab> tabs;
    final List<Widget> tabViews;

    switch (role) {
      case UserRole.freelancer:
        tabs = const [
          Tab(text: 'Projects'),
          Tab(text: 'Technologies'),
          Tab(text: 'Categories'),
          Tab(text: 'Searches & Filters'),
          Tab(text: 'Collections & Folders'),
          Tab(text: 'Resources & Blogs'),
        ];
        tabViews = [
          _projectsView(context),

          _technologiesView(context),
          _categoriesView(context),
          _buildSearchesAndFilters(context),
          _buildCollectionsAndFolders(context),
          _buildResourcesAndBlogs(context),
        ];
        break;
      case UserRole.client:
        tabs = const [
          Tab(text: 'Freelancers'),
          Tab(text: 'Projects'),
          Tab(text: 'Searches & Filters'),
          Tab(text: 'Collections & Folders'),
          Tab(text: 'Resources & Blogs'),
        ];
        tabViews = [
          _freelancersView(context),
          _projectsView(context),
          _buildSearchesAndFilters(context),
          _buildCollectionsAndFolders(context),
          _buildResourcesAndBlogs(context),
        ];
        break;
      case UserRole.investor:
        tabs = const [
          Tab(text: 'Startups'),
          Tab(text: 'Founders'),
          Tab(text: 'Searches & Filters'),
          Tab(text: 'Collections & Folders'),
          Tab(text: 'Resources & Blogs'),
        ];
        tabViews = [
          _startupsView(context),
          _foundersView(context),
          _buildSearchesAndFilters(context),
          _buildCollectionsAndFolders(context),
          _buildResourcesAndBlogs(context),
        ];
        break;
      case UserRole.founder:
        tabs = const [
          Tab(text: 'Investors'),
          Tab(text: 'Freelancers'),
          Tab(text: 'Searches & Filters'),
          Tab(text: 'Collections & Folders'),
          Tab(text: 'Resources & Blogs'),
        ];
        tabViews = [
          _investorsView(context),
          _freelancersView(context),
          _buildSearchesAndFilters(context),
          _buildCollectionsAndFolders(context),
          _buildResourcesAndBlogs(context),
        ];
        break;
    }

    return ListenableBuilder(
      listenable: BookmarkManager.instance,
      builder: (context, _) {
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Bookmarks'),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs,
              ),
            ),
            body: TabBarView(children: tabViews),
          ),
        );
      },
    );
  }

  Widget _buildSearchesAndFilters(BuildContext context) {
    final searches = BookmarkManager.instance.getSavedSearches();
    final filters = BookmarkManager.instance.getSavedFilters();
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SAVED SEARCHES', style: context.text.labelSmall),
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              onPressed: () => _showAddSearchDialog(context),
            ),
          ],
        ),
        if (searches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Text(
              'No saved searches yet',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        else
          for (final s in searches)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              onTap: () => context.showSnack('Executing search for "$s"…'),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                  AppSizes.hGapMd,
                  Expanded(child: Text(s, style: context.text.bodyMedium)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () =>
                        BookmarkManager.instance.removeSavedSearch(s),
                  ),
                ],
              ),
            ),
        AppSizes.vGapLg,
        Text('SAVED FILTERS', style: context.text.labelSmall),
        AppSizes.vGapMd,
        if (filters.isEmpty)
          const Text(
            'No saved filters yet',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        else
          for (final f in filters)
            AppCard(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              onTap: () => context.showSnack('Applying filter "${f['name']}"…'),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['name'] ?? 'Filter',
                          style: context.text.titleSmall,
                        ),
                        Text(
                          f.entries
                              .where((e) => e.key != 'name')
                              .map((e) => '${e.key}: ${e.value}')
                              .join(' · '),
                          style: context.text.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildCollectionsAndFolders(BuildContext context) {
    final collections = BookmarkManager.instance.getCollections();
    final folders = BookmarkManager.instance.getFolders();
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MY COLLECTIONS', style: context.text.labelSmall),
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              onPressed: () => _showAddDialog(
                context,
                'Collection',
                (v) => BookmarkManager.instance.addCollection(v),
              ),
            ),
          ],
        ),
        for (final c in collections)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            onTap: () => context.showSnack('Opening collection "$c"…'),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_special_outlined,
                  color: AppColors.warning,
                  size: 22,
                ),
                AppSizes.hGapMd,
                Expanded(child: Text(c, style: context.text.bodyMedium)),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
        AppSizes.vGapLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BOOKMARK FOLDERS', style: context.text.labelSmall),
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              onPressed: () => _showAddDialog(
                context,
                'Folder',
                (v) => BookmarkManager.instance.addFolder(v),
              ),
            ),
          ],
        ),
        for (final f in folders)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            onTap: () => context.showSnack('Opening folder "$f"…'),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_open_outlined,
                  color: AppColors.info,
                  size: 22,
                ),
                AppSizes.hGapMd,
                Expanded(child: Text(f, style: context.text.bodyMedium)),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResourcesAndBlogs(BuildContext context) {
    final resources = [
      ('Clean Architecture in Flutter', 'Course · 4h duration', 'lr1'),
      ('Due Diligence Checklist', 'Document · 12 pages', 'lr2'),
      ('Pitch Deck Fundamentals', 'Video · 45 mins', 'lr3'),
    ];
    final blogs = [
      ('How to Raise Seed Capital', 'by Rajiv Anand · 5m read', 'b1'),
      ('State of Flutter in 2026', 'by Priya Nair · 8m read', 'b2'),
      ('AgriTech Scale Strategies', 'by Ishaan Verma · 10m read', 'b3'),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Text('LEARNING RESOURCES', style: context.text.labelSmall),
        AppSizes.vGapMd,
        for (final r in resources)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            onTap: () => context.push(
              '${Routes.documentViewer}?type=PDF&name=${Uri.encodeComponent(r.$1)}',
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.success,
                  size: 22,
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1, style: context.text.titleSmall),
                      Text(r.$2, style: context.text.labelSmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.showSnack('Unsaved resource'),
                ),
              ],
            ),
          ),
        AppSizes.vGapLg,
        Text('BLOGS & ARTICLES', style: context.text.labelSmall),
        AppSizes.vGapMd,
        for (final b in blogs)
          AppCard(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            onTap: () => context.showSnack('Opening article…'),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.$1, style: context.text.titleSmall),
                      Text(b.$2, style: context.text.labelSmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => context.showSnack('Unsaved article'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAddSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Search Query'),
        content: AppTextField(
          controller: controller,
          hint: 'e.g. Flutter Remote',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                BookmarkManager.instance.addSavedSearch(controller.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    String type,
    Function(String) onSave,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New $type'),
        content: AppTextField(
          controller: controller,
          hint: 'e.g. New $type Name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
