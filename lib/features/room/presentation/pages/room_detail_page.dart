/// — Trang danh sách thiết bị trong phòng
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/common/widgets/animated_list_item.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/device_list_item.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_summary_strip.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';
import 'package:thermo_humi/features/room/presentation/widgets/device_empty_state.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/room_detail_app_bar.dart';

class RoomDetailPage extends StatefulWidget {
  /// Chỉ cần roomId — page tự lookup data từ mock/repository
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  State<RoomDetailPage> createState() => _RoomDeviceListPageState();
}

class _RoomDeviceListPageState extends State<RoomDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Filter state
  DeviceFilterType _activeFilter = DeviceFilterType.all;

  // Dữ liệu phòng — lookup từ shared mock theo roomId
  late final RoomWithDevices _rwd;
  late List<DeviceEntity> _allDevices;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Lookup phòng theo roomId từ shared mock (sẽ thay bằng BLoC sau)
    final allRooms = buildMockRooms();
    _rwd = allRooms.firstWhere(
      (r) => r.room.id == widget.roomId,
      orElse: () => RoomWithDevices(
        room: RoomEntity(
          id: widget.roomId,
          name: 'Phòng không xác định',
          totalDevices: 0,
          onlineDevices: 0,
          alertCount: 0,
          createdAt: DateTime.now(),
        ),
        devices: [],
      ),
    );
    _allDevices = List.of(_rwd.devices);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<DeviceEntity> get _filteredDevices {
    switch (_activeFilter) {
      case DeviceFilterType.online:
        return _allDevices.where((d) => d.isOnline).toList();
      case DeviceFilterType.offline:
        return _allDevices.where((d) => !d.isOnline).toList();
      case DeviceFilterType.alert:
        return _allDevices.where((d) => d.hasAlert).toList();
      case DeviceFilterType.all:
        return _allDevices;
    }
  }

  int get _onlineCount => _allDevices.where((d) => d.isOnline).length;
  int get _alertCount => _allDevices.where((d) => d.hasAlert).length;

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật dữ liệu',
            style: GoogleFonts.inter(fontSize: 13.sp),
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color.fromARGB(255, 255, 255, 255);
    const Color appBarBg = AppColors.appBarBg;
    const Color textPrimary = AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: RoomDetailAppBar(
        roomName: _rwd.room.name,
        backgroundColor: AppColors.gradientEnd,
        textColor: Colors.white,
        onSearch: _onSearch,
        onMoreOptions: _onMoreOptions,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Summary strip ──
            DeviceSummaryStrip(
              totalDevices: _allDevices.length,
              onlineCount: _onlineCount,
              alertCount: _alertCount,
            ),

            // ── Filter chips ──
            DeviceFilterBar(
              activeFilter: _activeFilter,
              alertCount: _alertCount,
              onFilterChanged: (f) => setState(() => _activeFilter = f),
            ),

            // ── Device list ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF007AFF),
                backgroundColor: Colors.white,
                child: _filteredDevices.isEmpty
                    ? DeviceEmptyState(filter: _activeFilter)
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
                        itemCount: _filteredDevices.length,
                        itemBuilder: (context, index) {
                          return AnimatedListItem(
                            index: index,
                            child: DeviceListItem(
                              device: _filteredDevices[index],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch() {}

  void _onMoreOptions() {}
}
