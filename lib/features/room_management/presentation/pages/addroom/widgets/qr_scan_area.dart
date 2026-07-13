/// QrScanArea — vùng bấm để mở scanner (UI only, không chứa logic)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class QrScanArea extends StatelessWidget {
  final VoidCallback onTap;

  const QrScanArea({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 28.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid, // dashed via CustomPainter nếu muốn
          ),
          color: AppColors.primary.withValues(alpha: 0.04),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QrIcon(),
            SizedBox(height: 12.h),
            Text(
              'Quét mã QR hoặc chọn từ thư viện',
              style: AppTextStyles.bodySmall(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              'Bấm để chọn phương thức',
              style: AppTextStyles.labelSmall(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon 4 ô vuông tượng trưng mã QR
class _QrIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: CustomPaint(painter: _QrIconPainter()),
    );
  }
}

class _QrIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final gap = size.width * 0.06;
    final cell = (size.width - gap * 3) / 2;
    final r = 3.0;

    // 4 ô vuông bo góc
    final positions = [
      Offset(gap, gap),
      Offset(gap + cell + gap, gap),
      Offset(gap, gap + cell + gap),
      Offset(gap + cell + gap, gap + cell + gap),
    ];

    for (final pos in positions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, cell, cell), Radius.circular(r)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
