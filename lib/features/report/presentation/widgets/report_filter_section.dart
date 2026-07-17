import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_cubit.dart';
import 'package:thermo_humi/features/report/presentation/bloc/report/device_report_state.dart';
import 'package:thermo_humi/features/report/presentation/widgets/report_date_picker.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

/// Toàn bộ phần bộ lọc bên trên: dropdown Phòng, Thiết bị, chọn ngày và nút Xem báo cáo.
class ReportFilterSection extends StatelessWidget {
  final DeviceReportState state;

  const ReportFilterSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.white,
      child: Column(
        children: [
          // Room & Device Dropdown
          Row(
            children: [
              Expanded(
                child: _buildDropdown<RoomEntity>(
                  value: state.selectedRoom,
                  items: state.rooms,
                  hint: 'Chọn phòng',
                  getLabel: (room) => 'Phòng ${room.name}',
                  onChanged: (room) {
                    if (room != null) {
                      context.read<DeviceReportCubit>().selectRoom(room);
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdown<DeviceEntity>(
                  value: state.selectedDevice,
                  items: state.devices,
                  hint: 'Chọn thiết bị',
                  getLabel: (device) => device.name,
                  onChanged: (device) {
                    if (device != null) {
                      context.read<DeviceReportCubit>().selectDevice(device);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Date Picker (Tháng/Năm bên trái, cuộn ngang ngày bên phải)
          ReportDatePicker(
            selectedDate: state.selectedDate,
            onDateSelected: (date) {
              context.read<DeviceReportCubit>().selectDate(date);
            },
          ),
          SizedBox(height: 16.h),

          // Nút Xem báo cáo
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () => context.read<DeviceReportCubit>().fetchReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.bar_chart, size: 20.sp),
              label: Text(
                'Xem báo cáo',
                style: AppTextStyles.label13(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generic dropdown builder dùng cho cả Room và Device.
  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          elevation: 0,
          hint: Text(
            hint,
            style: AppTextStyles.body13().copyWith(color: Colors.grey),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 20,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                getLabel(item),
                style: AppTextStyles.titleSmall2(
                  color: AppColors.backgroundColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
