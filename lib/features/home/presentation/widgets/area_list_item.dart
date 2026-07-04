import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class AreaListItem extends StatelessWidget {
  final RoomWithDevices rwd;

  const AreaListItem({super.key, required this.rwd});

  @override
  Widget build(BuildContext context) {
    final room = rwd.room;
    final onlineCount = rwd.devices.where((d) => d.isOnline).length;
    final alertCount = rwd.devices.where((d) => d.hasAlert).length;
    final hasAlert = alertCount > 0;

    return InkWell(
      onTap: () {
        context.goNamed('device-list', pathParameters: {'roomId': room.id});
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(room.name, style: AppTextStyles.bodyMedium()),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                // Thiết bị
                Icon(
                  Icons.devices_rounded,
                  color: AppColors.textSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${room.totalDevices} thiết bị',
                  style: AppTextStyles.labelLarge(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 12.w),
                // Online
                Icon(Icons.circle, color: const Color(0xFF34C759), size: 8.sp),
                SizedBox(width: 4.w),
                Text(
                  '$onlineCount online',
                  style: AppTextStyles.labelLarge(
                    color: const Color(0xFF34C759),
                  ),
                ),
                const Spacer(),
                // Alert
                if (hasAlert) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFFF9800),
                    size: 16.sp,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '$alertCount cảnh báo',
                    style: AppTextStyles.labelLarge(
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
