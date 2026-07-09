import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _ProfileMenuItem(
              iconPath: 'assets/icons/profile/thongTin.svg',
              label: 'Thông tin tài khoản',
              isFirst: true,
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _ProfileMenuItem(
              iconPath: 'assets/icons/profile/lichSu.svg',
              label: 'Lịch sử hoạt động',
              onTap: () {
                context.goNamed('threshold-history');
              },
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _ProfileMenuItem(
              iconPath: 'assets/icons/profile/thanhVien.svg',
              label: 'Thành viên',
              badgeCount: '5',
              onTap: () {
                context.goNamed('member-management');
              },
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _ProfileMenuItem(
              iconPath: 'assets/icons/profile/room.svg',
              label: 'Quản lý phòng',
              badgeCount: '4',
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _ProfileMenuItem(
              iconPath: 'assets/icons/profile/device.svg',
              label: 'Quản lý thiết bị',
              badgeCount: '12',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final String? badgeCount;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.iconPath,
    required this.label,
    this.badgeCount,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16.r) : Radius.zero,
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
        onTap: onTap ?? () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 38.w,
                height: 38.w,
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 22.w,
                    height: 22.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF424242),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(child: Text(label, style: AppTextStyles.labelLarge())),
              if (badgeCount != null)
                Text(
                  badgeCount!,
                  style: AppTextStyles.labelLarge().copyWith(
                    color: Colors.grey,
                  ),
                ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.w),
            ],
          ),
        ),
      ),
    );
  }
}
