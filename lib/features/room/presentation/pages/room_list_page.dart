/// RoomListPage — Trang danh sách phòng với thiết bị (Tab Areas)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_detail_page.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/animated_item.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/global_summary_bar.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/room_card.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_list/room_list_app_bar.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Phòng nào đang mở rộng
  final Set<String> _expandedRooms = {};

  // Mock data — thay bằng BLoC khi có API
  late final List<RoomWithDevices> _rooms;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _rooms = buildMockRooms();
    // Mặc định mở phòng đầu tiên
    //if (_rooms.isNotEmpty) _expandedRooms.add(_rooms.first.room.id);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật dữ liệu',
            style: AppTextStyles.bodyMedium(),
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
    const Color appBarBg = Colors.transparent;
    const Color textPrimary = Color(0xFF1C1C1E);

    final int totalDevices = _rooms.fold(
      0,
      (sum, r) => sum + r.room.totalDevices,
    );
    final int totalOnline = _rooms.fold(
      0,
      (sum, r) => sum + r.room.onlineDevices,
    );
    final int totalAlerts = _rooms.fold(0, (sum, r) => sum + r.room.alertCount);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: RoomListAppBar(
          backgroundColor: appBarBg,
          textColor: textPrimary,
          onSearch: () {
            // TODO: Search action
          },
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Global summary bar ──
              GlobalSummaryBar(
                totalRooms: _rooms.length,
                totalDevices: totalDevices,
                totalOnline: totalOnline,
                totalAlerts: totalAlerts,
              ),

              // ── Room list ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final rwd = _rooms[index];
                      final isExpanded = _expandedRooms.contains(rwd.room.id);
                      return AnimatedItem(
                        index: index,
                        child: RoomCard(
                          rwd: rwd,
                          isExpanded: isExpanded,
                          onHeaderTap: () => _toggleRoom(rwd.room.id),
                          onViewAll: () => _navigateToRoomDetail(rwd),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
