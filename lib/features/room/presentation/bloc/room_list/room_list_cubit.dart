import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_room_usecase.dart';
import 'package:thermo_humi/features/room/presentation/bloc/room_list/room_list_state.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

class RoomListCubit extends Cubit<RoomListState> {
  final GetRoomsUseCase _getRoomsUseCase;

  RoomListCubit(this._getRoomsUseCase) : super(const RoomListState());

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
      final storage = sl<SecureStorage>();
      final userDataStr = await storage.read(AppConstants.kUserData);
      if (userDataStr != null) {
        final Map<String, dynamic> userJson = jsonDecode(userDataStr);
        return userJson['id']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
