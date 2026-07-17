import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_rooms_with_devices_usecase.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';
import 'package:thermo_humi/core/realtime/device_realtime_service.dart';

import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  final GetRoomsWithDevicesUseCase _getRoomsWithDevices;
  final DeviceRealtimeService _realtimeService;
  StreamSubscription? _subscription;

  RoomDetailCubit(this._getRoomsWithDevices, this._realtimeService) : super(const RoomDetailState()) {
    _subscription = _getRoomsWithDevices.stream.listen((rooms) {
      if (state.roomWithDevices != null) {
        final roomId = state.roomWithDevices!.room.id;
        final updatedRoom = rooms.firstWhere(
          (r) => r.room.id == roomId,
          orElse: () => state.roomWithDevices!,
        );
        emit(state.copyWith(
          status: RoomDetailStatus.success,
          roomWithDevices: updatedRoom,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadRoomData(String roomId) async {
    emit(state.copyWith(status: RoomDetailStatus.loading));
    
    final result = await _getRoomsWithDevices.execute();

    result.fold(
      (error) => emit(state.copyWith(
        status: RoomDetailStatus.failure,
        errorMessage: error,
      )),
      (rooms) {
        final roomWithDevices = rooms.firstWhere(
          (r) => r.room.id == roomId,
          orElse: () => RoomWithDevices(
            room: RoomEntity(
              id: roomId,
              name: 'Khu vực không xác định',
              totalDevices: 0,
              onlineDevices: 0,
              alertCount: 0,
              createdAt: DateTime.now(),
            ),
            devices: const [],
          ),
        );

        emit(state.copyWith(
          status: RoomDetailStatus.success,
          roomWithDevices: roomWithDevices,
        ));
      },
    );
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

  Future<void> refreshRoomData(String roomId) async {
    await loadRoomData(roomId);
  }
}
