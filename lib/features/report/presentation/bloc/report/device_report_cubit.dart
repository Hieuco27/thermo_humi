import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'device_report_state.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';

class DeviceReportCubit extends Cubit<DeviceReportState> {
  final DeviceRepository repository;

  DeviceReportCubit({required this.repository})
      : super(DeviceReportState(selectedDate: DateTime.now()));

  Future<void> loadFilters({String? initialDeviceId}) async {
    emit(state.copyWith(status: DeviceReportStatus.loadingFilters));

    final roomsResult = await repository.getRooms();

    roomsResult.fold(
      (error) => emit(state.copyWith(status: DeviceReportStatus.error, errorMessage: error)),
      (rooms) async {
        if (rooms.isEmpty) {
          emit(state.copyWith(status: DeviceReportStatus.filtersLoaded, rooms: rooms));
          return;
        }

        RoomEntity? selectedRoom;
        DeviceEntity? selectedDevice;
        List<DeviceEntity> devices = [];

        // If an initial deviceId is provided, we need to find its room
        if (initialDeviceId != null) {
          for (final room in rooms) {
            final devicesResult = await repository.getRoomDevices(room.id);
            devicesResult.fold((l) => null, (roomDevices) {
              final device = roomDevices.where((d) => d.id == initialDeviceId).firstOrNull;
              if (device != null) {
                selectedRoom = room;
                devices = roomDevices;
                selectedDevice = device;
              }
            });
            if (selectedRoom != null) break;
          }
        }

        emit(state.copyWith(
          status: DeviceReportStatus.filtersLoaded,
          rooms: rooms,
          selectedRoom: selectedRoom,
          devices: devices,
          selectedDevice: selectedDevice,
        ));
      },
    );
  }

  Future<void> selectRoom(RoomEntity room) async {
    emit(state.copyWith(status: DeviceReportStatus.loadingFilters, selectedRoom: room));
    final devicesResult = await repository.getRoomDevices(room.id);
    
    devicesResult.fold(
      (error) => emit(state.copyWith(status: DeviceReportStatus.error, errorMessage: error)),
      (devices) {
        emit(state.copyWith(
          status: DeviceReportStatus.filtersLoaded,
          devices: devices,
          selectedDevice: devices.isNotEmpty ? devices.first : null,
          reportData: [], // Clear report data when changing filters
        ));
      },
    );
  }

  void selectDevice(DeviceEntity device) {
    emit(state.copyWith(selectedDevice: device, reportData: [])); // Clear report data
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date, reportData: [])); // Clear report data
  }

  Future<void> fetchReport() async {
    if (state.selectedDevice == null) return;
    
    emit(state.copyWith(status: DeviceReportStatus.loadingReport));
    
    final result = await repository.getDeviceReport(
      state.selectedDevice!.id,
      state.selectedDate,
    );
    
    result.fold(
      (error) => emit(state.copyWith(status: DeviceReportStatus.error, errorMessage: error)),
      (data) => emit(state.copyWith(status: DeviceReportStatus.reportLoaded, reportData: data)),
    );
  }
}
