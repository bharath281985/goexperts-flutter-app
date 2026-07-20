import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Labeled dropdown field.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    this.value,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final T? value;
  final String? label;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(context.tr(label!), style: context.text.titleSmall),
          AppSizes.vGapSm,
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint == null ? null : context.tr(hint!),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: AppSizes.iconMd)
                : null,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    context.tr(itemLabel(e)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
