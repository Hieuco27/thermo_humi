import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class GlobalSummaryBar extends StatelessWidget {
  final int totalRooms;
  final int totalDevices;
  final int totalOnline;
  final int totalAlerts;

  const GlobalSummaryBar({
    super.key,
    required this.totalRooms,
    required this.totalDevices,
    required this.totalOnline,
    required this.totalAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final Color textSec = const Color(0xFF6D6D71);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Row(
        children: [
          _GStat(
            label: 'Phòng',
            value: '$totalRooms',
            color: AppColors.backgroundColor,
            textSec: textSec,
          ),
          SizedBox(width: 6.w),
          _GStat(
            label: 'Thiết bị',
            value: '$totalDevices',
            color: AppColors.backgroundColor,
            textSec: textSec,
          ),
          SizedBox(width: 6.w),
          _GStat(
            label: 'Online',
            value: '$totalOnline',
            color: AppColors.appBarBg,
            textSec: textSec,
          ),
          SizedBox(width: 6.w),
          _GStat(
            label: 'Cảnh báo',
            value: '$totalAlerts',
            color: AppColors.dashboardWarning,
            textSec: textSec,
          ),
        ],
      ),
    );
  }
}

class _GStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textSec;

  const _GStat({
    required this.label,
    required this.value,
    required this.color,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = Colors.white;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.r),
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
            Text(value, style: AppTextStyles.labelLarge(color: color)),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.labelLarge()),
          ],
        ),
      ),
    );
  }
}
