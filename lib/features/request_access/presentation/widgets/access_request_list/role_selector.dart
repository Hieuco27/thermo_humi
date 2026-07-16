import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

class RoleSelector extends StatelessWidget {
  final AccessRole selectedRole;
  final ValueChanged<AccessRole>? onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quyền hạn sẽ cấp',
          style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Row(
          children: AccessRole.values.map((role) {
            final isSelected = role == selectedRole;
            return Expanded(
              child: GestureDetector(
                onTap: onChanged == null ? null : () => onChanged!(role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      role.displayName,
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
