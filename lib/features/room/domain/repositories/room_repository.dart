/// Abstract interface — Room Repository (domain layer)
/// Không biết gì về HTTP / Dio. Chỉ làm việc với Entity thuần túy.
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';

abstract class RoomRepository {
  /// Lấy danh sách phòng (chỉ entity, không có devices).
  Future<Either<String, List<RoomEntity>>> getRooms(String userId);
}
