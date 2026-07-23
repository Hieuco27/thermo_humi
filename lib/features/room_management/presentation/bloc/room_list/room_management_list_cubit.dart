import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/room_management/domain/usecases/get_rooms_usecase.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_list/room_management_list_state.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

class RoomManagementListCubit extends Cubit<RoomManagementListState> {
  final GetRoomsManagementUseCase _getRoomsUseCase;

  RoomManagementListCubit(this._getRoomsUseCase)
    : super(const RoomManagementListState());

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
