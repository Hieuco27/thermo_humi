import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class EmptySearchState extends StatelessWidget {
  final String query;
  const EmptySearchState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              'Không tìm thấy phòng "$query"',
              style: AppTextStyles.bodyMedium(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
