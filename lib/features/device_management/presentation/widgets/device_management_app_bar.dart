import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DeviceManagementAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DeviceManagementAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Quản lý thiết bị',
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22.sp),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
          onPressed: () {
            context.pushNamed(
              'add-room',
              queryParameters: {'flexible': 'true'},
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
