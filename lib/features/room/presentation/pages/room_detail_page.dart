/// — Trang danh sách thiết bị trong phòng
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/common/widgets/animated_list_item.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_detail/room_detail_cubit.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_detail/room_detail_state.dart';
import 'package:thermo_humi/features/room/presentation/widgets/device_list_item.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_summary_strip.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';
import 'package:thermo_humi/features/sharing/presentation/pages/share_page.dart';
import 'package:thermo_humi/features/room/presentation/widgets/device_empty_state.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/room_detail_app_bar.dart';

class RoomDetailPage extends StatelessWidget {
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomDetailCubit>()..loadRoomData(roomId),
      child: _RoomDeviceListView(roomId: roomId),
    );
  }
}

class _RoomDeviceListView extends StatefulWidget {
  final String roomId;

  const _RoomDeviceListView({required this.roomId});

  @override
  State<_RoomDeviceListView> createState() => _RoomDeviceListViewState();
}

class _RoomDeviceListViewState extends State<_RoomDeviceListView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<DeviceEntity> _getFilteredDevices(
    List<DeviceEntity> allDevices,
    DeviceFilterType filter,
  ) {
    switch (filter) {
      case DeviceFilterType.online:
        return allDevices.where((d) => d.isOnline).toList();
      case DeviceFilterType.offline:
        return allDevices.where((d) => !d.isOnline).toList();
      case DeviceFilterType.alert:
        return allDevices.where((d) => d.hasAlert).toList();
      case DeviceFilterType.all:
        return allDevices;
    }
  }

  // Future<void> _onRefresh(BuildContext context) async {
  //   HapticFeedback.lightImpact();
  //   context.read<RoomDetailCubit>().refreshRoomData(widget.roomId);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Đã cập nhật dữ liệu',
  //           style: GoogleFonts.inter(fontSize: 13.sp),
  //         ),
  //         backgroundColor: const Color(0xFF1C1C1E),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.r),
  //         ),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomDetailCubit, RoomDetailState>(
      builder: (context, state) {
        if (state.status == RoomDetailStatus.initial ||
            state.status == RoomDetailStatus.loading &&
                state.roomWithDevices == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = state.roomWithDevices!.room;
        final allDevices = state.roomWithDevices!.devices;
        final filteredDevices = _getFilteredDevices(
          allDevices,
          state.activeFilter,
        );
        final onlineCount = allDevices.where((d) => d.isOnline).length;
        final alertCount = allDevices.where((d) => d.hasAlert).length;

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: RoomDetailAppBar(
              roomName: room.name,
              backgroundColor: AppColors.gradientEnd,
              textColor: Colors.white,
              onSearch: () {},
              onMoreOptions: () {},
            ),
            body: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── Summary strip ──
                  DeviceSummaryStrip(
                    totalDevices: allDevices.length,
                    onlineCount: onlineCount,
                    alertCount: alertCount,
                  ),

                  // ── Filter chips ──
                  DeviceFilterBar(
                    activeFilter: state.activeFilter,
                    totalCount: allDevices.length,
                    onlineCount: onlineCount,
                    offlineCount: allDevices.length - onlineCount,
                    alertCount: alertCount,
                    isSelectionMode: state.isSelectionMode,
                    onFilterChanged: (f) =>
                        context.read<RoomDetailCubit>().changeFilter(f),
                    onSelectModeToggle: () =>
                        context.read<RoomDetailCubit>().toggleSelectionMode(),
                    onCancelSelection: () =>
                        context.read<RoomDetailCubit>().toggleSelectionMode(),
                    onShareTap: () {
                      final selectedDeviceIds = state.selectedDeviceIds
                          .toList();
                      if (selectedDeviceIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vui lòng chọn ít nhất 1 thiết bị để chia sẻ',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SharePage(
                            initialDeviceIds: selectedDeviceIds,
                            roomId: room.id,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Device list ──
                  Expanded(
                    child: filteredDevices.isEmpty
                        ? DeviceEmptyState(filter: state.activeFilter)
                        : ListView.builder(
                            padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
                            itemCount: filteredDevices.length,
                            itemBuilder: (context, index) {
                              final device = filteredDevices[index];
                              return AnimatedListItem(
                                index: index,
                                child: DeviceListItem(
                                  device: device,
                                  isSelectionMode: state.isSelectionMode,
                                  isSelected: state.selectedDeviceIds.contains(
                                    device.id,
                                  ),
                                  onToggleSelect: (id) {
                                    context
                                        .read<RoomDetailCubit>()
                                        .toggleDeviceSelection(id);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
