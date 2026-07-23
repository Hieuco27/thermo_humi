import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';

class GetRoomsManagementUseCase {
  final RoomRepository _repository;

  GetRoomsManagementUseCase(this._repository);

  Future<Either<String, List<RoomEntity>>> execute(String userId) {
    return _repository.getRooms(userId);
  }
}
