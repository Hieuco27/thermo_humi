import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'device_report_state.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/usecases/get_room_usecase.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'dart:convert';

class DeviceReportCubit extends Cubit<DeviceReportState> {
  final DeviceRepository repository;
  final GetRoomsUseCase getRoomsUseCase;

  DeviceReportCubit({required this.repository, required this.getRoomsUseCase})
    : super(DeviceReportState(selectedDate: DateTime.now()));

  Future<void> loadFilters({String? initialDeviceId}) async {
    emit(state.copyWith(status: DeviceReportStatus.loadingFilters));

    final storage = sl<SecureStorage>();
    final userDataStr = await storage.read(AppConstants.kUserData);
    String? userId;
    if (userDataStr != null) {
      final Map<String, dynamic> userJson = jsonDecode(userDataStr);
      userId = userJson['id']?.toString();
    }

    if (userId == null) {
      emit(
        state.copyWith(
          status: DeviceReportStatus.error,
          errorMessage: 'User ID not found',
        ),
      );
      return;
    }

    final roomsResult = await getRoomsUseCase.execute(userId);

    roomsResult.fold(
      (error) => emit(
        state.copyWith(status: DeviceReportStatus.error, errorMessage: error),
      ),
      (rooms) async {
        if (rooms.isEmpty) {
          emit(
            state.copyWith(
              status: DeviceReportStatus.filtersLoaded,
              rooms: rooms,
            ),
          );
          return;
        }

        RoomEntity? selectedRoom;
        DeviceEntity? selectedDevice;
        List<DeviceEntity> devices = [];

        // If an initial deviceId is provided, we need to find its room
        if (initialDeviceId != null) {
          for (final room in rooms) {
            final devicesResult = await repository.getDevices(
              roomId: room.id,
              limit: 100,
            );
            devicesResult.fold((l) => null, (paginatedResult) {
              final roomDevices = paginatedResult.devices;
              final device = roomDevices
                  .where((d) => d.id == initialDeviceId)
                  .firstOrNull;
              if (device != null) {
                selectedRoom = room;
                devices = roomDevices;
                selectedDevice = device;
              }
            });
            if (selectedRoom != null) break;
          }
        }

        emit(
          state.copyWith(
            status: DeviceReportStatus.filtersLoaded,
            rooms: rooms,
            selectedRoom: selectedRoom,
            devices: devices,
            selectedDevice: selectedDevice,
          ),
        );
      },
    );
  }

  Future<void> selectRoom(RoomEntity room) async {
    // Ngay khi chọn phòng, lập tức xoá device và reportData,
    // đồng thời giữ status là filtersLoaded (không dùng loadingFilters nữa để tránh hiện loading)
    emit(
      DeviceReportState(
        status: DeviceReportStatus.filtersLoaded,
        rooms: state.rooms,
        selectedRoom: room,
        devices:
            const [], // Tạm thời rỗng trong lúc đợi tải danh sách mới (hoặc giữ state.devices tuỳ ý, nhưng rỗng thì tốt hơn để khỏi nhầm)
        selectedDevice: null,
        selectedDate: state.selectedDate,
        reportData: state.reportData, // Giữ nguyên dữ liệu cũ
      ),
    );
    final devicesResult = await repository.getDevices(roomId: room.id);

    devicesResult.fold(
      (error) => emit(
        state.copyWith(status: DeviceReportStatus.error, errorMessage: error),
      ),
      (paginatedResult) {
        emit(
          DeviceReportState(
            status: DeviceReportStatus.filtersLoaded,
            rooms: state.rooms,
            selectedRoom: state.selectedRoom,
            devices: paginatedResult.devices,
            selectedDevice: null,
            selectedDate: state.selectedDate,
            reportData: state.reportData,
          ),
        );
      },
    );
  }

  void selectDevice(DeviceEntity device) {
    emit(
      state.copyWith(
        status: DeviceReportStatus.filtersLoaded,
        selectedDevice: device,
      ),
    );
  }

  void selectDate(DateTime date) {
    emit(
      state.copyWith(
        status: DeviceReportStatus.filtersLoaded,
        selectedDate: date,
      ),
    );
  }

  Future<void> fetchReport() async {
    if (state.selectedDevice == null) return;

    emit(state.copyWith(status: DeviceReportStatus.loadingReport));

    final result = await repository.getDeviceReport(
      state.selectedDevice!.id,
      state.selectedDate,
    );

    result.fold(
      (error) => emit(
        state.copyWith(status: DeviceReportStatus.error, errorMessage: error),
      ),
      (data) => emit(
        state.copyWith(
          status: DeviceReportStatus.reportLoaded,
          reportData: data,
        ),
      ),
    );
  }
}
