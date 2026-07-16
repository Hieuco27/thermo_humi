/// DeviceRecognizedBanner — dòng xác nhận "Đã nhận diện thiết bị: {mã}"
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceRecognizedBanner extends StatelessWidget {
  final String deviceCode;
  final String? source; // 'qr' | 'imei' | null

  const DeviceRecognizedBanner({
    super.key,
    required this.deviceCode,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final label = source == 'qr' ? 'QR' : 'IMEI';

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF34C759).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: const Color(0xFF34C759), size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall(color: Colors.black87),
                  children: [
                    TextSpan(
                      text: 'Đã nhận diện ($label): ',
                      style: AppTextStyles.bodySmall(color: Colors.grey.shade600),
                    ),
                    TextSpan(
                      text: deviceCode,
                      style: AppTextStyles.label13(
                        color: const Color(0xFF1C7C44),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
