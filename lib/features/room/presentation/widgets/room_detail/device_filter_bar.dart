import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

enum DeviceFilterType { all, online, offline, alert }

class DeviceFilterBar extends StatelessWidget {
  final DeviceFilterType activeFilter;
  final int totalCount;
  final int onlineCount;
  final int offlineCount;
  final int alertCount;
  final bool isSelectionMode;
  final ValueChanged<DeviceFilterType> onFilterChanged;
  final VoidCallback? onSelectModeToggle;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onShareTap;

  const DeviceFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.onlineCount,
    required this.offlineCount,
    required this.alertCount,
    this.isSelectionMode = false,
    required this.onFilterChanged,
    this.onSelectModeToggle,
    this.onCancelSelection,
    this.onShareTap,
  });

  String _getLabel(DeviceFilterType type) {
    switch (type) {
      case DeviceFilterType.all:
        return 'Tất cả';
      case DeviceFilterType.online:
        return 'Online';
      case DeviceFilterType.offline:
        return 'Offline';
      case DeviceFilterType.alert:
        return 'Cảnh báo';
    }
  }

  int _getCount(DeviceFilterType type) {
    switch (type) {
      case DeviceFilterType.all:
        return totalCount;
      case DeviceFilterType.online:
        return onlineCount;
      case DeviceFilterType.offline:
        return offlineCount;
      case DeviceFilterType.alert:
        return alertCount;
    }
  }

  Color _getColor(DeviceFilterType type) {
    switch (type) {
      case DeviceFilterType.all:
        return AppColors.primary;
      case DeviceFilterType.online:
        return AppColors.dashboardSuccess;
      case DeviceFilterType.offline:
        return AppColors.textSecondary;
      case DeviceFilterType.alert:
        return AppColors.dashboardWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLabel = _getLabel(activeFilter);
    final activeCount = _getCount(activeFilter);
    final activeColor = _getColor(activeFilter);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          PopupMenuButton<DeviceFilterType>(
            offset: Offset(0, 40.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            elevation: 0,
            constraints: BoxConstraints(minWidth: 200.w),
            onSelected: (DeviceFilterType result) {
              HapticFeedback.lightImpact();
              onFilterChanged(result);
            },
            itemBuilder: (BuildContext context) {
              final items = <PopupMenuEntry<DeviceFilterType>>[];
              for (var i = 0; i < DeviceFilterType.values.length; i++) {
                final type = DeviceFilterType.values[i];
                final isSelected = activeFilter == type;
                items.add(
                  PopupMenuItem<DeviceFilterType>(
                    value: type,
                    height: 45.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _getColor(type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _getLabel(type),
                          style: AppTextStyles.bodyMedium(color: Colors.black87)
                              .copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${_getCount(type)}',
                          style: AppTextStyles.bodyMedium(
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        SizedBox(
                          width: 24.w,
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 20.w,
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
                if (i < DeviceFilterType.values.length - 1) {
                  items.add(
                    PopupMenuDivider(height: 1, color: Colors.grey.shade200),
                  );
                }
              }
              return items;
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '$activeLabel  ($activeCount)',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.black87,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.w,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (isSelectionMode) ...[
            TextButton(
              onPressed: onCancelSelection,
              child: Text(
                'Hủy',
                style: AppTextStyles.bodyMedium(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: onShareTap,
              child: Text(
                'Chia sẻ',
                style: AppTextStyles.bodyMedium(color: AppColors.primary),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: onSelectModeToggle,
              child: Text(
                'Chọn',
                style: AppTextStyles.bodyMedium(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
