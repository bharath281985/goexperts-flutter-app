import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Reusable search bar with optional filter button.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Enter search keyword',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.filterCount = 0,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final int filterCount;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            readOnly: readOnly,
            onTap: onTap,
            autofocus: autofocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.tr(hint),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: AppSizes.iconMd,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: AppSizes.lg,
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          AppSizes.hGapMd,
          _FilterButton(count: filterCount, onTap: onFilterTap!),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: Material(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: Container(
            width: AppSizes.inputHeight,
            height: AppSizes.inputHeight,
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.dividerColor),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.tune_rounded, size: AppSizes.iconMd),
          ),
        ),
      ),
    );
  }
}
