import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ScanOptionSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ScanOptionSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn phương thức quét QR',
                  style: AppTextStyles.titleMedium(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
              title: Text(
                'Quét bằng camera',
                style: AppTextStyles.bodyMedium(color: Colors.black87),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: onCamera,
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
              title: Text(
                'Chọn ảnh từ thư viện',
                style: AppTextStyles.bodyMedium(color: Colors.black87),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: onGallery,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
