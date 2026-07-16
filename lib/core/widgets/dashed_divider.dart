import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedDividerPainter(color: AppColors.projectDash),
      child: const SizedBox.expand(),
    );
  }
}

class DashedDividerPainter extends CustomPainter {
  const DashedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3;
    const dashWidth = 7.0;
    const dashGap = 7.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
