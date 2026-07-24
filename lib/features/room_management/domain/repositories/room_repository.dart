/// Room Repository — abstract interface (Domain layer)
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

abstract class RoomRepository {
  Future<Either<String, List<RoomEntity>>> getRooms(String userId);
  Future<Either<String, void>> addRoom(String name);
}
