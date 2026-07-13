import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/room_device_tile.dart';
import '../bloc/device_management/device_management_cubit.dart';
import '../bloc/device_management/device_management_state.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<DeviceManagementCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeviceManagementCubit>()..loadInitialDevices(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Quản lý thiết bị',
            style: AppTextStyles.titleMediumAppBar(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22.sp),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
              onPressed: () {
                // Navigate to add device logic (can reuse add device sheet later)
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            final cubit = context.read<DeviceManagementCubit>();
            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: SizedBox(
                    height: 40.h,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: cubit.onSearchChanged,
                      style: AppTextStyles.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên thiết bị',
                        hintStyle: AppTextStyles.bodyMedium(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 22.sp,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter & Sort Row
                BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.devices.length} thiết bị',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Row(
                            children: [
                              // Sort Button
                              InkWell(
                                onTap: cubit.onSortToggled,
                                borderRadius: BorderRadius.circular(16.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.swap_vert,
                                        size: 16.sp,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Tên ${state.sortOrder}',
                                        style: AppTextStyles.label13(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Filter Chips Row
                BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Status Filter Dropdown
                            _buildDropdownFilter(
                              label: state.statusFilter == 'all'
                                  ? 'Tất cả trạng thái'
                                  : (state.statusFilter == 'online'
                                        ? 'Online'
                                        : 'Offline'),
                              isActive: state.statusFilter != 'all',
                              onTap: () {
                                _showStatusFilterSheet(
                                  context,
                                  state.statusFilter,
                                  cubit.onStatusFilterChanged,
                                );
                              },
                            ),
                            SizedBox(width: 8.w),
                            // Room Filter Dropdown
                            _buildDropdownFilter(
                              label: state.roomIdFilter == null
                                  ? 'Tất cả phòng'
                                  : (state.rooms
                                            .where(
                                              (r) => r.id == state.roomIdFilter,
                                            )
                                            .firstOrNull
                                            ?.name ??
                                        'Phòng'),
                              isActive: state.roomIdFilter != null,
                              onTap: () {
                                _showRoomFilterSheet(
                                  context,
                                  state.rooms,
                                  state.roomIdFilter,
                                  cubit.onRoomFilterChanged,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),

                // List
                Expanded(
                  child: BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
                    builder: (context, state) {
                      if (state.isLoading && state.devices.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.devices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Không tìm thấy thiết bị phù hợp',
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final groupedKeys = state.groupedDevices.keys.toList();
                      // Because it's already sorted, keys might not be alphabetically sorted if Z-A,
                      // but the map entries retain insertion order in Dart (which matches the sorted devices)

                      return ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        itemCount:
                            groupedKeys.length + (state.isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == groupedKeys.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final letter = groupedKeys[index];
                          final groupDevices = state.groupedDevices[letter]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 8.h,
                                ),
                                child: Text(
                                  letter,
                                  style: AppTextStyles.titleMedium(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              ...groupDevices.map((device) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to DeviceThresholdScreen
                                      // context.pushNamed('device_detail', pathParameters: {'id': device.id});
                                    },
                                    child: RoomDeviceTile(
                                      device: device,
                                      showRoomBadge: true,
                                      onMoreTap: () {
                                        // Handle more
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.label13(
                color: isActive ? AppColors.primary : Colors.black,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: isActive ? AppColors.primary : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterSheet(
    BuildContext context,
    String currentStatus,
    Function(String) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tất cả trạng thái'),
                trailing: currentStatus == 'all'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged('all');
                  context.pop();
                },
              ),
              ListTile(
                title: const Text('Online'),
                trailing: currentStatus == 'online'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged('online');
                  context.pop();
                },
              ),
              ListTile(
                title: const Text('Offline'),
                trailing: currentStatus == 'offline'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged('offline');
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoomFilterSheet(
    BuildContext context,
    List<dynamic> rooms,
    String? currentRoomId,
    Function(String?) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tất cả phòng'),
                trailing: currentRoomId == null
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged(null);
                  context.pop();
                },
              ),
              ...rooms.map(
                (r) => ListTile(
                  title: Text(r.name),
                  trailing: currentRoomId == r.id
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onChanged(r.id);
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
