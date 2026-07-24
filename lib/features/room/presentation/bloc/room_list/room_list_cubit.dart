import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_room_usecase.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';

class RoomListCubit extends Cubit<RoomListState> {
  final GetRoomsUseCase _getRoomsUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  RoomListCubit(this._getRoomsUseCase, this._getUserProfileUseCase)
    : super(const RoomListState());

  Future<void> loadRooms() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RoomListStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomListStatus.failure,
          errorMessage: "User ID not found",
        ),
      );
      return;
    }

    final result = await _getRoomsUseCase.execute(userId);

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

  Future<void> refresh() async {
    emit(state.copyWith(status: RoomListStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomListStatus.failure,
          errorMessage: "User ID not found",
        ),
      );
      return;
    }

    final result = await _getRoomsUseCase.execute(userId);

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

  Future<String?> _getUserId() async {
    try {
      final user = await _getUserProfileUseCase.execute();
      return user?.id;
    } catch (_) {
      return null;
    }
  }
}
