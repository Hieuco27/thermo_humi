import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

enum RoomListStatus { initial, loading, success, failure }

class RoomListState extends Equatable {
  final RoomListStatus status;
  final List<RoomWithDevices> rooms;
  final String? errorMessage;

  const RoomListState({
    this.status = RoomListStatus.initial,
    this.rooms = const [],
    this.errorMessage,
  });

  RoomListState copyWith({
    RoomListStatus? status,
    List<RoomWithDevices>? rooms,
    String? errorMessage,
  }) {
    return RoomListState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Tiện ích UI — kiểm tra trạng thái
  bool get isLoading => status == RoomListStatus.loading;
  bool get isSuccess => status == RoomListStatus.success;
  bool get isFailure => status == RoomListStatus.failure;
  bool get isEmpty => isSuccess && rooms.isEmpty;

  @override
  List<Object?> get props => [status, rooms, errorMessage];
}
