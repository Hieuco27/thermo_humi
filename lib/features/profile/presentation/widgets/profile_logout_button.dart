import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/router/route_names.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Xác nhận đăng xuất',
                    style: AppTextStyles.titleMedium(color: Colors.black),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.labelLarge(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(RouteNames.login);
                      },
                      child: Text(
                        'Đăng xuất',
                        style: AppTextStyles.labelLarge(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 20.w),
                  SizedBox(width: 10.w),
                  Text(
                    'Đăng xuất',
                    style: AppTextStyles.labelLarge().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
