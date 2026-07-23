import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class AreaListItem extends StatelessWidget {
  final RoomEntity room;

  const AreaListItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final onlineCount = room.onlineDevices;
    final alertCount = room.alertCount;
    final hasAlert = alertCount > 0;

    return InkWell(
      onTap: () {
        context.goNamed('device-list', pathParameters: {'roomId': room.id});
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                  size: 22.sp,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                // Thiết bị
                Opacity(
                  opacity: 0.6,
                  child: SvgPicture.asset(
                    'assets/icons/room/device.svg',
                    width: 20.sp,
                    height: 20.sp,
                    colorFilter: ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Text(
                  '${room.totalDevices} thiết bị',
                  style: AppTextStyles.labelLarge(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 20.w),
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
                  Opacity(
                    opacity: 0.6,
                    child: SvgPicture.asset(
                      'assets/icons/home/canhBao.svg',
                      width: 16.sp,
                      height: 16.sp,
                    ),
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
