import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class AddDeviceOptionSheet extends StatelessWidget {
  final String roomName;
  final VoidCallback onAddNew;
  final VoidCallback onSelectUnassigned;

  const AddDeviceOptionSheet({
    super.key,
    required this.roomName,
    required this.onAddNew,
    required this.onSelectUnassigned,
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
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thêm thiết bị vào $roomName',
                  style: AppTextStyles.titleMedium(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.black87,
                size: 22.sp,
              ),
              title: Text(
                'Thêm thiết bị mới (quét QR/IMEI)',
                style: AppTextStyles.bodyMedium(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: () {
                context.pop();
                onAddNew();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.format_list_bulleted_rounded,
                color: Colors.black87,
                size: 22.sp,
              ),
              title: Text(
                'Chọn từ thiết bị chưa gán phòng',
                style: AppTextStyles.bodyMedium(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: () {
                context.pop();
                onSelectUnassigned();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
