import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class RoomMgmtAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddRoom;
  const RoomMgmtAppBar({super.key, required this.onAddRoom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Quản lý phòng',
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: onAddRoom,
          icon: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
          tooltip: 'Thêm phòng mới',
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
