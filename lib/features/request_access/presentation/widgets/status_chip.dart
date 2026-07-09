import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

class StatusChip extends StatelessWidget {
  final AccessRequestStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AccessRequestStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = 'Chờ xác nhận';
        break;
      case AccessRequestStatus.accepted:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Đã chấp nhận';
        break;
      case AccessRequestStatus.declined:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = 'Đã từ chối';
        break;
      case AccessRequestStatus.expired:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        text = 'Đã hết hạn';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium(color: textColor).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
