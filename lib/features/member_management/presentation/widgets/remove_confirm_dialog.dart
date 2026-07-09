import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

class RemoveConfirmDialog extends StatelessWidget {
  final Member member;

  const RemoveConfirmDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Xoá ${member.name} khỏi hệ thống?',
        style: AppTextStyles.titleSmall2(),
      ),
      content: Text(
        'Người này sẽ mất quyền truy cập vào tổ chức ngay lập tức. Hành động này không thể hoàn tác.',
        style: AppTextStyles.bodyMedium().copyWith(color: Colors.grey[700]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Huỷ', style: AppTextStyles.bodyMedium()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text('Xoá', style: AppTextStyles.bodyMedium().copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
