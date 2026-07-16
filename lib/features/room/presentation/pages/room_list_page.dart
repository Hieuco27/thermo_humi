/// RoomListPage — Trang danh sách phòng với thiết bị (Tab Areas)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_cubit.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_detail_page.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/animated_item.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/global_summary_bar.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/room_card.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/room_list_app_bar.dart';

class RoomListPage extends StatelessWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomListCubit>()..loadRooms(),
      child: const _RoomListView(),
    );
  }
}

class _RoomListView extends StatefulWidget {
  const _RoomListView();

  @override
  State<_RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<_RoomListView>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Phòng nào đang mở rộng
  final Set<String> _expandedRooms = {};

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _toggleRoom(String roomId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedRooms.contains(roomId)) {
        _expandedRooms.remove(roomId);
      } else {
        _expandedRooms.add(roomId);
      }
    });
  }

  void _navigateToRoomDetail(RoomWithDevices rwd) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomDetailPage(roomId: rwd.room.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarBg = AppColors.gradientEnd;
    const Color textPrimary = AppColors.background;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: RoomListAppBar(
          backgroundColor: appBarBg,
          textColor: textPrimary,
          onSearch: () {},
        ),
        body: BlocConsumer<RoomListCubit, RoomListState>(
          listener: (context, state) {
            // Khi load thành công → chạy animation fade-in
            if (state.isSuccess) {
              _fadeCtrl.forward(from: 0);
            }
          },
          builder: (context, state) {
            // ── Loading ──
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ── Lỗi ──
            if (state.isFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 56.sp,
                        color: AppColors.gradientEnd.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage ?? 'Đã xảy ra lỗi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<RoomListCubit>().refresh(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── Danh sách trống ──
            if (state.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 56.sp,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Chưa có phòng nào',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Thành công — hiển thị danh sách ──
            final rooms = state.rooms;
            final int totalDevices =
                rooms.fold(0, (sum, r) => sum + r.room.totalDevices);
            final int totalOnline =
                rooms.fold(0, (sum, r) => sum + r.room.onlineDevices);
            final int totalAlerts =
                rooms.fold(0, (sum, r) => sum + r.room.alertCount);

            return FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () => context.read<RoomListCubit>().refresh(),
                child: Column(
                  children: [
                    // ── Global summary bar ──
                    GlobalSummaryBar(
                      totalRooms: rooms.length,
                      totalDevices: totalDevices,
                      totalOnline: totalOnline,
                      totalAlerts: totalAlerts,
                    ),

                    // ── Room list ──
                    Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.only(top: 8.h, bottom: 24.h),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final rwd = rooms[index];
                          final isExpanded =
                              _expandedRooms.contains(rwd.room.id);
                          return AnimatedItem(
                            index: index,
                            child: RoomCard(
                              rwd: rwd,
                              isExpanded: isExpanded,
                              onHeaderTap: () =>
                                  _toggleRoom(rwd.room.id),
                              onViewAll: () =>
                                  _navigateToRoomDetail(rwd),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
