import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Đăng ký',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge().copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 24.h), // Thêm khoảng cách giữa tiêu đề và form
      ],
    );
  }
}
