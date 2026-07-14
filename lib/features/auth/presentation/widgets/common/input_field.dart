import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: AppTextStyles.labelLarge(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.labelLarge().copyWith(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF1A8FD1), width: 1.5),
        ),
      ),
    );
  }
}
