import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class RoomManagementCard extends StatelessWidget {
  final RoomWithDevices rwd;
  final VoidCallback onTap;

  const RoomManagementCard({super.key, required this.rwd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final room = rwd.room;
    final hasDevices = room.totalDevices > 0;
    final allOnline = hasDevices && room.onlineDevices == room.totalDevices;
    final hasOffline = hasDevices && room.offlineDevices > 0;

    // Màu chấm trạng thái
    final Color statusColor = !hasDevices
        ? Colors.transparent
        : allOnline
        ? const Color(0xFF34C759)
        : Colors.red.shade400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
            // Room icon
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: Center(child: Image.asset('assets/icons/room/room.png')),
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: AppTextStyles.titleMedium(color: Colors.black),
                  ),
                  SizedBox(height: 4.h),
                  if (!hasDevices)
                    Text(
                      'Chưa có thiết bị',
                      style: AppTextStyles.bodyMedium(color: Colors.grey),
                    )
                  else
                    Row(
                      children: [
                        // Status dot
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${room.totalDevices} thiết bị · ${room.onlineDevices} online',
                          style: AppTextStyles.bodyMedium(
                            color: hasOffline
                                ? Colors.red.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
