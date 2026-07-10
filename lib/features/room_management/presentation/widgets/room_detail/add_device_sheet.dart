import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

/// Bottom sheet "Thêm thiết bị vào phòng này"
/// Gồm 2 lựa chọn: Thêm mới (QR/IMEI) hoặc Chọn từ thiết bị chưa gán phòng
class AddDeviceSheet extends StatelessWidget {
  final VoidCallback onAddNew;
  final VoidCallback onSelectUnassigned;

  const AddDeviceSheet({
    super.key,
    required this.onAddNew,
    required this.onSelectUnassigned,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _SheetOption(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Thêm thiết bị mới (quét QR/IMEI)',
                    subtitle: 'Kích hoạt và thêm vào phòng này',
                    onTap: () {
                      Navigator.pop(context);
                      onAddNew();
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _SheetOption(
                    icon: Icons.devices_other_rounded,
                    title: 'Chọn từ thiết bị chưa gán phòng',
                    subtitle: 'Gán thiết bị đang chờ vào phòng này',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectUnassigned();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: Colors.black87, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium(color: Colors.black),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
