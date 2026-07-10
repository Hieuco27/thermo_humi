import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceActionSheet extends StatelessWidget {
  final String deviceName;
  final bool isAdmin;
  final VoidCallback onUnassign;
  final VoidCallback onDeleteFromSystem;

  const DeviceActionSheet({
    super.key,
    required this.deviceName,
    required this.isAdmin,
    required this.onUnassign,
    required this.onDeleteFromSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  deviceName,
                  style: AppTextStyles.titleMedium(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Colors.black87,
                size: 22.sp,
              ),
              title: Text(
                'Chuyển khỏi phòng này',
                style: AppTextStyles.bodyMedium(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              onTap: () {
                context.pop();
                onUnassign();
              },
            ),
            if (isAdmin)
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                  size: 22.sp,
                ),
                title: Text(
                  'Xoá thiết bị khỏi hệ thống',
                  style: AppTextStyles.bodyMedium(color: Colors.red.shade600),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                onTap: () {
                  context.pop();
                  onDeleteFromSystem();
                },
              ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
