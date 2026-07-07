import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  RoomDetailCubit() : super(const RoomDetailState());

  void loadRoomData(String roomId) async {
    emit(state.copyWith(status: RoomDetailStatus.loading));
    
    // Giả lập load API, sau này thay bằng repository call
    await Future.delayed(const Duration(milliseconds: 300));

    final allRooms = buildMockRooms();
    final roomWithDevices = allRooms.firstWhere(
      (r) => r.room.id == roomId,
      orElse: () => RoomWithDevices(
        room: RoomEntity(
          id: roomId,
          name: 'Phòng không xác định',
          totalDevices: 0,
          onlineDevices: 0,
          alertCount: 0,
          createdAt: DateTime.now(),
        ),
        devices: [],
      ),
    );

    emit(state.copyWith(
      status: RoomDetailStatus.success,
      roomWithDevices: roomWithDevices,
    ));
  }

  void changeFilter(DeviceFilterType filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void toggleSelectionMode() {
    final newMode = !state.isSelectionMode;
    emit(state.copyWith(
      isSelectionMode: newMode,
      selectedDeviceIds: newMode ? state.selectedDeviceIds : const {}, // Clear on exit
    ));
  }

  void toggleDeviceSelection(String deviceId) {
    final newSelected = Set<String>.from(state.selectedDeviceIds);
    if (newSelected.contains(deviceId)) {
      newSelected.remove(deviceId);
    } else {
      newSelected.add(deviceId);
    }
    emit(state.copyWith(selectedDeviceIds: newSelected));
  }

  void refreshRoomData(String roomId) async {
    // Giả lập refresh data
    await Future.delayed(const Duration(seconds: 1));
    loadRoomData(roomId);
  }
}
