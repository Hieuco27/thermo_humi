import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class RoomDeviceTile extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onMoreTap;
  final bool showRoomBadge;

  const RoomDeviceTile({
    super.key,
    required this.device,
    required this.onMoreTap,
    this.showRoomBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == DeviceStatus.online;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device icon
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.sensors_rounded,
              size: 22.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 8.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF34C759)
                            : Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      device.name,
                      style: AppTextStyles.titleMedium(color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                if (showRoomBadge) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: device.roomName != null
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      device.roomName ?? 'Chưa gán phòng',
                      style: AppTextStyles.label13(
                        color: device.roomName != null
                            ? AppColors.primary
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
                Text(
                  device.serialNumber ?? 'Không có SN',
                  style: AppTextStyles.label13(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // More button
          IconButton(
            onPressed: onMoreTap,
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 22.sp,
              color: Colors.grey.shade500,
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(6.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
