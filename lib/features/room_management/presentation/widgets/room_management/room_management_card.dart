import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class RoomManagementCard extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback onTap;

  const RoomManagementCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDevices = room.totalDevices > 0;

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
                  Text(room.name, style: AppTextStyles.titleMediumLogin()),
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
                          decoration: BoxDecoration(shape: BoxShape.circle),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${room.totalDevices} thiết bị',
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Chevron
            Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
