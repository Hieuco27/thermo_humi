import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:thermo_humi/features/profile/presentation/widgets/profile_menu_list.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
          title: Text(
            'Tài khoản',
            style: AppTextStyles.titleMediumAppBar().copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const ProfileAvatarSection(),
                    SizedBox(height: 20.h),
                    const ProfileMenuList(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: const ProfileLogoutButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
