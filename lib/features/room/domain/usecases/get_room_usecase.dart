/// UseCase — Lấy danh sách phòng kèm thiết bị đang online
/// Gọi RoomRepository và trả về `Either<String, List<RoomWithDevices>>`.
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/repositories/room_repository.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

class GetRoomsUseCase {
  final RoomRepository _repository;

  GetRoomsUseCase(this._repository);

  Future<Either<String, List<RoomEntity>>> execute(String userId) {
    return _repository.getRooms(userId);
  }
}
