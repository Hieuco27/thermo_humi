/// Abstract interface — Room Repository (domain layer)
/// Không biết gì về HTTP / Dio. Chỉ làm việc với Entity thuần túy.
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

abstract class RoomRepository {
  /// Lấy danh sách phòng kèm thiết bị đang online.
  /// Trả về [Right(List<RoomWithDevices>)] nếu thành công.
  /// Trả về [Left(String)] (message lỗi) nếu thất bại.
  Future<Either<String, List<RoomWithDevices>>> getRoomsWithDevices();

  /// Lấy danh sách phòng (chỉ entity, không có devices).
  Future<Either<String, List<RoomEntity>>> getRooms();

  /// Stream báo hiệu khi có thay đổi từ dữ liệu realtime
  Stream<List<RoomWithDevices>> get roomsWithDevicesStream;
}
