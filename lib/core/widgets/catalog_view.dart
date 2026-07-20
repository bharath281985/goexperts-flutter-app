import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/constants/app_sizes.dart';
import '../bloc/list_bloc.dart';
import '../utils/enums.dart';
import 'app_filter_bottom_sheet.dart';
import 'app_search_bar.dart';
import 'paginated_list_view.dart';

/// End-to-end listing view: wires a [ListBloc] to a search bar, advanced
/// filters and a [PaginatedListView]. Every catalog screen uses this.
class CatalogView<T> extends StatelessWidget {
  const CatalogView({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    this.searchHint = 'Enter search keyword',
    this.filterSections,
    this.sortOptions = const [],
    this.separator,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.header,
    this.gridColumns = 1,
    this.showSearch = true,
    this.skeletonHeight = 120,
    this.floatingActionButton,
    this.onRefresh,
  });

  final ListFetcher<T> fetcher;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String searchHint;
  final List<FilterSection> Function()? filterSections;
  final List<String> sortOptions;
  final Widget? separator;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? header;
  final int gridColumns;
  final bool showSearch;
  final double skeletonHeight;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListBloc<T>>(
      create: (_) => ListBloc<T>(fetcher: fetcher)..add(const ListStarted()),
      child: _CatalogBody<T>(
        itemBuilder: itemBuilder,
        searchHint: searchHint,
        filterSections: filterSections,
        sortOptions: sortOptions,
        separator: separator,
        emptyTitle: emptyTitle,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
        header: header,
        gridColumns: gridColumns,
        showSearch: showSearch,
        skeletonHeight: skeletonHeight,
        floatingActionButton: floatingActionButton,
        onRefresh: onRefresh,
      ),
    );
  }
}

class _CatalogBody<T> extends StatefulWidget {
  const _CatalogBody({
    required this.itemBuilder,
    required this.searchHint,
    required this.filterSections,
    required this.sortOptions,
    required this.separator,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.header,
    required this.gridColumns,
    required this.showSearch,
    required this.skeletonHeight,
    this.floatingActionButton,
    this.onRefresh,
  });

  final Widget Function(BuildContext, T, int) itemBuilder;
  final String searchHint;
  final List<FilterSection> Function()? filterSections;
  final List<String> sortOptions;
  final Widget? separator;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? header;
  final int gridColumns;
  final bool showSearch;
  final double skeletonHeight;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  @override
  State<_CatalogBody<T>> createState() => _CatalogBodyState<T>();
}

class _CatalogBodyState<T> extends State<_CatalogBody<T>> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ListBloc<T>>().add(ListSearchChanged(value));
    });
  }

  Future<void> _openFilters() async {
    if (widget.filterSections == null) return;
    final bloc = context.read<ListBloc<T>>();
    final result = await AppFilterBottomSheet.show(
      context,
      sections: widget.filterSections!(),
      sortOptions: widget.sortOptions,
      selectedSort: bloc.state.query.sortBy,
    );
    if (result != null) {
      bloc.add(
        ListFiltersChanged(
          filters: {
            for (final entry in result.selections.entries)
              if (entry.value.isNotEmpty) entry.key: entry.value.toList(),
          },
          sortBy: result.sort,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListBloc<T>, ListState<T>>(
      builder: (context, state) {
        final bloc = context.read<ListBloc<T>>();
        final content = Column(
          children: [
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.md,
                  AppSizes.screenPadding,
                  AppSizes.sm,
                ),
                child: AppSearchBar(
                  controller: _searchController,
                  hint: widget.searchHint,
                  onChanged: _onSearch,
                  onFilterTap: widget.filterSections != null
                      ? _openFilters
                      : null,
                  filterCount: state.activeFilterCount,
                ),
              ),
            Expanded(
              child: PaginatedListView<T>(
                status: state.status,
                items: state.items,
                itemBuilder: widget.itemBuilder,
                separator: widget.separator,
                onRefresh: () async {
                  bloc.add(const ListRefreshed());
                  if (widget.onRefresh != null) {
                    await widget.onRefresh!();
                  }
                  await bloc.stream.firstWhere(
                    (s) => s.status != ViewStatus.refreshing,
                  );
                },
                onLoadMore: () => bloc.add(const ListLoadMore()),
                hasMore: state.hasMore,
                errorMessage: state.errorMessage,
                emptyTitle: widget.emptyTitle,
                emptyMessage: widget.emptyMessage,
                emptyIcon: widget.emptyIcon,
                header: widget.header,
                gridColumns: widget.gridColumns,
                skeletonHeight: widget.skeletonHeight,
              ),
            ),
          ],
        );

        if (widget.floatingActionButton != null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: content,
            floatingActionButton: widget.floatingActionButton,
          );
        }
        return content;
      },
    );
  }
}
