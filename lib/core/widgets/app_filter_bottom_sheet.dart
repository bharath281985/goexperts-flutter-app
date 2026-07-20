import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import 'app_multi_select.dart';
import 'app_primary_button.dart';
import 'app_secondary_button.dart';

/// One selectable filter value. [value] is sent to the API; [label] is shown.
class FilterOption {
  const FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// A single filter section rendered as chips or a searchable multi-pick list.
class FilterSection {
  FilterSection({
    required this.key,
    required this.title,
    List<String>? options,
    List<FilterOption>? optionItems,
    Set<String>? selected,
    this.singleSelect = false,
    this.searchable = false,
    this.searchHint = 'Search…',
  }) : optionItems =
           optionItems ??
           (options ?? const <String>[])
               .map((o) => FilterOption(value: o, label: o))
               .toList(),
       selected = selected ?? <String>{};

  final String key;
  final String title;
  final List<FilterOption> optionItems;
  Set<String> selected;
  final bool singleSelect;
  final bool searchable;
  final String searchHint;

  List<String> get options => optionItems.map((o) => o.label).toList();
}

/// Generic advanced-filter bottom sheet with sort, reset and apply.
/// Returns the selected values keyed by section, or null when dismissed.
class AppFilterBottomSheet extends StatefulWidget {
  const AppFilterBottomSheet({
    super.key,
    required this.sections,
    this.sortOptions = const [],
    this.selectedSort,
  });

  final List<FilterSection> sections;
  final List<String> sortOptions;
  final String? selectedSort;

  static Future<FilterResult?> show(
    BuildContext context, {
    required List<FilterSection> sections,
    List<String> sortOptions = const [],
    String? selectedSort,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AppFilterBottomSheet(
        sections: sections,
        sortOptions: sortOptions,
        selectedSort: selectedSort,
      ),
    );
  }

  @override
  State<AppFilterBottomSheet> createState() => _AppFilterBottomSheetState();
}

class _AppFilterBottomSheetState extends State<AppFilterBottomSheet> {
  late final Map<String, Set<String>> _selections = {
    for (final s in widget.sections) s.key: Set<String>.from(s.selected),
  };
  late String? _sort = widget.selectedSort;
  final Map<String, String> _sectionSearch = {};

  void _reset() {
    setState(() {
      for (final s in widget.sections) {
        _selections[s.key] = <String>{};
      }
      _sort = null;
      _sectionSearch.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: context.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                children: [
                  Text(context.tr('Filters'), style: context.text.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text(context.tr('Reset')),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: [
                  if (widget.sortOptions.isNotEmpty) ...[
                    AppMultiSelect(
                      label: 'Sort by',
                      options: widget.sortOptions,
                      selected: _sort == null ? {} : {_sort!},
                      onChanged: (v) =>
                          setState(() => _sort = v.isEmpty ? null : v.last),
                    ),
                    AppSizes.vGapLg,
                  ],
                  for (final s in widget.sections) ...[
                    if (s.searchable)
                      _SearchableMultiPick(
                        title: s.title,
                        hint: s.searchHint,
                        options: s.optionItems,
                        selected: _selections[s.key]!,
                        searchQuery: _sectionSearch[s.key] ?? '',
                        onSearchChanged: (q) =>
                            setState(() => _sectionSearch[s.key] = q),
                        onChanged: (v) => setState(() {
                          _selections[s.key] = s.singleSelect && v.isNotEmpty
                              ? {v.last}
                              : v;
                        }),
                      )
                    else
                      AppMultiSelect(
                        label: s.title,
                        options: s.optionItems.map((o) => o.label).toList(),
                        selected: {
                          for (final value in _selections[s.key]!)
                            s.optionItems
                                .firstWhere(
                                  (o) => o.value == value,
                                  orElse: () =>
                                      FilterOption(value: value, label: value),
                                )
                                .label,
                        },
                        onChanged: (labels) {
                          final byLabel = {
                            for (final o in s.optionItems) o.label: o.value,
                          };
                          setState(() {
                            final next = labels
                                .map((label) => byLabel[label] ?? label)
                                .toSet();
                            _selections[s.key] =
                                s.singleSelect && next.isNotEmpty
                                ? {next.last}
                                : next;
                          });
                        },
                      ),
                    AppSizes.vGapLg,
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Apply Filters',
                      onPressed: () => Navigator.pop(
                        context,
                        FilterResult(selections: _selections, sort: _sort),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchableMultiPick extends StatelessWidget {
  const _SearchableMultiPick({
    required this.title,
    required this.hint,
    required this.options,
    required this.selected,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final List<FilterOption> options;
  final Set<String> selected;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? options
        : options.where((o) => o.label.toLowerCase().contains(query)).toList();
    final selectedLabels = options
        .where((o) => selected.contains(o.value))
        .map((o) => o.label)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(title), style: context.text.titleSmall),
        AppSizes.vGapSm,
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: context.tr(hint),
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        if (selectedLabels.isNotEmpty) ...[
          AppSizes.vGapSm,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final option in options.where(
                (o) => selected.contains(o.value),
              ))
                InputChip(
                  label: Text(context.tr(option.label)),
                  selected: true,
                  onDeleted: () {
                    final next = Set<String>.from(selected)
                      ..remove(option.value);
                    onChanged(next);
                  },
                ),
            ],
          ),
        ],
        AppSizes.vGapSm,
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Text(
                    context.tr('No matches'),
                    style: context.text.bodySmall?.copyWith(
                      color: context.text.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final option = filtered[index];
                    final isSelected = selected.contains(option.value);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isSelected,
                      activeColor: AppColors.primary,
                      title: Text(context.tr(option.label)),
                      onChanged: (_) {
                        final next = Set<String>.from(selected);
                        if (isSelected) {
                          next.remove(option.value);
                        } else {
                          next.add(option.value);
                        }
                        onChanged(next);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class FilterResult {
  const FilterResult({required this.selections, this.sort});
  final Map<String, Set<String>> selections;
  final String? sort;

  int get activeCount =>
      selections.values.fold<int>(0, (sum, set) => sum + set.length) +
      (sort != null ? 1 : 0);
}
