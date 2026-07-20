import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../utils/enums.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'app_loading_shimmer.dart';

/// The backbone of every listing screen.
///
/// Handles loading / empty / error / success states, pull-to-refresh and
/// infinite-scroll pagination in one place so feature screens stay declarative.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.status,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.errorMessage,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.padding = const EdgeInsets.all(AppSizes.screenPadding),
    this.separator,
    this.header,
    this.skeletonHeight = 96,
    this.gridColumns = 1,
  });

  final ViewStatus status;
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final String? errorMessage;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final EdgeInsets padding;
  final Widget? separator;
  final Widget? header;
  final double skeletonHeight;
  final int gridColumns;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.onLoadMore == null || !widget.hasMore) return;
    if (widget.status == ViewStatus.loadingMore) return;
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 40) {
      widget.onLoadMore!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == ViewStatus.loading) {
      return AppLoadingShimmer(height: widget.skeletonHeight);
    }
    if (widget.status == ViewStatus.failure && widget.items.isEmpty) {
      return AppErrorState(
        message: widget.errorMessage,
        onRetry: widget.onRefresh,
      );
    }
    if (widget.status == ViewStatus.empty ||
        (widget.status == ViewStatus.success && widget.items.isEmpty)) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          children: [
            if (widget.header != null) widget.header!,
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: AppEmptyState(
                title: widget.emptyTitle,
                message: widget.emptyMessage,
                icon: widget.emptyIcon,
                actionLabel: widget.emptyActionLabel,
                onAction: widget.onEmptyAction,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.gridColumns > 1 ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildList() {
    final showLoader = widget.status == ViewStatus.loadingMore;
    return ListView.separated(
      controller: _controller,
      padding: widget.padding,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          widget.items.length +
          (widget.header != null ? 1 : 0) +
          (showLoader ? 1 : 0),
      separatorBuilder: (_, i) {
        if (widget.header != null && i == 0) return const SizedBox.shrink();
        return widget.separator ?? AppSizes.vGapMd;
      },
      itemBuilder: (context, index) {
        var idx = index;
        if (widget.header != null) {
          if (index == 0) return widget.header!;
          idx = index - 1;
        }
        if (showLoader && idx == widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[idx], idx);
      },
    );
  }

  Widget _buildGrid() {
    return CustomScrollView(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.gridColumns,
              mainAxisSpacing: AppSizes.md,
              crossAxisSpacing: AppSizes.md,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  widget.itemBuilder(context, widget.items[index], index),
              childCount: widget.items.length,
            ),
          ),
        ),
        if (widget.status == ViewStatus.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
