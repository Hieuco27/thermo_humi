/// RoomSelectorField — ô chọn phòng read-only cho mode flexible.
/// Dùng GestureDetector + Container thay vì TextField để tránh bàn phím / con trỏ nhấp nháy.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class RoomSelectorField extends StatelessWidget {
  /// null = hiện "Chưa gán phòng" (màu xám, giá trị mặc định)
  final String? selectedRoomName;
  final VoidCallback onTap;

  const RoomSelectorField({
    super.key,
    required this.selectedRoomName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnassigned = selectedRoomName == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 44.h, maxHeight: 44.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            // Icon phòng bên trái
            Icon(
              Icons.meeting_room_outlined,
              color: isUnassigned ? Colors.grey : AppColors.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            // Text phòng đã chọn hoặc placeholder
            Expanded(
              child: Text(
                isUnassigned ? 'Chưa gán phòng' : selectedRoomName!,
                style: isUnassigned
                    ? AppTextStyles.label13(color: Colors.grey)
                    : AppTextStyles.label13(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            // Icon mũi tên xuống bên phải
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
