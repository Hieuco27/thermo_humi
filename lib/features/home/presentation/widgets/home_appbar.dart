import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/home/qr.svg',
          colorFilter: const ColorFilter.mode(
            AppColors.background,
            BlendMode.srcIn,
          ),
          width: 24.w,
          height: 24.w,
        ),
        onPressed: () {},
      ),
      title: Text(
        'Trang chủ',
        style: AppTextStyles.titleMediumAppBar(color: AppColors.background),
      ),
      actions: [
        IconButton(
          icon: Badge(
            label: const Text('3'),
            child: SvgPicture.asset(
              'assets/icons/appbar/request.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.background,
                BlendMode.srcIn,
              ),
              width: 24.w,
              height: 24.w,
            ),
          ),
          onPressed: () {
            context.pushNamed('request-access-list');
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
