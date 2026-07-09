import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';

class ThresholdLogTile extends StatelessWidget {
  final ThresholdChangeLog log;

  const ThresholdLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final isTemp = log.metricType.toLowerCase().contains('nhiệt độ');

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Color(0xFFD3E3F8), // light blue bg
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                log.userInitials,
                style: AppTextStyles.bodyMedium().copyWith(
                  color: AppColors.gradientEnd, // dark blue text
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.userName,
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      timeFormat.format(log.timestamp),
                      style: AppTextStyles.labelMedium(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Device & Metric type
                Row(
                  children: [
                    Icon(
                      isTemp ? Icons.thermostat : Icons.water_drop_outlined,
                      size: 14.w,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '${log.deviceName} · ${log.metricType}',
                        style: AppTextStyles.labelMedium(
                          color: Colors.grey[700]!,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Values
                Row(
                  children: [
                    Text(
                      log.oldValue,
                      style: AppTextStyles.labelLarge().copyWith(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14.w,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      log.newValue,
                      style: AppTextStyles.labelLarge().copyWith(
                        color: AppColors.gradientEnd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
