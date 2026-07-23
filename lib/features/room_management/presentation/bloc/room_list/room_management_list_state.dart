import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

enum RoomManagementListStatus { initial, loading, success, failure }

class RoomManagementListState extends Equatable {
  final RoomManagementListStatus status;
  final List<RoomEntity> rooms;
  final String? errorMessage;

  const RoomManagementListState({
    this.status = RoomManagementListStatus.initial,
    this.rooms = const [],
    this.errorMessage,
  });

  bool get isLoading => status == RoomManagementListStatus.loading;
  bool get isSuccess => status == RoomManagementListStatus.success;
  bool get isFailure => status == RoomManagementListStatus.failure;

  RoomManagementListState copyWith({
    RoomManagementListStatus? status,
    List<RoomEntity>? rooms,
    String? errorMessage,
  }) {
    return RoomManagementListState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rooms, errorMessage];
}
