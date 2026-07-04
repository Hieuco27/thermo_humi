import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class GlobalSummaryBar extends StatelessWidget {
  final int totalRooms;
  final int totalDevices;
  final int totalOnline;
  final int totalAlerts;
  final bool isDark;

  const GlobalSummaryBar({
    super.key,
    required this.totalRooms,
    required this.totalDevices,
    required this.totalOnline,
    required this.totalAlerts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color textSec = const Color(0xFF6D6D71);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _GStat(
            label: 'Phòng',
            value: '$totalRooms',
            color: const Color(0xFF007AFF),
            textSec: textSec,
          ),
          SizedBox(width: 8.w),
          _GStat(
            label: 'Thiết bị',
            value: '$totalDevices',
            color: Colors.black,
            textSec: textSec,
          ),
          SizedBox(width: 8.w),
          _GStat(
            label: 'Online',
            value: '$totalOnline',
            color: const Color(0xFF34C759),
            textSec: textSec,
          ),
          SizedBox(width: 8.w),
          _GStat(
            label: 'Alerts',
            value: '$totalAlerts',
            color: const Color(0xFFFF9800),
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
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleMedium(color: color)),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.bodySmall()),
          ],
        ),
      ),
    );
  }
}
