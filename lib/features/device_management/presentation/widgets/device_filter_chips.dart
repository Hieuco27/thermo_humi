import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_state.dart';

class DeviceFilterChips extends StatelessWidget {
  const DeviceFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeviceManagementCubit>();

    return BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter Dropdown
                PopupMenuButton<String>(
                  offset: Offset(0, 40.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  color: Colors.white,
                  elevation: 0,
                  onSelected: (val) {
                    HapticFeedback.lightImpact();
                    cubit.onStatusFilterChanged(val);
                  },
                  itemBuilder: (context) => [
                    _buildPopupItem<String>(
                      value: 'all',
                      label: 'Tất cả trạng thái',
                      isSelected: state.statusFilter == 'all',
                    ),
                    PopupMenuDivider(height: 1, color: Colors.grey.shade200),
                    _buildPopupItem<String>(
                      value: 'online',
                      label: 'Online',
                      isSelected: state.statusFilter == 'online',
                    ),
                    PopupMenuDivider(height: 1, color: Colors.grey.shade200),
                    _buildPopupItem<String>(
                      value: 'offline',
                      label: 'Offline',
                      isSelected: state.statusFilter == 'offline',
                    ),
                  ],
                  child: _buildDropdownFilterButton(
                    label: state.statusFilter == 'all'
                        ? 'Tất cả trạng thái'
                        : (state.statusFilter == 'online'
                              ? 'Online'
                              : 'Offline'),
                    isActive: state.statusFilter != 'all',
                  ),
                ),
                SizedBox(width: 8.w),
                // Room Filter Dropdown
                PopupMenuButton<String>(
                  offset: Offset(0, 40.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  color: Colors.white,
                  elevation: 0,
                  onSelected: (val) {
                    HapticFeedback.lightImpact();
                    cubit.onRoomFilterChanged(val == 'all' ? null : val);
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[
                      _buildPopupItem<String>(
                        value: 'all',
                        label: 'Tất cả phòng',
                        isSelected: state.roomIdFilter == null,
                      ),
                    ];
                    if (state.rooms.isNotEmpty) {
                      items.add(
                        PopupMenuDivider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                      );
                    }
                    for (int i = 0; i < state.rooms.length; i++) {
                      final room = state.rooms[i];
                      items.add(
                        _buildPopupItem<String>(
                          value: room.id,
                          label: room.name,
                          isSelected: state.roomIdFilter == room.id,
                        ),
                      );
                      if (i < state.rooms.length - 1) {
                        items.add(
                          PopupMenuDivider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                        );
                      }
                    }
                    return items;
                  },
                  child: _buildDropdownFilterButton(
                    label: state.roomIdFilter == null
                        ? 'Tất cả phòng'
                        : (state.rooms
                                  .where((r) => r.id == state.roomIdFilter)
                                  .firstOrNull
                                  ?.name ??
                              'Phòng'),
                    isActive: state.roomIdFilter != null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownFilterButton({
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.label13(
              color: isActive ? AppColors.primary : Colors.black,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16.sp,
            color: isActive ? AppColors.primary : Colors.black,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<T> _buildPopupItem<T>({
    required T value,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<T>(
      value: value,
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium(color: Colors.black87).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 24.w,
            child: isSelected
                ? Icon(Icons.check, color: AppColors.primary, size: 22.w)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
