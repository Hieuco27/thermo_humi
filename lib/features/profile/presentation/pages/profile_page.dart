import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _buildAvatarSection(),
              SizedBox(height: 32.h),
              _buildMenuList(),
              SizedBox(height: 20.h),
              _buildLogoutButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              decoration: const BoxDecoration(
                color: Color(0xFFD3E3F8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'HN',
                  style: TextStyle(
                    color: const Color(0xFF1565C0),
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14.w,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text('Thái Hiếu', style: AppTextStyles.bodyLarge()),
        SizedBox(height: 2.h),
        Text(
          '+84 912 345 678',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD3E3F8), // bg-accent
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Admin · HMS Technology',
            style: TextStyle(
              color: const Color(0xFF1565C0), // text-accent
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.person_outline,
              label: 'Thông tin tài khoản',
              isFirst: true,
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(icon: Icons.history, label: 'Lịch sử hoạt động'),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(
              icon: Icons.people_outline,
              label: 'Quản lý thành viên',
              badgeCount: '5',
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(
              icon: Icons.meeting_room_outlined,
              label: 'Quản lý phòng',
              badgeCount: '4',
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(
              icon: Icons.devices_outlined,
              label: 'Quản lý thiết bị',
              badgeCount: '12',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badgeCount,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16.r) : Radius.zero,
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: const Color(0xFF424242), size: 18.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (badgeCount != null)
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Text(
                    badgeCount,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.black87, size: 20.w),
                  SizedBox(width: 10.w),
                  Text('Đăng xuất', style: AppTextStyles.bodyLarge()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
