import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class RoomListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onSearch;

  const RoomListAppBar({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'Phòng & Thiết bị',
        textAlign: TextAlign.center,
        style: AppTextStyles.titleMediumAppBar(color: textColor),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: textColor, size: 22.sp),
          onPressed: onSearch ?? () {},
          tooltip: 'Tìm kiếm',
        ),
        SizedBox(width: 4.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: const Divider(height: 1, color: Color(0xFFE5E5EA)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
