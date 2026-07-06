import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceSummaryStrip extends StatelessWidget {
  final int totalDevices;
  final int onlineCount;
  final int alertCount;

  const DeviceSummaryStrip({
    super.key,
    required this.totalDevices,
    required this.onlineCount,
    required this.alertCount,
  });

  @override
  Widget build(BuildContext context) {
    final offlineCount = totalDevices - onlineCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          _StatCard(
            label: 'Tổng',
            value: '$totalDevices',
            color: AppColors.backgroundColor,
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Online',
            value: '$onlineCount',
            color: AppColors.dashboardSuccess,
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Offline',
            value: '$offlineCount',
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          _StatCard(
            label: 'Cảnh báo',
            value: '$alertCount',
            color: alertCount > 0
                ? AppColors.dashboardWarning
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.labelLarge().copyWith(color: color),
            ),
            SizedBox(height: 2.h),
            Text(label, style: AppTextStyles.labelLarge()),
          ],
        ),
      ),
    );
  }
}
