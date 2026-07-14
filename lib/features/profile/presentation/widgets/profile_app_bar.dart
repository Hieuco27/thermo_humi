import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
