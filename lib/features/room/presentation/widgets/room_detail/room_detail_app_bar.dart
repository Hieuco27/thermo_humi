import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class RoomDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoomDetailAppBar({
    super.key,
    required this.roomName,
    required this.backgroundColor,
    required this.textColor,
    required this.onSearch,
    required this.onMoreOptions,
  });

  final String roomName;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onSearch;
  final VoidCallback onMoreOptions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 22.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        roomName,
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
      actions: [
        // Search button
        IconButton(
          icon: Icon(Icons.search_rounded, color: textColor, size: 22.sp),
          onPressed: onSearch,
        ),
        // More options
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: textColor, size: 22.sp),
          onPressed: onMoreOptions,
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
