import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

enum RoomDetailStatus { initial, loading, success, failure }

class RoomDetailState extends Equatable {
  final RoomDetailStatus status;
  final RoomEntity? room;
  final DeviceFilterType activeFilter;
  final bool isSelectionMode;
  final Set<String> selectedDeviceIds;
  final String? errorMessage;

  const RoomDetailState({
    this.status = RoomDetailStatus.initial,
    this.room,
    this.activeFilter = DeviceFilterType.all,
    this.isSelectionMode = false,
    this.selectedDeviceIds = const {},
    this.errorMessage,
  });

  RoomDetailState copyWith({
    RoomDetailStatus? status,
    RoomEntity? room,
    DeviceFilterType? activeFilter,
    bool? isSelectionMode,
    Set<String>? selectedDeviceIds,
    String? errorMessage,
  }) {
    return RoomDetailState(
      status: status ?? this.status,
      room: room ?? this.room,
      activeFilter: activeFilter ?? this.activeFilter,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    room,
    activeFilter,
    isSelectionMode,
    selectedDeviceIds,
    errorMessage,
  ];
}
