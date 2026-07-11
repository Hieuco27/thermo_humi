/// RoomManagementScreen — Màn hình quản lý phòng (từ Profile)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room_management/presentation/models/room_detail_result.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_list/room_mgmt_app_bar.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  late List<RoomWithDevices> _allRooms;
  List<RoomWithDevices> _filteredRooms = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allRooms = buildMockRooms();
    _filteredRooms = _allRooms;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredRooms = query.isEmpty
          ? _allRooms
          : _allRooms
                .where((rwd) => rwd.room.name.toLowerCase().contains(query))
                .toList();
    });
  }

  int get _totalDevices =>
      _allRooms.fold(0, (sum, r) => sum + r.room.totalDevices);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RoomMgmtAppBar(onAddRoom: _onAddRoom),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
            child: SizedBox(
              height: 45.h,
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.label13(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: AppTextStyles.bodyMedium(
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 22.sp,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 22.sp,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Summary line
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_allRooms.length} phòng · $_totalDevices thiết bị',
                style: AppTextStyles.bodyMedium(color: Colors.grey.shade500),
              ),
            ),
          ),

          //  Room List
          Expanded(
            child: _filteredRooms.isEmpty
                ? _EmptySearchState(query: _searchCtrl.text)
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    itemCount: _filteredRooms.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final rwd = _filteredRooms[index];
                      return _RoomManagementCard(
                        rwd: rwd,
                        onTap: () => _openRoomDetail(rwd.room),
                      );
                    },
                  ),
          ),

          // Nút thêm phòng mới ghim ở cuối
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                bottom: 24.h,
                top: 8.h,
              ),
              child: _AddRoomButton(onTap: _onAddRoom),
            ),
          ),
        ],
      ),
    );
  }

  void _openRoomDetail(RoomEntity room) async {
    final result = await context.pushNamed<RoomDetailResult>(
      'room-management-detail',
      pathParameters: {'roomId': room.id},
    );

    if (result != null && mounted) {
      setState(() {
        if (result.isDeleted) {
          _allRooms.removeWhere((rwd) => rwd.room.id == room.id);
        } else {
          final index = _allRooms.indexWhere((rwd) => rwd.room.id == room.id);
          if (index != -1) {
            final oldRwd = _allRooms[index];
            final updatedRoom = RoomEntity(
              id: oldRwd.room.id,
              name: result.newName,
              description: oldRwd.room.description,
              totalDevices: result.newDeviceCount,
              onlineDevices: result.newOnlineCount,
              alertCount: oldRwd.room.alertCount,
              createdAt: oldRwd.room.createdAt,
            );
            // Cập nhật lại list gốc
            _allRooms[index] = RoomWithDevices(
              room: updatedRoom,
              devices: oldRwd
                  .devices, // Danh sách mock devices không quá quan trọng ở màn ngoài
            );
          }
        }
        _onSearch();
      });
    }
  }

  void _onAddRoom() {
    // TODO: Navigate tới màn Thêm phòng mới
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Màn hình Thêm phòng mới sẽ mở ở đây')),
    );
  }
}

// ── Room Card
class _RoomManagementCard extends StatelessWidget {
  final RoomWithDevices rwd;
  final VoidCallback onTap;

  const _RoomManagementCard({required this.rwd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final room = rwd.room;
    final hasDevices = room.totalDevices > 0;
    final allOnline = hasDevices && room.onlineDevices == room.totalDevices;
    final hasOffline = hasDevices && room.offlineDevices > 0;

    // Màu chấm trạng thái
    final Color statusColor = !hasDevices
        ? Colors.transparent
        : allOnline
        ? const Color(0xFF34C759)
        : Colors.red.shade400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Room icon
            SizedBox(
              width: 44.w,
              height: 44.w,

              child: Icon(
                Icons.meeting_room_rounded,
                size: 22.sp,
                color: hasDevices ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: AppTextStyles.titleMedium(color: Colors.black),
                  ),
                  SizedBox(height: 4.h),
                  if (!hasDevices)
                    Text(
                      'Chưa có thiết bị',
                      style: AppTextStyles.bodyMedium(
                        color: Colors.orange.shade600,
                      ),
                    )
                  else
                    Row(
                      children: [
                        // Status dot
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${room.totalDevices} thiết bị · ${room.onlineDevices} online',
                          style: AppTextStyles.bodyMedium(
                            color: hasOffline
                                ? Colors.red.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Room Button ───────────────────────────────────────────────────────
class _AddRoomButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddRoomButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.add_rounded, size: 18.sp),
        label: const Text('Thêm phòng mới'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

// Empty Search State
class _EmptySearchState extends StatelessWidget {
  final String query;
  const _EmptySearchState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              'Không tìm thấy phòng "$query"',
              style: AppTextStyles.bodyMedium(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
