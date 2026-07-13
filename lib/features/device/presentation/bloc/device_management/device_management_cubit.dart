import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'device_management_state.dart';

class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final DeviceRepository _repository;
  Timer? _debounce;
  static const int _limit = 20;

  DeviceManagementCubit({required DeviceRepository repository})
    : _repository = repository,
      super(const DeviceManagementState());

  void loadInitialDevices() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.getDevices(
      search: state.searchQuery,
      sortOrder: state.sortOrder,
      statusFilter: state.statusFilter,
      roomId: state.roomIdFilter,
      page: 1,
      limit: _limit,
    );

    // tải các phòng nếu chưa được tải
    if (state.rooms.isEmpty) {
      final roomsResult = await _repository.getRooms();
      roomsResult.fold((l) => null, (r) => emit(state.copyWith(rooms: r)));
    }

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (data) {
        final grouped = _groupDevices(data.devices);
        emit(
          state
              .copyWith(
                isLoading: false,
                devices: data.devices,
                groupedDevices: grouped,
                currentPage: 1,
                hasReachedMax: data.devices.length >= data.totalCount,
              )
              .clearError(),
        );
      },
    );
  }

  void loadMore() async {
    if (state.hasReachedMax || state.isLoading || state.isFetchingMore) return;

    emit(state.copyWith(isFetchingMore: true, error: null));
    final nextPage = state.currentPage + 1;

    final result = await _repository.getDevices(
      search: state.searchQuery,
      sortOrder: state.sortOrder,
      statusFilter: state.statusFilter,
      roomId: state.roomIdFilter,
      page: nextPage,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(isFetchingMore: false, error: failure)),
      (data) {
        final newDevices = List<DeviceEntity>.from(state.devices)
          ..addAll(data.devices);
        final grouped = _groupDevices(newDevices);

        emit(
          state
              .copyWith(
                isFetchingMore: false,
                devices: newDevices,
                groupedDevices: grouped,
                currentPage: nextPage,
                hasReachedMax: newDevices.length >= data.totalCount,
              )
              .clearError(),
        );
      },
    );
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadInitialDevices();
    });
  }

  void onSortToggled() {
    final newSort = state.sortOrder == 'A-Z' ? 'Z-A' : 'A-Z';
    emit(state.copyWith(sortOrder: newSort));
    loadInitialDevices();
  }

  void onStatusFilterChanged(String status) {
    emit(state.copyWith(statusFilter: status));
    loadInitialDevices();
  }

  void onRoomFilterChanged(String? roomId) {
    if (roomId == null || roomId.isEmpty) {
      emit(state.clearRoomFilter());
    } else {
      emit(state.copyWith(roomIdFilter: roomId));
    }
    loadInitialDevices();
  }

  Map<String, List<DeviceEntity>> _groupDevices(List<DeviceEntity> devices) {
    final Map<String, List<DeviceEntity>> groups = {};
    for (final device in devices) {
      final firstLetter = device.name.trim().isNotEmpty
          ? device.name.trim()[0].toUpperCase()
          : '#';
      if (!groups.containsKey(firstLetter)) {
        groups[firstLetter] = [];
      }
      groups[firstLetter]!.add(device);
    }
    return groups;
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    // Todo: Cancel stream subscriptions (e.g. from a global event bus) when available
    return super.close();
  }
}
