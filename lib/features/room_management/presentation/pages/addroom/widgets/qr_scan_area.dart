/// QrScanArea — vùng bấm để mở scanner (UI only, không chứa logic)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              style: AppTextStyles.label13(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              'Bấm để chọn phương thức',
              style: AppTextStyles.titleSmall2(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon tượng trưng mã QR từ SVG
class _QrIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/home/qr.svg',
      width: 50.w,
      height: 50.w,
      colorFilter: ColorFilter.mode(
        AppColors.primary.withValues(alpha: 0.7),
        BlendMode.srcIn,
      ),
    );
  }
}
