import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import 'app_file_upload.dart';
import 'app_primary_button.dart';
import 'app_text_field.dart';

/// Reusable report bottom sheet for any entity (user, project, startup,
/// investor, company, message, review, portfolio, …).
class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key, required this.targetType, this.targetName});

  final String targetType;
  final String? targetName;

  static Future<bool> show(BuildContext context, {required String targetType, String? targetName}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ReportSheet(targetType: targetType, targetName: targetName),
      ),
    );
    return result ?? false;
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  static const _reasons = ['Spam', 'Fraud', 'Fake profile', 'Abuse', 'Inappropriate content', 'Other'];
  String? _reason;
  final _details = TextEditingController();
  String? _attachment;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: AppColors.danger),
                AppSizes.hGapSm,
                Expanded(
                  child: Text('Report ${widget.targetType}', style: context.text.titleLarge),
                ),
              ],
            ),
            if (widget.targetName != null) ...[
              AppSizes.vGapXs,
              Text(widget.targetName!, style: context.text.bodySmall),
            ],
            AppSizes.vGapLg,
            Text('Reason', style: context.text.titleSmall),
            AppSizes.vGapSm,
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final r in _reasons)
                  ChoiceChip(
                    label: Text(r),
                    selected: _reason == r,
                    onSelected: (_) => setState(() => _reason = r),
                    selectedColor: AppColors.danger.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: _reason == r ? AppColors.danger : context.text.bodyMedium?.color,
                      fontWeight: _reason == r ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(color: _reason == r ? AppColors.danger : context.theme.dividerColor),
                  ),
              ],
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _details,
              label: 'Details (optional)',
              hint: 'Add any additional context…',
              maxLines: 3,
            ),
            AppSizes.vGapLg,
            AppFileUpload(
              label: 'Add evidence (optional)',
              hint: 'Screenshot or document',
              fileName: _attachment,
              onTap: () => setState(() => _attachment = 'evidence_screenshot.png'),
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(
              label: 'Submit Report',
              gradient: false,
              onPressed: _reason == null
                  ? null
                  : () {
                      Navigator.of(context).pop(true);
                      context.showSnack('Report submitted. Our team will review it.');
                    },
            ),
          ],
        ),
      ),
    );
  }
}
