import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          // Room Dropdown
          _buildDropdown<RoomEntity>(
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
          SizedBox(height: 12.h),

          // Device Dropdown
          _buildDropdown<DeviceEntity>(
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
          SizedBox(height: 12.h),

          // Date Picker: Tháng / Năm / Ngày
          Row(
            children: [
              Expanded(
                child: ReportDatePicker(
                  label: 'Tháng ${state.selectedDate.month}',
                  selectedDate: state.selectedDate,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ReportDatePicker(
                  label: '${state.selectedDate.year}',
                  selectedDate: state.selectedDate,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ReportDatePicker(
                  label:
                      'Ngày ${state.selectedDate.day.toString().padLeft(2, '0')}',
                  selectedDate: state.selectedDate,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Nút Xem báo cáo
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<DeviceReportCubit>().fetchReport(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.bar_chart, size: 20),
              label: Text(
                'Xem báo cáo',
                style: AppTextStyles.labelLarge(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: AppTextStyles.bodyMedium(color: Colors.grey)),
          icon:
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                getLabel(item),
                style: AppTextStyles.bodyMedium(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
