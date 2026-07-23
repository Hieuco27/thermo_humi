import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/widgets/room_detail/device_filter_bar.dart';

enum RoomManageStatus { initial, loading, success, failure, deleting, deleted }

class RoomManageState extends Equatable {
  final RoomManageStatus status;
  final RoomEntity? room;
  final DeviceFilterType activeFilter;
  final bool isSelectionMode;
  final Set<String> selectedDeviceIds;
  final String? errorMessage;
  final bool hasChanges;
  final bool isAdmin;

  const RoomManageState({
    this.status = RoomManageStatus.initial,
    this.room,
    this.activeFilter = DeviceFilterType.all,
    this.isSelectionMode = false,
    this.selectedDeviceIds = const {},
    this.errorMessage,
    this.hasChanges = false,
    this.isAdmin =
        true, // Mặc định là true theo giả định để test full chức năng
  });

  RoomManageState copyWith({
    RoomManageStatus? status,
    RoomEntity? room,
    DeviceFilterType? activeFilter,
    bool? isSelectionMode,
    Set<String>? selectedDeviceIds,
    String? errorMessage,
    bool? hasChanges,
    bool? isAdmin,
  }) {
    return RoomManageState(
      status: status ?? this.status,
      room: room ?? this.room,
      activeFilter: activeFilter ?? this.activeFilter,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      errorMessage: errorMessage ?? this.errorMessage,
      hasChanges: hasChanges ?? this.hasChanges,
      isAdmin: isAdmin ?? this.isAdmin,
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
    hasChanges,
    isAdmin,
  ];
}
