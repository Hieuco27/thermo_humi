import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class EmptyDeviceState extends StatelessWidget {
  const EmptyDeviceState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.device_hub_rounded,
            size: 60.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Phòng này chưa có thiết bị nào',
            style: AppTextStyles.titleMedium(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
