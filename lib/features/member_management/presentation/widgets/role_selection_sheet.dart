import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

class RoleSelectionSheet extends StatefulWidget {
  final Member member;
  final bool isLastAdmin;
  final VoidCallback onRemove;

  const RoleSelectionSheet({
    super.key,
    required this.member,
    required this.isLastAdmin,
    required this.onRemove,
  });

  @override
  State<RoleSelectionSheet> createState() => _RoleSelectionSheetState();
}

class _RoleSelectionSheetState extends State<RoleSelectionSheet> {
  late MemberRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastAdmin =
        widget.isLastAdmin && widget.member.role == MemberRole.admin;
    final bool hasChanged = _selectedRole != widget.member.role;

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
            // Handle bar
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
            // Header: Member info
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
                        widget.member.initials,
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
                          widget.member.name,
                          style: AppTextStyles.bodyLarge().copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.member.email,
                          style: AppTextStyles.labelMedium(
                            color: Colors.grey[600]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHỌN VAI TRÒ',
                    style: AppTextStyles.labelMedium(color: Colors.grey[600]!),
                  ),
                  SizedBox(height: 12.h),

                  if (isLastAdmin)
                    Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[800],
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Bạn phải chỉ định một Admin khác trước khi thay đổi vai trò của người này.',
                              style: AppTextStyles.labelMedium(
                                color: Colors.orange[900]!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Role List
                  ...MemberRole.values.map((role) {
                    final bool isSelected = _selectedRole == role;
                    return InkWell(
                      onTap: isLastAdmin
                          ? null
                          : () {
                              setState(() {
                                _selectedRole = role;
                              });
                            },
                      child: Opacity(
                        opacity: isLastAdmin ? 0.5 : 1.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: Text(
                                  role.displayName,
                                  style: AppTextStyles.bodyMedium().copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  role.description,
                                  style: AppTextStyles.labelMedium(
                                    color: Colors.grey[600]!,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  isLastAdmin
                                      ? Icons.lock_outline
                                      : Icons.check,
                                  color: AppColors.gradientEnd,
                                  size: 20.w,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text('Huỷ', style: AppTextStyles.bodyMedium()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasChanged
                          ? () {
                              Navigator.pop(context, _selectedRole);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientEnd,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Lưu thay đổi',
                        style: AppTextStyles.bodyMedium().copyWith(
                          color: hasChanged ? Colors.white : Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: OutlinedButton.icon(
                onPressed: isLastAdmin ? null : widget.onRemove,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: isLastAdmin ? Colors.grey[300]! : Colors.red,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                icon: const Icon(Icons.person_remove_outlined),
                label: Text(
                  'Xoá khỏi hệ thống',
                  style: AppTextStyles.bodyMedium(),
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
