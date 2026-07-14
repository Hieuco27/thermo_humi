import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_management/device_management_cubit.dart';

class DeviceSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const DeviceSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeviceManagementCubit>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SizedBox(
        height: 40.h,
        child: TextField(
          controller: controller,
          onChanged: cubit.onSearchChanged,
          style: AppTextStyles.bodyMedium(),
          decoration: InputDecoration(
            hintText: 'Tìm theo tên thiết bị',
            hintStyle: AppTextStyles.bodyMedium(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
