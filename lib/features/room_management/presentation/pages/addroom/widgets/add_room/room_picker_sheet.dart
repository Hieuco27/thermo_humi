/// RoomPickerSheet — bottom sheet chọn phòng cho mode flexible.
/// Widget độc lập, có thể tái sử dụng ở màn khác.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class RoomPickerSheet extends StatelessWidget {
  final List<RoomEntity> rooms;
  final bool isLoading;

  /// ID phòng đang được chọn (null = "Chưa gán phòng")
  final String? selectedRoomId;

  /// Callback khi người dùng chọn 1 dòng.
  /// Truyền (null, null) khi chọn "Chưa gán phòng".
  final void Function(String? roomId, String? roomName) onSelected;

  const RoomPickerSheet({
    super.key,
    required this.rooms,
    required this.isLoading,
    required this.selectedRoomId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            // ── Tiêu đề ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn phòng',
                  style: AppTextStyles.labelLarge(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // ── Dòng "Chưa gán phòng" ──
            _buildUnassignedTile(context),

            Divider(color: Colors.grey.shade200, height: 1),

            // ── Danh sách phòng hoặc loading ──
            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (rooms.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Chưa có phòng nào. Hãy tạo phòng trong Quản lý phòng.',
                  style: AppTextStyles.bodySmall(color: Colors.grey.shade400),
                  textAlign: TextAlign.center,
                ),
              )
            else
              // Giới hạn chiều cao sheet để không che hết màn hình
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rooms.length,
                  itemBuilder: (_, index) =>
                      _buildRoomTile(context, rooms[index]),
                ),
              ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUnassignedTile(BuildContext context) {
    final isSelected = selectedRoomId == null;
    return ListTile(
      leading: Icon(Icons.cancel, color: Colors.grey.shade400, size: 22.sp),
      title: Text(
        'Chưa gán phòng',
        style: AppTextStyles.label13(
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      subtitle: Text(
        'Thiết bị sẽ hoạt động độc lập',
        style: AppTextStyles.bodySmall(color: Colors.grey.shade400),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary, size: 20.sp)
          : null,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
      onTap: () {
        Navigator.pop(context);
        onSelected(null, null);
      },
    );
  }

  Widget _buildRoomTile(BuildContext context, RoomEntity room) {
    final isSelected = room.id == selectedRoomId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Image.asset(
            "assets/icons/room/room.png",
            width: 22.sp,
            height: 22.sp,
          ),
          title: Text(
            room.name,
            style: AppTextStyles.label13(
              color: isSelected ? AppColors.primary : Colors.black,
            ),
          ),
          subtitle: Text(
            '${room.totalDevices} thiết bị',
            style: AppTextStyles.bodySmall(color: Colors.grey),
          ),

          trailing: isSelected
              ? Icon(Icons.check_rounded, color: AppColors.primary, size: 20.sp)
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          onTap: () {
            Navigator.pop(context);
            onSelected(room.id, room.name);
          },
        ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}
