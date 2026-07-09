import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

class MemberListTile extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;

  const MemberListTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isPending = member.isPending;
    final bool isCurrentUser = member.isCurrentUser;
    final double opacity = isPending ? 0.5 : 1.0;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: isCurrentUser ? null : onTap,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Avatar
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
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: AppTextStyles.bodyMedium().copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser)
                            Padding(
                              padding: EdgeInsets.only(left: 6.w),
                              child: Text(
                                '(Bạn)',
                                style: AppTextStyles.labelMedium(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isPending ? 'Đang chờ chấp nhận' : member.email,
                        style: AppTextStyles.labelMedium(
                          color: Colors.grey[600]!,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Role & Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.role.displayName,
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (!isCurrentUser)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.w,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
