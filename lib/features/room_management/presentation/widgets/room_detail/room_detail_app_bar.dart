import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_cubit.dart';

class RoomDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  final int deviceCount;
  final bool isAdmin;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const RoomDetailAppBar({
    super.key,
    required this.roomName,
    required this.deviceCount,
    required this.isAdmin,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete = deviceCount == 0;
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: Colors.white,
        ),
        onPressed: () {
          final state = context.read<RoomManageCubit>().state;
          if (state.hasChanges) {
            context.pop();
          } else {
            context.pop();
          }
        },
      ),
      title: Text(
        roomName,
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
      actions: [
        if (isAdmin)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 22.sp,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              if (value == 'rename') onRename();
              if (value == 'delete' && canDelete) onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 22.sp),
                    SizedBox(width: 10.w),
                    Text('Đổi tên phòng'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                enabled: canDelete,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 22.sp,
                      color: canDelete
                          ? Colors.red.shade600
                          : Colors.grey.shade400,
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xoá phòng',
                          style: TextStyle(
                            color: canDelete
                                ? Colors.red.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        if (!canDelete)
                          Text(
                            'Cần chuyển hết thiết bị ra trước',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(width: 4.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
