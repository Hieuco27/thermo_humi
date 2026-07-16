import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class DeviceManagementState extends Equatable {
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;

  final List<DeviceEntity> devices;
  final Map<String, List<DeviceEntity>> groupedDevices;
  final List<RoomEntity> rooms;
  final String searchQuery;
  final String sortOrder;
  final String statusFilter;
  final String? roomIdFilter;

  final int currentPage;
  final bool hasReachedMax;

  const DeviceManagementState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.devices = const [],
    this.groupedDevices = const {},
    this.rooms = const [],
    this.searchQuery = '',
    this.sortOrder = 'A-Z',
    this.statusFilter = 'all',
    this.roomIdFilter,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  DeviceManagementState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    List<DeviceEntity>? devices,
    Map<String, List<DeviceEntity>>? groupedDevices,
    List<RoomEntity>? rooms,
    String? searchQuery,
    String? sortOrder,
    String? statusFilter,
    String? roomIdFilter,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return DeviceManagementState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error:
          error, // Can set null if not provided via some logic, but usually we just let it be overridden
      devices: devices ?? this.devices,
      groupedDevices: groupedDevices ?? this.groupedDevices,
      rooms: rooms ?? this.rooms,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      statusFilter: statusFilter ?? this.statusFilter,
      roomIdFilter: roomIdFilter ?? this.roomIdFilter,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  // To allow clearing roomIdFilter explicitly
  DeviceManagementState clearRoomFilter() {
    return DeviceManagementState(
      isLoading: isLoading,
      isFetchingMore: isFetchingMore,
      error: error,
      devices: devices,
      groupedDevices: groupedDevices,
      rooms: rooms,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      statusFilter: statusFilter,
      roomIdFilter: null,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
    );
  }

  // Same for clearing error
  DeviceManagementState clearError() {
    return DeviceManagementState(
      isLoading: isLoading,
      isFetchingMore: isFetchingMore,
      error: null,
      devices: devices,
      groupedDevices: groupedDevices,
      rooms: rooms,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      statusFilter: statusFilter,
      roomIdFilter: roomIdFilter,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isFetchingMore,
    error,
    devices,
    groupedDevices,
    rooms,
    searchQuery,
    sortOrder,
    statusFilter,
    roomIdFilter,
    currentPage,
    hasReachedMax,
  ];
}
