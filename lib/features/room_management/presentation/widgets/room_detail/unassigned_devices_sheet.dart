import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

/// Bottom sheet / full page cho phép chọn thiết bị chưa gán phòng,
/// rồi gán hàng loạt vào phòng hiện tại.
class UnassignedDevicesSheet extends StatefulWidget {
  final List<DeviceEntity> devices;
  final String roomName;

  const UnassignedDevicesSheet({
    super.key,
    required this.devices,
    required this.roomName,
  });

  @override
  State<UnassignedDevicesSheet> createState() => _UnassignedDevicesSheetState();
}

class _UnassignedDevicesSheetState extends State<UnassignedDevicesSheet> {
  final Set<String> _selected = {};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              SizedBox(height: 12.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn thiết bị để gán',
                            style: AppTextStyles.titleMedium(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Gán vào: ${widget.roomName}',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selected.isNotEmpty)
                      Text(
                        '${_selected.length} đã chọn',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Divider(height: 1, color: Colors.grey.shade200),

              // Device list
              Expanded(
                child: widget.devices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.devices_other_rounded,
                                size: 48.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không có thiết bị nào chưa được gán phòng',
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        itemCount: widget.devices.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (_, index) {
                          final device = widget.devices[index];
                          final isSelected = _selected.contains(device.id);
                          return _UnassignedDeviceTile(
                            device: device,
                            isSelected: isSelected,
                            onToggle: () => _toggle(device.id),
                          );
                        },
                      ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () {
                              final selected = widget.devices
                                  .where((d) => _selected.contains(d.id))
                                  .toList();
                              Navigator.pop(context, selected);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade200,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _selected.isEmpty
                            ? 'Gán vào phòng'
                            : 'Gán ${_selected.length} thiết bị vào phòng',
                        style: AppTextStyles.titleMedium(
                          color: _selected.isEmpty
                              ? Colors.grey.shade500
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnassignedDeviceTile extends StatelessWidget {
  final DeviceEntity device;
  final bool isSelected;
  final VoidCallback onToggle;

  const _UnassignedDeviceTile({
    required this.device,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == DeviceStatus.online;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey, width: 0.2),
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? const Color(0xFF34C759)
                    : Colors.grey.shade400,
              ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: AppTextStyles.titleMedium(color: Colors.black),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    device.serialNumber ?? '-',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
