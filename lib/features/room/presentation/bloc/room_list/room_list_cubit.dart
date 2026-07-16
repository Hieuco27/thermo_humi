import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_rooms_with_devices_usecase.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';

class RoomListCubit extends Cubit<RoomListState> {
  final GetRoomsWithDevicesUseCase _getRoomsWithDevices;

  RoomListCubit(this._getRoomsWithDevices) : super(const RoomListState());

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
