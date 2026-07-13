import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_cubit.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_state.dart';
import 'package:thermo_humi/features/room_management/presentation/models/room_detail_result.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/add_device_option_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/delete_device_confirm_dialog.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/device_action_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/room_device_tile.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/unassigned_devices_sheet.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoomManageCubit()..loadRoomData(roomId),
      child: const _RoomDetailView(),
    );
  }
}

class _RoomDetailView extends StatelessWidget {
  const _RoomDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomManageCubit, RoomManageState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == RoomManageStatus.deleted) {
          final result = RoomDetailResult(
            isDeleted: true,
            newDeviceCount: 0,
            newOnlineCount: 0,
            newName: '',
          );
          context.pop(result);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          context.read<RoomManageCubit>().clearError();
        }
      },
      builder: (context, state) {
        if (state.status == RoomManageStatus.initial ||
            (state.status == RoomManageStatus.loading &&
                state.roomWithDevices == null)) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = state.roomWithDevices!.room;
        final devices = state.roomWithDevices!.devices;
        final onlineCount = devices.where((d) => d.isOnline).length;
        final deviceCount = devices.length;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (state.hasChanges) {
              final result = RoomDetailResult(
                isDeleted: false,
                newDeviceCount: deviceCount,
                newOnlineCount: onlineCount,
                newName: room.name,
              );
              context.pop(result);
            } else {
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _DetailAppBar(
              roomName: room.name,
              deviceCount: deviceCount,
              isAdmin: state.isAdmin,
              onRename: () => _showRenameDialog(context, room.name),
              onDelete: () => _showDeleteRoomDialog(context, deviceCount == 0),
            ),
            body: Column(
              children: [
                _SummaryStrip(
                  totalDevices: deviceCount,
                  onlineCount: onlineCount,
                ),
                Expanded(
                  child: deviceCount == 0
                      ? _EmptyDeviceState()
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                          itemCount: deviceCount,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return RoomDeviceTile(
                              key: ValueKey(device.id),
                              device: device,
                              onMoreTap: () => _showDeviceActionSheet(
                                context,
                                device,
                                state.isAdmin,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            bottomNavigationBar: _AddDeviceButton(
              onTap: () => _showAddDeviceOptionSheet(context, room.name),
            ),
          ),
        );
      },
    );
  }

  void _showDeviceActionSheet(
    BuildContext context,
    DeviceEntity device,
    bool isAdmin,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceActionSheet(
        deviceName: device.name,
        isAdmin: isAdmin,
        onUnassign: () =>
            context.read<RoomManageCubit>().unassignDevice(device.id),
        onDeleteFromSystem: () => _confirmDeleteFromSystem(context, device),
      ),
    );
  }

  void _confirmDeleteFromSystem(BuildContext context, DeviceEntity device) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteDeviceConfirmDialog(
        deviceName: device.name,
        onConfirm: () =>
            context.read<RoomManageCubit>().deleteDeviceCompletely(device.id),
      ),
    );
  }

  void _showAddDeviceOptionSheet(BuildContext context, String roomName) {
    final roomId = context
        .read<RoomManageCubit>()
        .state
        .roomWithDevices
        ?.room
        .id;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDeviceOptionSheet(
        roomName: roomName,
        onAddNew: () {
          Navigator.pop(context); // Đóng sheet trước
          if (roomId != null) {
            // Navigate tới AddRoomScreen chế độ "chỉ thêm thiết bị"
            context.pushNamed(
              'add-room',
              queryParameters: {'existingRoomId': roomId},
            );
          }
        },
        onSelectUnassigned: () =>
            _showUnassignedDevicesSheet(context, roomName),
      ),
    );
  }

  void _showUnassignedDevicesSheet(
    BuildContext context,
    String roomName,
  ) async {
    final cubit = context.read<RoomManageCubit>();
    final unassigned = await cubit.getUnassignedDevices();

    if (!context.mounted) return;

    final result = await showModalBottomSheet<List<DeviceEntity>>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          UnassignedDevicesSheet(devices: unassigned, roomName: roomName),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await cubit.assignExistingDevices(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gán ${result.length} thiết bị vào phòng $roomName',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  void _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên phòng'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên phòng mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.pop();
                context.read<RoomManageCubit>().renameRoom(newName);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoomDialog(BuildContext context, bool canDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá phòng'),
        content: canDelete
            ? const Text('Phòng này sẽ bị xoá vĩnh viễn. Bạn có chắc không?')
            : const Text(
                'Không thể xoá phòng vì hiện vẫn còn thiết bị bên trong.\n\n'
                'Vui lòng chuyển hết thiết bị ra khỏi phòng trước.',
              ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Đóng')),
          if (canDelete)
            TextButton(
              onPressed: () {
                context.pop();
                context.read<RoomManageCubit>().deleteRoom();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
              child: const Text('Xoá phòng'),
            ),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  final int deviceCount;
  final bool isAdmin;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _DetailAppBar({
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
            final result = RoomDetailResult(
              isDeleted: false,
              newDeviceCount: deviceCount,
              newOnlineCount:
                  state.roomWithDevices?.devices
                      .where((d) => d.isOnline)
                      .length ??
                  0,
              newName: roomName,
            );
            context.pop(result);
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
              Icons.more_horiz_rounded,
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
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
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
                      size: 18,
                      color: canDelete
                          ? Colors.red.shade600
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 10),
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

class _SummaryStrip extends StatelessWidget {
  final int totalDevices;
  final int onlineCount;

  const _SummaryStrip({required this.totalDevices, required this.onlineCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$totalDevices thiết bị · $onlineCount online',
          style: AppTextStyles.bodyMedium(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _EmptyDeviceState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.device_hub_rounded,
            size: 60.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Phòng này chưa có thiết bị nào',
            style: AppTextStyles.titleMedium(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _AddDeviceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddDeviceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SafeArea(
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.add_rounded, color: Colors.black87, size: 20.sp),
          label: Text(
            'Thêm thiết bị vào phòng này',
            style: AppTextStyles.titleMedium(color: Colors.black87),
          ),
          style: TextButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: const BorderSide(
                color: Color(0xFFF39C12),
              ), // Màu cam như design
            ),
          ),
        ),
      ),
    );
  }
}
