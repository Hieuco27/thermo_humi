import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class SummaryStrip extends StatelessWidget {
  final int totalDevices;
  final int onlineCount;

  const SummaryStrip({super.key, required this.totalDevices, required this.onlineCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$totalDevices thiết bị · $onlineCount online',
          style: AppTextStyles.bodyMedium(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
