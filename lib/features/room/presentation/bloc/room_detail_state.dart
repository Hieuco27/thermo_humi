import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

enum RoomDetailStatus { initial, loading, success, failure }

class RoomDetailState extends Equatable {
  final RoomDetailStatus status;
  final RoomWithDevices? roomWithDevices;
  final DeviceFilterType activeFilter;
  final bool isSelectionMode;
  final Set<String> selectedDeviceIds;
  final String? errorMessage;

  const RoomDetailState({
    this.status = RoomDetailStatus.initial,
    this.roomWithDevices,
    this.activeFilter = DeviceFilterType.all,
    this.isSelectionMode = false,
    this.selectedDeviceIds = const {},
    this.errorMessage,
  });

  RoomDetailState copyWith({
    RoomDetailStatus? status,
    RoomWithDevices? roomWithDevices,
    DeviceFilterType? activeFilter,
    bool? isSelectionMode,
    Set<String>? selectedDeviceIds,
    String? errorMessage,
  }) {
    return RoomDetailState(
      status: status ?? this.status,
      roomWithDevices: roomWithDevices ?? this.roomWithDevices,
      activeFilter: activeFilter ?? this.activeFilter,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        roomWithDevices,
        activeFilter,
        isSelectionMode,
        selectedDeviceIds,
        errorMessage,
      ];
}
