import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_list/room_management_list_cubit.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_list/room_management_list_state.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

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
  late List<RoomEntity> _allRooms;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
      _searchQuery = _searchCtrl.text.trim().toLowerCase();
    });
  }

  int _getTotalDevices(List<RoomEntity> rooms) =>
      rooms.fold(0, (sum, room) => sum + room.totalDevices);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RoomManagementListCubit>()..loadRooms(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const RoomMgmtAppBar(),
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

                    // Bloc Builder
                    Expanded(
                      child: BlocBuilder<RoomManagementListCubit, RoomManagementListState>(
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state.isFailure) {
                            return Center(
                              child: Text('Lỗi: ${state.errorMessage}'),
                            );
                          }

                          final allRooms = state.rooms;
                          final filteredRooms = _searchQuery.isEmpty
                              ? allRooms
                              : allRooms
                                    .where(
                                      (room) => room.name
                                          .toLowerCase()
                                          .contains(_searchQuery),
                                    )
                                    .toList();

                          return Column(
                            children: [
                              // Summary line
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${allRooms.length} phòng · ${_getTotalDevices(allRooms)} thiết bị',
                                    style: AppTextStyles.bodyMedium(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                              // Room List
                              Expanded(
                                child: filteredRooms.isEmpty
                                    ? EmptySearchState(query: _searchQuery)
                                    : RefreshIndicator(
                                        onRefresh: () async {
                                          await context
                                              .read<RoomManagementListCubit>()
                                              .refresh();
                                        },
                                        child: ListView.separated(
                                          padding: EdgeInsets.only(
                                            left: 8.w,
                                            right: 8.w,
                                            top: 4.h,
                                            // Chừa khoảng trống cho nút AddRoomButton ở dưới cùng
                                            bottom: 80.h,
                                          ),
                                          itemCount: filteredRooms.length,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: 14.h),
                                          itemBuilder: (context, index) {
                                            final room = filteredRooms[index];
                                            return RoomManagementCard(
                                              room: room,
                                              onTap: () => _openRoomDetail(
                                                context,
                                                room,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
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
                    child: Builder(
                      builder: (context) {
                        return AddRoomButton(onTap: () => _onAddRoom(context));
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openRoomDetail(BuildContext context, RoomEntity thisRoom) async {
    final result = await context.pushNamed<bool>(
      'room-management-detail',
      pathParameters: {'roomId': thisRoom.id},
    );

    if (result != null && mounted) {
      // Reload rooms to get updated details (like device counts, room names)
      context.read<RoomManagementListCubit>().refresh();
    }
  }

  void _onAddRoom(BuildContext context) async {
    final result = await context.pushNamed<dynamic>('add-room');

    // Cập nhật list phòng nếu tạo mới thành công (không cần gọi lại API)
    if (result != null && mounted) {
      context.read<RoomManagementListCubit>().refresh();
    }
  }
}
