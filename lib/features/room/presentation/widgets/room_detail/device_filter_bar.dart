import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

enum DeviceFilterType { all, online, offline, alert }

class DeviceFilterBar extends StatelessWidget {
  final DeviceFilterType activeFilter;
  final int alertCount;
  final ValueChanged<DeviceFilterType> onFilterChanged;

  const DeviceFilterBar({
    super.key,
    required this.activeFilter,
    required this.alertCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = AppColors.background;

    return Container(
      color: bg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          _DeviceFilterChip(
            label: 'Tất cả',
            isActive: activeFilter == DeviceFilterType.all,
            onTap: () => onFilterChanged(DeviceFilterType.all),
          ),
          SizedBox(width: 4.w),
          _DeviceFilterChip(
            label: 'Online',
            isActive: activeFilter == DeviceFilterType.online,
            onTap: () => onFilterChanged(DeviceFilterType.online),
            activeColor: AppColors.dashboardSuccess,
          ),
          SizedBox(width: 4.w),
          _DeviceFilterChip(
            label: 'Offline',
            isActive: activeFilter == DeviceFilterType.offline,
            onTap: () => onFilterChanged(DeviceFilterType.offline),
            activeColor: AppColors.textSecondary,
          ),
          SizedBox(width: 4.w),
          _DeviceFilterChip(
            label: 'Cảnh báo',
            isActive: activeFilter == DeviceFilterType.alert,
            badge: alertCount > 0 ? '$alertCount' : null,
            onTap: () => onFilterChanged(DeviceFilterType.alert),
            activeColor: AppColors.dashboardWarning,
          ),
        ],
      ),
    );
  }
}

class _DeviceFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;
  final Color activeColor;

  const _DeviceFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
    this.activeColor = const Color(0xFF007AFF),
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isActive ? activeColor : AppColors.background;
    final Color textColor = isActive ? Colors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? activeColor : AppColors.textFieldBorder,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.titleSmall2().copyWith(color: textColor),
            ),
            if (badge != null) ...[
              SizedBox(width: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(badge!, style: AppTextStyles.titleSmall()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
