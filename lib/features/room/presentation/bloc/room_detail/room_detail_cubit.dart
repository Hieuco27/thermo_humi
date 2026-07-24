import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_room_usecase.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  final GetRoomsUseCase _getRoomsUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  RoomDetailCubit(this._getRoomsUseCase, this._getUserProfileUseCase)
    : super(const RoomDetailState());

  Future<void> loadRoomData(String roomId) async {
    emit(state.copyWith(status: RoomDetailStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomDetailStatus.failure,
          errorMessage: "User ID not found",
        ),
      );
      return;
    }

    final result = await _getRoomsUseCase.execute(userId);

    result.fold(
      (error) => emit(
        state.copyWith(status: RoomDetailStatus.failure, errorMessage: error),
      ),
      (rooms) {
        final room = rooms.where((r) => r.id == roomId).firstOrNull;
        if (room != null) {
          emit(state.copyWith(status: RoomDetailStatus.success, room: room));
        } else {
          emit(
            state.copyWith(
              status: RoomDetailStatus.failure,
              errorMessage: "Phòng không tồn tại",
            ),
          );
        }
      },
    );
  }

  void setFilter(DeviceFilterType filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void toggleSelectionMode() {
    final newMode = !state.isSelectionMode;
    emit(
      state.copyWith(
        isSelectionMode: newMode,
        selectedDeviceIds: newMode
            ? state.selectedDeviceIds
            : const {}, // Clear on exit
      ),
    );
  }

  void toggleDeviceSelection(String deviceId) {
    final updatedSelection = Set<String>.from(state.selectedDeviceIds);
    if (updatedSelection.contains(deviceId)) {
      updatedSelection.remove(deviceId);
    } else {
      updatedSelection.add(deviceId);
    }
    emit(state.copyWith(selectedDeviceIds: updatedSelection));
  }

  Future<String?> _getUserId() async {
    try {
      final user = await _getUserProfileUseCase.execute();
      return user?.id;
    } catch (_) {
      return null;
    }
  }
}
