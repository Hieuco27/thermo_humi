import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: Color(0xFFD3E3F8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'HN',
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14.w,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text('Thái Hiếu', style: AppTextStyles.bodyLarge()),
        SizedBox(height: 2.h),
        Text(
          '+84 912 345 678',
          style: AppTextStyles.titleSmall().copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD3E3F8), // bg-accent
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Admin · HMS Technology',
            style: AppTextStyles.titleSmall2().copyWith(
              color: AppColors.gradientEnd,
            ),
          ),
        ),
      ],
    );
  }
}
