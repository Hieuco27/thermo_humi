/// ImeiInputField — ô nhập IMEI thủ công (UI only)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ImeiInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const ImeiInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      style: AppTextStyles.bodyMedium(color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Nhập mã IMEI thiết bị',
        hintStyle: AppTextStyles.bodyMedium(color: Colors.grey.shade400),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SvgPicture.asset(
            'assets/icons/other/imei.svg',
            width: 20.sp,
            height: 20.sp,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade400,
              BlendMode.srcIn,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 44.w),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  size: 18.sp,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        errorText: errorText,
        errorStyle: AppTextStyles.bodySmall(color: Colors.red.shade500),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
