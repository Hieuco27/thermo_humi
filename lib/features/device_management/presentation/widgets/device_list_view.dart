import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/device_management/device_management_state.dart';
import 'package:thermo_humi/features/room_management/presentation/widgets/room_detail/room_device_tile.dart';

class DeviceListView extends StatelessWidget {
  final ScrollController scrollController;

  const DeviceListView({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
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

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),
          itemCount: groupedKeys.length + (state.isFetchingMore ? 1 : 0),
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
                    top: 12.h,
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
    );
  }
}
