import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_file_upload.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/repositories/review_repository.dart';

/// Reusable review-submission bottom sheet (freelancer, client, startup,
/// investor, service, project reviews). Rating + comment + media + reply-ready.
class ReviewFormSheet extends StatefulWidget {
  const ReviewFormSheet({super.key, required this.targetType, this.targetName, this.targetId});

  final String targetType;
  final String? targetName;
  final String? targetId;

  static Future<bool> show(
    BuildContext context, {
    required String targetType,
    String? targetName,
    String? targetId,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ReviewFormSheet(targetType: targetType, targetName: targetName, targetId: targetId),
      ),
    );
    return result ?? false;
  }

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  double _rating = 0;
  final _comment = TextEditingController();
  String? _media;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      context.showSnack('Please select a rating', isError: true);
      return;
    }
    setState(() => _submitting = true);
    await sl<ReviewRepository>().submitReview(
      rating: _rating,
      comment: _comment.text.trim(),
      targetType: widget.targetType,
      targetId: widget.targetId,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop(true);
    context.showSnack('Thanks for your review!');
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
            Text('Review ${widget.targetName ?? widget.targetType}', style: context.text.titleLarge),
            AppSizes.vGapLg,
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i.toDouble()),
                      icon: Icon(
                        i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.warning,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ),
            Center(
              child: Text(
                _rating == 0 ? 'Tap to rate' : _ratingLabel(_rating),
                style: context.text.labelMedium,
              ),
            ),
            AppSizes.vGapLg,
            AppTextField(
              controller: _comment,
              label: 'Your review',
              hint: 'Share your experience…',
              maxLines: 5,
            ),
            AppSizes.vGapLg,
            AppFileUpload(
              label: 'Add photos / video (optional)',
              hint: 'PNG, JPG or MP4',
              icon: Icons.add_a_photo_outlined,
              fileName: _media,
              onTap: () => setState(() => _media = 'review_photo.jpg'),
            ),
            AppSizes.vGapXl,
            AppPrimaryButton(label: 'Submit Review', isLoading: _submitting, onPressed: _submit),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double r) => switch (r.toInt()) {
        1 => 'Poor',
        2 => 'Fair',
        3 => 'Good',
        4 => 'Very good',
        _ => 'Excellent',
      };
}
