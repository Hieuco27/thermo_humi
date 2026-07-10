import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/common/mock/mock_room_data.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/room_manage_state.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

class RoomManageCubit extends Cubit<RoomManageState> {
  RoomManageCubit() : super(const RoomManageState());

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadRoomData(String roomId) async {
    emit(state.copyWith(status: RoomManageStatus.loading));
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

    emit(
      state.copyWith(
        status: RoomManageStatus.success,
        roomWithDevices: roomWithDevices,
        hasChanges: false,
      ),
    );
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void changeFilter(DeviceFilterType filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  // ── Selection Mode ────────────────────────────────────────────────────────
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
    final currentRwd = state.roomWithDevices;
    if (currentRwd == null) return false;

    // Optimistic update
    final newDevices = currentRwd.devices
        .where((d) => d.id != deviceId)
        .toList();
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.room.id,
      name: currentRwd.room.name,
      description: currentRwd.room.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.room.alertCount,
      createdAt: currentRwd.room.createdAt,
    );

    emit(
      state.copyWith(
        roomWithDevices: RoomWithDevices(room: newRoom, devices: newDevices),
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
          roomWithDevices: currentRwd,
          errorMessage: 'Không thể chuyển thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  //  Delete Device (Xoá khỏi hệ thống)
  Future<bool> deleteDeviceCompletely(String deviceId) async {
    final currentRwd = state.roomWithDevices;
    if (currentRwd == null) return false;

    // Optimistic update
    final newDevices = currentRwd.devices
        .where((d) => d.id != deviceId)
        .toList();
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.room.id,
      name: currentRwd.room.name,
      description: currentRwd.room.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.room.alertCount,
      createdAt: currentRwd.room.createdAt,
    );

    emit(
      state.copyWith(
        roomWithDevices: RoomWithDevices(room: newRoom, devices: newDevices),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          roomWithDevices: currentRwd,
          errorMessage: 'Không thể xoá thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  // Assign Existing Devices (Gán thiết bị chưa có phòng vào phòng này)
  Future<bool> assignExistingDevices(List<DeviceEntity> devicesToAdd) async {
    final currentRwd = state.roomWithDevices;
    if (currentRwd == null) return false;

    final newDevices = [...currentRwd.devices, ...devicesToAdd];
    final onlineCount = newDevices.where((d) => d.isOnline).length;
    final newRoom = RoomEntity(
      id: currentRwd.room.id,
      name: currentRwd.room.name,
      description: currentRwd.room.description,
      totalDevices: newDevices.length,
      onlineDevices: onlineCount,
      alertCount: currentRwd.room.alertCount,
      createdAt: currentRwd.room.createdAt,
    );

    emit(
      state.copyWith(
        roomWithDevices: RoomWithDevices(room: newRoom, devices: newDevices),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          roomWithDevices: currentRwd,
          errorMessage: 'Không thể gán thiết bị. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  //  Rename Room
  Future<bool> renameRoom(String newName) async {
    final currentRwd = state.roomWithDevices;
    if (currentRwd == null) return false;

    final updatedRoom = RoomEntity(
      id: currentRwd.room.id,
      name: newName,
      description: currentRwd.room.description,
      totalDevices: currentRwd.room.totalDevices,
      onlineDevices: currentRwd.room.onlineDevices,
      alertCount: currentRwd.room.alertCount,
      createdAt: currentRwd.room.createdAt,
    );

    emit(
      state.copyWith(
        roomWithDevices: RoomWithDevices(
          room: updatedRoom,
          devices: currentRwd.devices,
        ),
        hasChanges: true,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (_) {
      emit(state.copyWith(roomWithDevices: currentRwd));
      return false;
    }
  }

  // ── Delete Room (chỉ cho phép khi không còn thiết bị)
  Future<bool> deleteRoom() async {
    final currentRwd = state.roomWithDevices;
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

  // ── Get unassigned devices (mock) ─────────────────────────────────────────
  Future<List<DeviceEntity>> getUnassignedDevices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return buildUnassignedDevices();
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
