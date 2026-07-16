import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Dashed upload dropzone. Wire [onTap] to file_picker / image_picker.
class AppFileUpload extends StatelessWidget {
  const AppFileUpload({
    super.key,
    required this.label,
    this.hint = 'PDF, DOCX, PNG · up to 10MB',
    this.icon = Icons.cloud_upload_outlined,
    this.onTap,
    this.fileName,
  });

  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      onTap: onTap,
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            children: [
              Icon(
                hasFile ? Icons.description_outlined : icon,
                size: 34,
                color: AppColors.primary,
              ),
              AppSizes.vGapSm,
              Text(hasFile ? fileName! : label,
                  style: context.text.titleSmall, textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(hasFile ? 'Tap to replace' : hint,
                  style: context.text.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple dashed border container drawn with a CustomPainter.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color: context.theme.dividerColor),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppSizes.radiusLg),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) => oldDelegate.color != color;
}
