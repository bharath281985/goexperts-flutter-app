import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Chip-based multi select (skills, industries, technologies, etc.).
class AppMultiSelect extends StatefulWidget {
  const AppMultiSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
    this.wrap = true,
    this.categorizedOptions,
    this.initialCategory,
    this.maxVisibleOptions,
    this.onCategoryChanged,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String? label;
  final bool wrap;
  final Map<String, List<String>>? categorizedOptions;
  final String? initialCategory;
  final int? maxVisibleOptions;
  final ValueChanged<String>? onCategoryChanged;

  @override
  State<AppMultiSelect> createState() => _AppMultiSelectState();
}

class _AppMultiSelectState extends State<AppMultiSelect> {
  String? _activeCategory;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _activeCategory = _resolvedInitialCategory();
  }

  @override
  void didUpdateWidget(covariant AppMultiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categorizedOptions != widget.categorizedOptions) {
      _activeCategory = _resolvedInitialCategory();
      _isExpanded = false;
    }
  }

  String? _resolvedInitialCategory() {
    final categories = widget.categorizedOptions;
    if (categories == null || categories.isEmpty) return null;
    if (widget.initialCategory != null &&
        categories.containsKey(widget.initialCategory!)) {
      return widget.initialCategory;
    }
    return categories.keys.first;
  }

  void _toggle(String value) {
    final next = Set<String>.from(widget.selected);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final categoryMap = widget.categorizedOptions;
    final hasCategories = categoryMap != null && categoryMap.isNotEmpty;
    final sourceOptions = hasCategories
        ? categoryMap[_activeCategory] ?? const <String>[]
        : widget.options;
    final shouldLimitVisible =
        widget.maxVisibleOptions != null &&
        widget.maxVisibleOptions! > 0 &&
        sourceOptions.length > widget.maxVisibleOptions!;
    final optionsToRender = shouldLimitVisible && !_isExpanded
        ? sourceOptions.take(widget.maxVisibleOptions!).toList()
        : sourceOptions;

    final chips = optionsToRender.map((o) {
      final isSelected = widget.selected.contains(o);
      final selectedColor = AppColors.primary.withValues(alpha: 0.12);
      return FilterChip(
        label: Text(context.tr(o)),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => _toggle(o),
        selectedColor: selectedColor,
        side: BorderSide(
          color: isSelected ? AppColors.primary : context.theme.dividerColor,
        ),
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.primary
              : context.text.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(context.tr(widget.label!), style: context.text.titleSmall),
          AppSizes.vGapSm,
        ],
        if (hasCategories) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in categoryMap.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: ChoiceChip(
                      label: Text(context.tr(category)),
                      selected: category == _activeCategory,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          _activeCategory = category;
                          _isExpanded = false;
                        });
                        widget.onCategoryChanged?.call(category);
                      },
                    ),
                  ),
              ],
            ),
          ),
          AppSizes.vGapMd,
        ],
        if (widget.wrap)
          Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: chips)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in chips)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: c,
                  ),
              ],
            ),
          ),
        if (shouldLimitVisible) ...[
          AppSizes.vGapSm,
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(context.tr(_isExpanded ? 'Show less' : 'Show more')),
            ),
          ),
        ],
      ],
    );
  }
}
