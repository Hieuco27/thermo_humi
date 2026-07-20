import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class RoomNameInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const RoomNameInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.label13(),
      decoration: InputDecoration(
        hintText: 'Tên phòng',
        isDense: true,
        constraints: BoxConstraints(minHeight: 44.h, maxHeight: 44.h),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 20.w),
        hintStyle: AppTextStyles.label13(color: Colors.grey.shade400),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Image.asset(
            "assets/icons/room/room.png",
            width: 20.sp,
            height: 20.sp,
            color: Colors.black87,
          ),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 14.sp,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}
