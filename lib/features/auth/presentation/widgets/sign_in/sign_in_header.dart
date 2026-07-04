import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Đăng nhập',
          style: AppTextStyles.headlineLarge().copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
