import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/entities/hourly_report_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

enum DeviceReportStatus { initial, loadingFilters, filtersLoaded, loadingReport, reportLoaded, error }

class DeviceReportState extends Equatable {
  final DeviceReportStatus status;
  final List<RoomEntity> rooms;
  final RoomEntity? selectedRoom;
  final List<DeviceEntity> devices;
  final DeviceEntity? selectedDevice;
  final DateTime selectedDate;
  final List<HourlyReportEntity> reportData;
  final String? errorMessage;

  const DeviceReportState({
    this.status = DeviceReportStatus.initial,
    this.rooms = const [],
    this.selectedRoom,
    this.devices = const [],
    this.selectedDevice,
    required this.selectedDate,
    this.reportData = const [],
    this.errorMessage,
  });

  DeviceReportState copyWith({
    DeviceReportStatus? status,
    List<RoomEntity>? rooms,
    RoomEntity? selectedRoom,
    List<DeviceEntity>? devices,
    DeviceEntity? selectedDevice,
    DateTime? selectedDate,
    List<HourlyReportEntity>? reportData,
    String? errorMessage,
  }) {
    return DeviceReportState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      selectedDate: selectedDate ?? this.selectedDate,
      reportData: reportData ?? this.reportData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rooms,
        selectedRoom,
        devices,
        selectedDevice,
        selectedDate,
        reportData,
        errorMessage,
      ];
}
