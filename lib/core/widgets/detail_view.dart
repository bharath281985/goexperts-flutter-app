import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/detail_cubit.dart';
import '../utils/enums.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';
import 'app_loading_shimmer.dart';
import 'app_scaffold.dart';

/// A reusable scaffold for every standalone detail page.
///
/// Wires a [DetailCubit] to a consistent header + loading/empty/error/success
/// lifecycle. Concrete pages just provide the fetcher and a content builder.
class DetailView<T> extends StatelessWidget {
  const DetailView({
    super.key,
    required this.title,
    required this.fetcher,
    required this.builder,
    this.actions,
    this.bottomBar,
    this.emptyTitle = 'Not found',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
  });

  final String title;
  final DetailFetcher<T> fetcher;
  final Widget Function(BuildContext context, T item) builder;
  final List<Widget>? actions;
  final Widget Function(BuildContext context, T item)? bottomBar;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailCubit<T>>(
      create: (_) => DetailCubit<T>(fetcher)..load(),
      child: BlocBuilder<DetailCubit<T>, DetailState<T>>(
        builder: (context, state) {
          return AppScaffold(
            appBar: AppBar(title: Text(title), actions: actions),
            bottomNavigationBar: state.status == ViewStatus.success && bottomBar != null
                ? SafeArea(child: bottomBar!(context, state.item as T))
                : null,
            body: switch (state.status) {
              ViewStatus.loading => const AppLoadingShimmer(itemCount: 5, height: 96),
              ViewStatus.failure => AppErrorState(
                  message: state.errorMessage,
                  onRetry: () => context.read<DetailCubit<T>>().load(),
                ),
              ViewStatus.empty => AppEmptyState(
                  title: emptyTitle,
                  message: emptyMessage,
                  icon: emptyIcon,
                ),
              _ => state.item == null
                  ? const AppLoadingShimmer(itemCount: 5, height: 96)
                  : builder(context, state.item as T),
            },
          );
        },
      ),
    );
  }
}

/// Small helper widgets shared by detail pages to keep them consistent.
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            if (trailing case final t?) t,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
