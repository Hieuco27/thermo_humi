import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class AddRoomButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddRoomButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.add_rounded, size: 20.sp),
        label: Text(
          'Thêm phòng mới',
          style: AppTextStyles.bodyMedium().copyWith(
            color: AppColors.background,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.gradientEnd,
          foregroundColor: AppColors.background,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
