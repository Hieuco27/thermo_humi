/// RoomManagementScreen — Màn hình quản lý phòng (từ Profile)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room_management/presentation/models/room_detail_result.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_management/room_management_app_bar.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_management/room_management_card.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_management/add_room_button.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_management/empty_search_state.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final keyboardHeight = MediaQueryData.fromView(
            View.of(context),
          ).viewInsets.bottom;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
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
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                            size: 22.sp,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 22.sp,
                                    color: Colors.grey,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_allRooms.length} phòng · $_totalDevices thiết bị',
                        style: AppTextStyles.bodyMedium(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),

                  //  Room List
                  Expanded(
                    child: _filteredRooms.isEmpty
                        ? EmptySearchState(query: _searchCtrl.text)
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              left: 8.w,
                              right: 8.w,
                              top: 4.h,
                              // Chừa khoảng trống cho nút AddRoomButton ở dưới cùng
                              bottom: 80.h,
                            ),
                            itemCount: _filteredRooms.length,
                            separatorBuilder: (_, __) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              final rwd = _filteredRooms[index];
                              return RoomManagementCard(
                                rwd: rwd,
                                onTap: () => _openRoomDetail(rwd.room),
                              );
                            },
                          ),
                  ),
                ],
              ),
              // Lớp 2: Nút thêm phòng nằm đè lên trên
              Positioned(
                left: 0,
                right: 0,
                // Đẩy lùi nút xuống bằng đúng chiều cao bàn phím để triệt tiêu sự co rút của Scaffold cha
                bottom: -keyboardHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: MediaQuery.viewPaddingOf(context).bottom + 16.h,
                    top: 8.h,
                  ),
                  child: AddRoomButton(onTap: _onAddRoom),
                ),
              ),
            ],
          );
        },
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

  void _onAddRoom() async {
    final result = await context.pushNamed<dynamic>('add-room');

    // Cập nhật list phòng nếu tạo mới thành công (không cần gọi lại API)
    if (result != null && mounted) {
      // Khi có real model: cast result thành AddRoomResult
      // Hiện tại reload mock data để thấy phòng mới
      setState(() {
        _allRooms = buildMockRooms();
        _filteredRooms = _allRooms;
      });
    }
  }
}
