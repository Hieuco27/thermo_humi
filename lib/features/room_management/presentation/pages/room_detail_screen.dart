import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_cubit.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_state.dart';
import 'package:thermo_humi/features/room_management/presentation/models/room_detail_result.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/add_device_option_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/delete_device_confirm_dialog.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/device_action_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/room_device_tile.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/unassigned_devices_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/room_detail_app_bar.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/summary_strip.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/empty_device_state.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/add_device_button.dart';

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
            appBar: RoomDetailAppBar(
              roomName: room.name,
              deviceCount: deviceCount,
              isAdmin: state.isAdmin,
              onRename: () => _showRenameDialog(context, room.name),
              onDelete: () => _showDeleteRoomDialog(context, deviceCount == 0),
            ),
            body: Column(
              children: [
                SummaryStrip(
                  totalDevices: deviceCount,
                  onlineCount: onlineCount,
                ),
                Expanded(
                  child: deviceCount == 0
                      ? const EmptyDeviceState()
                      : ListView.separated(
                          padding: EdgeInsets.all(8.w),
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
            bottomNavigationBar: AddDeviceButton(
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
