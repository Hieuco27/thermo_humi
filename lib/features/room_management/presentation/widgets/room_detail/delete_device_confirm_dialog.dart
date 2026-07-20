import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeleteDeviceConfirmDialog extends StatelessWidget {
  final String deviceName;
  final VoidCallback onConfirm;

  const DeleteDeviceConfirmDialog({
    super.key,
    required this.deviceName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade600,
            size: 22.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Xoá $deviceName?',
            style: AppTextStyles.titleMedium(color: Colors.black87),
          ),
        ],
      ),
      content: Text(
        'Thiết bị "$deviceName" sẽ bị XOÁ VĨNH VIỄN khỏi hệ thống.\n'
        'Toàn bộ dữ liệu lịch sử của thiết bị này sẽ KHÔNG thể khôi phục lại.\n'
        'Bạn có chắc chắn muốn tiếp tục?',
        style: AppTextStyles.label13(color: Colors.black54),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Huỷ',
            style: AppTextStyles.labelLarge2(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop();
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(
            'Xoá',
            style: AppTextStyles.labelLarge2(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
