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
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/shared/mock/mock_room_data.dart';

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
    if (_rooms.isNotEmpty) _expandedRooms.add(_rooms.first.room.id);
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
    const bool isDark = false; // Bỏ dark mode ở trang này
    const Color bg = Color(0xFFF2F2F7);
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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(appBarBg, textPrimary),
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
                isDark: isDark,
              ),

              // ── Room list ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF007AFF),
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
                          isDark: isDark,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add room page
            HapticFeedback.lightImpact();
          },
          backgroundColor: const Color(0xFF007AFF),
          elevation: 4,
          child: Icon(Icons.add, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color bg, Color textPrimary) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,

      title: Text(
        'Phòng & Thiết bị',
        textAlign: TextAlign.center,
        style: AppTextStyles.titleMediumAppBar(color: textPrimary),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: textPrimary, size: 22.sp),
          onPressed: () {},
          tooltip: 'Tìm kiếm',
        ),
        SizedBox(width: 4.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(height: 1, color: const Color(0xFFE5E5EA)),
      ),
    );
  }
}
