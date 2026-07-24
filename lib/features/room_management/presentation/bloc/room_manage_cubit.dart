import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_room_usecase.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_state.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';
import 'package:thermo_humi/features/device/domain/usecases/get_unassigned_devices_usecase.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';

class RoomManageCubit extends Cubit<RoomManageState> {
  final GetRoomsUseCase _getRoomsUseCase;
  final GetUnassignedDevicesUseCase _getUnassignedDevicesUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  RoomManageCubit({
    required GetRoomsUseCase getRoomsUseCase,
    required GetUnassignedDevicesUseCase getUnassignedDevicesUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
  }) : _getRoomsUseCase = getRoomsUseCase,
       _getUnassignedDevicesUseCase = getUnassignedDevicesUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       super(const RoomManageState());

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadRoomData(String roomId) async {
    emit(state.copyWith(status: RoomManageStatus.loading));

    final userId = await _getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: RoomManageStatus.success,
          errorMessage: 'User ID not found',
        ),
      );
      return;
    }

    try {
      final result = await _getRoomsUseCase.execute(userId);

      result.fold(
        (error) => emit(
          state.copyWith(
            status: RoomManageStatus.success, // Keep UI from crashing
            errorMessage: error,
          ),
        ),
        (rooms) {
          final roomWithDevices =
              rooms.where((r) => r.id == roomId).firstOrNull ??
              RoomEntity(
                id: roomId,
                name: 'Phòng không xác định',
                totalDevices: 0,
                onlineDevices: 0,
                alertCount: 0,
                createdAt: DateTime.now(),
              );

          emit(
            state.copyWith(
              status: RoomManageStatus.success,
              room: roomWithDevices,
              hasChanges: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RoomManageStatus.success,
          errorMessage: 'Lỗi tải dữ liệu: $e',
        ),
      );
    }
  }

  Future<List<DeviceEntity>> fetchUnassignedDevices() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final result = await _getUnassignedDevicesUseCase.execute(userId);
    return result.fold(
      (error) => [], // Trả về mảng rỗng nếu lỗi (có thể xử lý log lỗi)
      (devices) => devices,
    );
  }

  // Lấy userId từ storage thông qua UseCase
  Future<String?> _getUserId() async {
    try {
      final user = await _getUserProfileUseCase.execute();
      return user?.id;
    } catch (_) {
      return null;
    }
  }

  // Filter
  void changeFilter(DeviceFilterType filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  // Selection Mode
  void toggleSelectionMode() {
    final newMode = !state.isSelectionMode;
    emit(
      state.copyWith(
        isSelectionMode: newMode,
        selectedDeviceIds: newMode ? state.selectedDeviceIds : const {},
      ),
    );
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

  // Chuyển khỏi phòng này
  Future<bool> unassignDevice(String deviceId) async {
    final currentRwd = state.room;
    if (currentRwd == null) return false;

    // Optimistic update
    final newDevices = currentRwd.devices
        .where((d) => d.id != deviceId)
        .toList();
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.id,
      name: currentRwd.name,
      description: currentRwd.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.alertCount,
      createdAt: currentRwd.createdAt,
    );

    emit(
      state.copyWith(
        room: newRoom.copyWith(devices: newDevices),
        hasChanges: true,
      ),
    );

    try {
      // Mock API call — thay bằng repository khi có API
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      // Rollback on failure
      emit(
        state.copyWith(
          room: currentRwd,
          errorMessage: 'Không thể chuyển thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  //  Delete Device (Xoá khỏi hệ thống)
  Future<bool> deleteDeviceCompletely(String deviceId) async {
    final currentRwd = state.room;
    if (currentRwd == null) return false;

    // Optimistic update
    final newDevices = currentRwd.devices
        .where((d) => d.id != deviceId)
        .toList();
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.id,
      name: currentRwd.name,
      description: currentRwd.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.alertCount,
      createdAt: currentRwd.createdAt,
    );

    emit(
      state.copyWith(
        room: newRoom.copyWith(devices: newDevices),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          room: currentRwd,
          errorMessage: 'Không thể xoá thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  // Assign Existing Devices (Gán thiết bị chưa có phòng vào phòng này)
  Future<bool> assignExistingDevices(List<DeviceEntity> devicesToAdd) async {
    final currentRwd = state.room;
    if (currentRwd == null) return false;

    final newDevices = [...currentRwd.devices, ...devicesToAdd];
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.id,
      name: currentRwd.name,
      description: currentRwd.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.alertCount,
      createdAt: currentRwd.createdAt,
    );

    emit(
      state.copyWith(
        room: newRoom.copyWith(devices: newDevices),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          room: currentRwd,
          errorMessage: 'Không thể gán thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  //  Rename Room
  Future<bool> renameRoom(String newName) async {
    final currentRwd = state.room;
    if (currentRwd == null) return false;

    final updatedRoom = RoomEntity(
      id: currentRwd.id,
      name: newName,
      description: currentRwd.description,
      totalDevices: currentRwd.totalDevices,
      onlineDevices: currentRwd.onlineDevices,
      alertCount: currentRwd.alertCount,
      createdAt: currentRwd.createdAt,
    );

    emit(
      state.copyWith(
        room: updatedRoom.copyWith(devices: currentRwd.devices),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (_) {
      emit(state.copyWith(room: currentRwd));
      return false;
    }
  }

  // ── Delete Room (chỉ cho phép khi không còn thiết bị)
  Future<bool> deleteRoom() async {
    final currentRwd = state.room;
    if (currentRwd == null) return false;
    if (currentRwd.devices.isNotEmpty) return false; // Business rule

    emit(state.copyWith(status: RoomManageStatus.deleting));

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      emit(state.copyWith(status: RoomManageStatus.deleted, hasChanges: true));
      return true;
    } catch (_) {
      emit(state.copyWith(status: RoomManageStatus.success));
      return false;
    }
  }

  // ── Clear error ───────────────────────────────────────────────────────────
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> refreshRoomData(String roomId) async {
    await Future.delayed(const Duration(seconds: 1));
    loadRoomData(roomId);
  }
}
