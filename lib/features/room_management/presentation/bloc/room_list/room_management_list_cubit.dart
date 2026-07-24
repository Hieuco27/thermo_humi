import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room_management/domain/usecases/get_rooms_usecase.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_list/room_management_list_state.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';

class RoomManagementListCubit extends Cubit<RoomManagementListState> {
  final GetRoomsManagementUseCase _getRoomsUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  RoomManagementListCubit(
    this._getRoomsUseCase,
    this._getUserProfileUseCase,
  ) : super(const RoomManagementListState());

  Future<void> loadRooms() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RoomManagementListStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomManagementListStatus.failure,
          errorMessage: "User ID not found",
        ),
      );
      return;
    }

    final result = await _getRoomsUseCase.execute(userId);

    result.fold(
      (errorMessage) => emit(
        state.copyWith(
          status: RoomManagementListStatus.failure,
          errorMessage: errorMessage,
        ),
      ),
      (rooms) => emit(
        state.copyWith(
          status: RoomManagementListStatus.success,
          rooms: rooms,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: RoomManagementListStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomManagementListStatus.failure,
          errorMessage: "User ID not found",
        ),
      );
      return;
    }

    final result = await _getRoomsUseCase.execute(userId);

    result.fold(
      (errorMessage) => emit(
        state.copyWith(
          status: RoomManagementListStatus.failure,
          errorMessage: errorMessage,
        ),
      ),
      (rooms) => emit(
        state.copyWith(
          status: RoomManagementListStatus.success,
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
