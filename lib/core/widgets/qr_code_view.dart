import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';

/// A deterministic faux-QR placeholder rendered from a string seed.
///
/// This is a visual placeholder only — swap for the `qr_flutter` package when
/// real QR generation is wired in.
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(painter: _QrPainter(data)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);
  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    const cells = 21;
    final cell = size.width / cells;
    final paint = Paint()..color = AppColors.primaryBlack;
    final seed = data.hashCode;

    bool filled(int x, int y) {
      // Finder patterns in three corners.
      bool inFinder(int fx, int fy) => x >= fx && x < fx + 7 && y >= fy && y < fy + 7;
      if (inFinder(0, 0) || inFinder(cells - 7, 0) || inFinder(0, cells - 7)) {
        final lx = x % 7 == 0 || (x - (x ~/ 7) * 7) == 6;
        final within = (x % 7 >= 2 && x % 7 <= 4 && y % 7 >= 2 && y % 7 <= 4);
        return lx || y % 7 == 0 || y % 7 == 6 || within;
      }
      return (seed >> ((x * 31 + y) % 31)) & 1 == 1;
    }

    for (var x = 0; x < cells; x++) {
      for (var y = 0; y < cells; y++) {
        if (filled(x, y)) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.data != data;
}
