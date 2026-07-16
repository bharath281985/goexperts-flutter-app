import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../utils/formatters.dart';

/// Tappable date field wrapping the Material date picker.
class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select date',
    this.firstDate,
    this.lastDate,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.text.titleSmall),
          AppSizes.vGapSm,
        ],
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: () => _pick(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today_rounded, size: AppSizes.iconSm),
            ),
            child: Text(
              value != null ? Formatters.date(value!) : hint,
              style: value != null
                  ? context.text.bodyMedium
                  : context.text.bodyMedium?.copyWith(color: context.text.bodySmall?.color),
            ),
          ),
        ),
      ],
    );
  }
}
