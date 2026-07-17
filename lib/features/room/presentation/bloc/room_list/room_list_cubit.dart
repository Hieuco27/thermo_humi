import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_rooms_with_devices_usecase.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';
import 'package:thermo_humi/core/realtime/device_realtime_service.dart';

class RoomListCubit extends Cubit<RoomListState> {
  final GetRoomsWithDevicesUseCase _getRoomsWithDevices;
  final DeviceRealtimeService _realtimeService;
  StreamSubscription? _subscription;

  RoomListCubit(this._getRoomsWithDevices, this._realtimeService) : super(const RoomListState()) {
    // Start Realtime connection
    _realtimeService.connect();

    // Listen to Realtime updates
    _subscription = _getRoomsWithDevices.stream.listen((rooms) {
      emit(state.copyWith(
        status: RoomListStatus.success,
        rooms: rooms,
        errorMessage: null,
      ));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  /// Gọi khi màn hình khởi tạo hoặc user kéo refresh
  Future<void> loadRooms() async {
    // Tránh load lại nếu đang loading
    if (state.isLoading) return;

    emit(state.copyWith(status: RoomListStatus.loading));

    final result = await _getRoomsWithDevices.execute();

    result.fold(
      // Left — thất bại
      (errorMessage) => emit(
        state.copyWith(
          status: RoomListStatus.failure,
          errorMessage: errorMessage,
        ),
      ),
      // Right — thành công
      (rooms) => emit(
        state.copyWith(
          status: RoomListStatus.success,
          rooms: rooms,
          errorMessage: null,
        ),
      ),
    );
  }

  /// Kéo để làm mới (pull-to-refresh) — reset về loading rồi load lại
  Future<void> refresh() async {
    emit(state.copyWith(status: RoomListStatus.loading));

    final result = await _getRoomsWithDevices.execute();

    result.fold(
      (errorMessage) => emit(
        state.copyWith(
          status: RoomListStatus.failure,
          errorMessage: errorMessage,
        ),
      ),
      (rooms) => emit(
        state.copyWith(
          status: RoomListStatus.success,
          rooms: rooms,
          errorMessage: null,
        ),
      ),
    );
  }
}
