import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

class PendingMemberActionSheet extends StatelessWidget {
  final Member member;
  final VoidCallback onResend;
  final VoidCallback onRevoke;

  const PendingMemberActionSheet({
    super.key,
    required this.member,
    required this.onResend,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.initials,
                        style: AppTextStyles.bodyLarge().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: AppTextStyles.bodyLarge().copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Đang chờ chấp nhận lời mời',
                          style: AppTextStyles.labelMedium(
                            color: Colors.orange[800]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onResend();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    icon: const Icon(Icons.send_outlined),
                    label: Text(
                      'Gửi lại lời mời',
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRevoke();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(
                      'Thu hồi lời mời',
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
